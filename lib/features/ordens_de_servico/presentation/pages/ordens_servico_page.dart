import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/shared/widgets/empty_state.dart';
import 'package:sisan/shared/widgets/pending_sync_banner.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                    itemBuilder: (_, i) => _OrdemServicoCard(
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

class _OrdemServicoCard extends StatelessWidget {
  const _OrdemServicoCard({required this.ordemServico, required this.onTap});

  final OrdemServico ordemServico;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ocorrencia = ordemServico.ocorrencia;
    final isMinha =
        ordemServico.tecnicoId == Supabase.instance.client.auth.currentUser?.id;
    final tempoDecorrido = _tempoDecorrido(ordemServico.criadoEm);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMinha
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ocorrencia.urgencia.cor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ocorrencia.tipo.icone,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ocorrencia.tipo.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StatusChip(status: ordemServico.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ocorrencia.endereco ?? ocorrencia.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 13,
                          color: Colors.black38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tempoDecorrido,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                        if (ocorrencia.protocolo != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.tag, size: 13, color: Colors.black38),
                          const SizedBox(width: 4),
                          Text(
                            ocorrencia.protocolo!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isMinha)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Sua OS ativa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  String _tempoDecorrido(DateTime criadoEm) {
    final diff = DateTime.now().difference(criadoEm);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return DateFormat('dd/MM HH:mm').format(criadoEm);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrdemServicoStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status.cor,
        ),
      ),
    );
  }
}
