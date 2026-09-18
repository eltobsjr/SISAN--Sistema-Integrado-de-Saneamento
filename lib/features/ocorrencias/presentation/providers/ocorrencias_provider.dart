import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ocorrencias/data/datasources/ocorrencia_supabase_datasource.dart';
import 'package:sisan/features/ocorrencias/data/repositories/ocorrencia_repository_impl.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/domain/repositories/i_ocorrencia_repository.dart';

final ocorrenciaRepositoryProvider = Provider<IOcorrenciaRepository>((ref) {
  return OcorrenciaRepositoryImpl(OcorrenciaSupabaseDatasource());
});

/// "Minhas ocorrências" — lista do cidadão autenticado.
class OcorrenciasNotifier extends AsyncNotifier<List<Ocorrencia>> {
  @override
  Future<List<Ocorrencia>> build() async {
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
