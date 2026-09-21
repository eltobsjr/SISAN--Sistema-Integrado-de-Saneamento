import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/widgets/ordem_servico_card.dart';
import 'package:sisan/shared/widgets/empty_state.dart';
import 'package:sisan/shared/widgets/pending_sync_banner.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

/// Fila de Ordens de Serviço do técnico — adaptado de `ResgatesPage` do
/// SIGAU (feature `resgates`), trocando a urgência 1-5 por
/// [OcorrenciaUrgencia] e a distância por ordem de chegada na fila.
class OrdensServicoPage extends ConsumerWidget {
  const OrdensServicoPage({super.key});

  List<OrdemServico> _ordenar(List<OrdemServico> lista) {
    final copia = List<OrdemServico>.from(lista);
    copia.sort((a, b) {
      final urgDiff = b.ocorrencia.urgencia.index.compareTo(
        a.ocorrencia.urgencia.index,
      );
      if (urgDiff != 0) return urgDiff;
      return a.criadoEm.compareTo(b.criadoEm);
    });
    return copia;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordensServicoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(ordensServicoProvider.notifier).recarregar(),
          ),
        ],
      ),
      body: Column(
        children: [
          const PendingSyncBanner(),
          Expanded(
            child: state.when(
              loading: () => const SkeletonList(),
              error: (_, _) => SisanErrorState(
                onRetry: () =>
                    ref.read(ordensServicoProvider.notifier).recarregar(),
              ),
              data: (lista) {
                final ordenada = _ordenar(lista);
                if (ordenada.isEmpty) {
                  return const EmptyState(
                    icon: Icons.check_circle_outline,
                    message:
                        'Nenhuma ordem de serviço pendente.\n'
                        'Todas as ocorrências do município estão em dia.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(ordensServicoProvider.notifier).recarregar(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ordenada.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => OrdemServicoCard(
                      ordemServico: ordenada[i],
                      onTap: () =>
                          context.push('/ordens-de-servico/${ordenada[i].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
