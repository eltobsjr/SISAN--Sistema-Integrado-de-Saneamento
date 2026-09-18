import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ordens_de_servico/data/datasources/ordem_servico_supabase_datasource.dart';
import 'package:sisan/features/ordens_de_servico/data/repositories/ordem_servico_repository_impl.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/domain/repositories/i_ordem_servico_repository.dart';

final ordemServicoRepositoryProvider = Provider<IOrdemServicoRepository>((ref) {
  return OrdemServicoRepositoryImpl(OrdemServicoSupabaseDatasource());
});

/// Fila de OS do município do técnico autenticado.
class OrdensServicoNotifier extends AsyncNotifier<List<OrdemServico>> {
  @override
  Future<List<OrdemServico>> build() async {
    final usuario = await ref.watch(authProvider.future);
    if (usuario == null) return [];
    return ref.read(ordemServicoRepositoryProvider).listarFila(usuario.municipioId);
  }

  Future<void> recarregar() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> aceitar(String osId) async {
    final usuario = await ref.read(authProvider.future);
    if (usuario == null) throw Exception('Usuário não autenticado.');
    await ref.read(ordemServicoRepositoryProvider).aceitar(
          osId: osId,
          tecnicoId: usuario.id,
        );
    ref.invalidateSelf();
  }

  Future<void> registrarChegada(
    String osId, {
    required double latitude,
    required double longitude,
  }) async {
    await ref.read(ordemServicoRepositoryProvider).registrarChegada(
          osId: osId,
          latitude: latitude,
          longitude: longitude,
        );
    ref.invalidateSelf();
  }

  Future<void> concluir(
    String osId, {
    required Map<String, bool> checklist,
    List<File> fotosDepois = const [],
  }) async {
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
