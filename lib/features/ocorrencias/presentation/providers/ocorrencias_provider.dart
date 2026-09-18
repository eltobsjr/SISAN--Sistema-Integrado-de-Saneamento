import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ocorrencias/data/datasources/ocorrencia_supabase_datasource.dart';
import 'package:sisan/features/ocorrencias/data/repositories/ocorrencia_repository_impl.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/domain/repositories/i_ocorrencia_repository.dart';
import 'package:sisan/shared/providers/sync_version_provider.dart';
import 'package:sisan/shared/services/connectivity_service.dart';
import 'package:sisan/shared/services/sync_service.dart';

/// Sentinela usada no lugar do protocolo real (gerado só no servidor) quando
/// a ocorrência foi criada offline e ainda está na fila de sincronização.
const kProtocoloOffline = 'OFFLINE';

final ocorrenciaRepositoryProvider = Provider<IOcorrenciaRepository>((ref) {
  return OcorrenciaRepositoryImpl(OcorrenciaSupabaseDatasource());
});

/// "Minhas ocorrências" — lista do cidadão autenticado.
class OcorrenciasNotifier extends AsyncNotifier<List<Ocorrencia>> {
  @override
  Future<List<Ocorrencia>> build() async {
    // Recarrega quando a fila offline local termina de sincronizar, pra
    // trocar o item "OFFLINE" pelo protocolo real assim que ele existir.
    ref.listen<int>(syncVersionProvider, (_, _) => ref.invalidateSelf());

    final usuario = await ref.watch(authProvider.future);
    if (usuario == null) return [];
    return ref.read(ocorrenciaRepositoryProvider).listarMinhas(usuario.id);
  }

  Future<Ocorrencia> criar({
    required OcorrenciaTipo tipo,
    required String descricao,
    List<File> fotos = const [],
    String? endereco,
    double? latitude,
    double? longitude,
  }) async {
    final usuario = await ref.read(authProvider.future);
    if (usuario == null) throw Exception('Usuário não autenticado.');

    final online = kIsWeb || await ref.read(connectivityServiceProvider).isOnline();
    if (!online) {
      final localPaths = fotos.isEmpty
          ? const <String>[]
          : await SyncService.savePhotosLocally(fotos, usuario.id);

      final pendente = Ocorrencia(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        municipioId: usuario.municipioId,
        denuncianteId: usuario.id,
        tipo: tipo,
        descricao: descricao,
        endereco: endereco,
        latitude: latitude,
        longitude: longitude,
        status: OcorrenciaStatus.pendente,
        urgencia: OcorrenciaUrgencia.normal,
        protocolo: kProtocoloOffline,
        criadoEm: DateTime.now(),
      );

      await ref.read(syncServiceProvider).enqueue(
        operation: 'INSERT',
        table: 'ocorrencias',
        payload: {
          'municipio_id': usuario.municipioId,
          'denunciante_id': usuario.id,
          'tipo': tipo.dbValue,
          'descricao': descricao,
          'endereco': ?endereco,
          'latitude': ?latitude,
          'longitude': ?longitude,
          '_local_photo_paths': localPaths,
        },
      );
      ref.invalidate(pendingSyncCountProvider);
      state = AsyncData([pendente, ...(state.valueOrNull ?? [])]);
      return pendente;
    }

    final ocorrencia = await ref.read(ocorrenciaRepositoryProvider).criar(
          municipioId: usuario.municipioId,
          denuncianteId: usuario.id,
          tipo: tipo,
          descricao: descricao,
          fotos: fotos,
          endereco: endereco,
          latitude: latitude,
          longitude: longitude,
        );
    ref.invalidateSelf();
    return ocorrencia;
  }
}

final ocorrenciasProvider =
    AsyncNotifierProvider<OcorrenciasNotifier, List<Ocorrencia>>(
  OcorrenciasNotifier.new,
);

/// Busca uma ocorrência direto pelo id — usado quando a tela de detalhe é
/// aberta sem o objeto completo em mãos (ex: deep link futuro).
final ocorrenciaPorIdProvider =
    FutureProvider.autoDispose.family<Ocorrencia, String>((ref, id) {
  return ref.watch(ocorrenciaRepositoryProvider).buscarPorId(id);
});
