import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ordens_de_servico/data/datasources/ordem_servico_supabase_datasource.dart';
import 'package:sisan/features/ordens_de_servico/data/repositories/ordem_servico_repository_impl.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/domain/repositories/i_ordem_servico_repository.dart';
import 'package:sisan/shared/providers/realtime_version_provider.dart';
import 'package:sisan/shared/providers/sync_version_provider.dart';
import 'package:sisan/shared/services/connectivity_service.dart';
import 'package:sisan/shared/services/sync_service.dart';

final ordemServicoRepositoryProvider = Provider<IOrdemServicoRepository>((ref) {
  return OrdemServicoRepositoryImpl(OrdemServicoSupabaseDatasource());
});

/// Fila de OS do município do técnico autenticado.
class OrdensServicoNotifier extends AsyncNotifier<List<OrdemServico>> {
  @override
  Future<List<OrdemServico>> build() async {
    // Recarrega quando outro técnico muda uma OS (Realtime) ou quando a
    // fila offline local termina de sincronizar.
    ref.listen<int>(realtimeVersionProvider('ordens_servico'), (_, _) => recarregar());
    ref.listen<int>(syncVersionProvider, (_, _) => recarregar());

    final usuario = await ref.watch(authProvider.future);
    if (usuario == null) return [];
    return ref.read(ordemServicoRepositoryProvider).listarFila(usuario.municipioId);
  }

  Future<void> recarregar() async {
    ref.invalidateSelf();
    await future;
  }

  Future<bool> get _online async =>
      kIsWeb || await ref.read(connectivityServiceProvider).isOnline();

  void _atualizarLocal(String osId, OrdemServico Function(OrdemServico) atualizar) {
    state = AsyncData(
      (state.valueOrNull ?? []).map((os) => os.id == osId ? atualizar(os) : os).toList(),
    );
  }

  Future<void> aceitar(String osId) async {
    final usuario = await ref.read(authProvider.future);
    if (usuario == null) throw Exception('Usuário não autenticado.');

    if (!await _online) {
      _atualizarLocal(
        osId,
        (os) => os.copyWith(
          tecnicoId: usuario.id,
          status: OrdemServicoStatus.aceita,
          aceitaEm: DateTime.now(),
        ),
      );
      await ref.read(syncServiceProvider).enqueue(
        operation: 'ACEITAR',
        table: 'ordens_servico',
        payload: {
          '_id': osId,
          'tecnico_id': usuario.id,
          'status': OrdemServicoStatus.aceita.dbValue,
          'aceita_em': DateTime.now().toUtc().toIso8601String(),
        },
      );
      ref.invalidate(pendingSyncCountProvider);
      return;
    }

    await ref.read(ordemServicoRepositoryProvider).aceitar(osId: osId, tecnicoId: usuario.id);
    ref.invalidateSelf();
  }

  Future<void> registrarChegada(
    String osId, {
    required double latitude,
    required double longitude,
  }) async {
    if (!await _online) {
      _atualizarLocal(
        osId,
        (os) => os.copyWith(status: OrdemServicoStatus.aCaminho, chegadaEm: DateTime.now()),
      );
      await ref.read(syncServiceProvider).enqueue(
        operation: 'CHEGADA',
        table: 'ordens_servico',
        payload: {
          '_id': osId,
          'status': OrdemServicoStatus.aCaminho.dbValue,
          'chegada_em': DateTime.now().toUtc().toIso8601String(),
          'chegada_latitude': latitude,
          'chegada_longitude': longitude,
        },
      );
      ref.invalidate(pendingSyncCountProvider);
      return;
    }

    await ref
        .read(ordemServicoRepositoryProvider)
        .registrarChegada(osId: osId, latitude: latitude, longitude: longitude);
    ref.invalidateSelf();
  }

  Future<void> concluir(
    String osId, {
    required Map<String, bool> checklist,
    List<File> fotosDepois = const [],
  }) async {
    if (!await _online) {
      // Offline: conclui mesmo assim (atualização otimista) — as fotos são
      // copiadas pra um diretório permanente e sobem no próximo sync, nunca
      // se perdem, mas não aparecem na UI até lá (ver devtrack da Fase Offline).
      final localPaths = fotosDepois.isEmpty
          ? const <String>[]
          : await SyncService.savePhotosLocally(fotosDepois, osId);

      _atualizarLocal(
        osId,
        (os) => os.copyWith(
          status: OrdemServicoStatus.concluida,
          checklist: checklist,
          concluidaEm: DateTime.now(),
        ),
      );
      await ref.read(syncServiceProvider).enqueue(
        operation: 'CONCLUIR',
        table: 'ordens_servico',
        payload: {
          '_id': osId,
          'status': OrdemServicoStatus.concluida.dbValue,
          'checklist': checklist,
          'concluida_em': DateTime.now().toUtc().toIso8601String(),
          '_local_photo_paths': localPaths,
        },
      );
      ref.invalidate(pendingSyncCountProvider);
      return;
    }

    await ref.read(ordemServicoRepositoryProvider).concluir(
          osId: osId,
          checklist: checklist,
          fotosDepois: fotosDepois,
        );
    ref.invalidateSelf();
  }
}

final ordensServicoProvider =
    AsyncNotifierProvider<OrdensServicoNotifier, List<OrdemServico>>(
  OrdensServicoNotifier.new,
);

/// Busca uma OS direto pelo id — usado quando a tela de detalhe é aberta sem
/// o objeto completo em mãos (ex: link de notificação futuro).
final ordemServicoPorIdProvider =
    FutureProvider.autoDispose.family<OrdemServico, String>((ref, id) {
  return ref.watch(ordemServicoRepositoryProvider).buscarPorId(id);
});
