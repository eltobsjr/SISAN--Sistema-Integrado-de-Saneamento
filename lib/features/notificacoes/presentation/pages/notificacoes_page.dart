import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sisan/features/notificacoes/domain/entities/notificacao.dart';
import 'package:sisan/features/notificacoes/presentation/providers/notificacoes_provider.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

class NotificacoesPage extends ConsumerWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificacoesProvider);
    final naoLidas = ref.watch(notificacoesNaoLidasProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notificações'),
            if (naoLidas > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$naoLidas',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (naoLidas > 0)
            IconButton(
              onPressed: () => ref.read(notificacoesProvider.notifier).marcarTodasComoLidas(),
              icon: const Icon(Icons.done_all_rounded),
              tooltip: 'Marcar todas como lidas',
            ),
        ],
      ),
      body: state.when(
        loading: () => const SkeletonList(itemCount: 6),
        error: (_, _) => SisanErrorState(onRetry: () => ref.invalidate(notificacoesProvider)),
        data: (notificacoes) {
          if (notificacoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 64, color: Colors.black26),
                  const SizedBox(height: 12),
                  Text('Nenhuma notificação', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black45)),
                  const SizedBox(height: 4),
                  Text(
                    'Você será notificado sobre suas ocorrências e ordens de serviço',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificacoesProvider),
            child: ListView.separated(
              itemCount: notificacoes.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
              itemBuilder: (_, i) => Dismissible(
                key: ValueKey(notificacoes[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => ref.read(notificacoesProvider.notifier).excluir(notificacoes[i].id),
                child: _NotificacaoTile(
                  notificacao: notificacoes[i],
                  onTap: () => _onTap(context, ref, notificacoes[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, Notificacao n) {
    if (!n.lida) {
      ref.read(notificacoesProvider.notifier).marcarComoLida(n.id);
    }
    final dados = n.dados;
    if (dados == null) return;
    switch (n.tipo) {
      case 'nova_os':
        final id = dados['ordem_servico_id'] as String?;
        if (id != null) context.push('/ordens-de-servico/$id');
      case 'status_os':
        final id = dados['ocorrencia_id'] as String?;
        if (id != null) context.push('/ocorrencias/$id');
    }
  }
}

class _NotificacaoTile extends StatelessWidget {
  const _NotificacaoTile({required this.notificacao, required this.onTap});

  final Notificacao notificacao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, cor) = _iconeCor(notificacao.tipo);
    final diff = DateTime.now().difference(notificacao.criadoEm);
    final tempo = diff.inMinutes < 60
        ? 'há ${diff.inMinutes} min'
        : diff.inHours < 24
            ? 'há ${diff.inHours}h'
            : DateFormat('dd/MM HH:mm').format(notificacao.criadoEm);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notificacao.lida ? null : cor.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: cor, size: 20),
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
                          notificacao.titulo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: notificacao.lida ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notificacao.lida)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notificacao.corpo,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(tempo, style: theme.textTheme.labelSmall?.copyWith(color: Colors.black38)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color) _iconeCor(String tipo) => switch (tipo) {
        'nova_os' => (Icons.assignment_outlined, const Color(0xFF0288D1)),
        'status_os' => (Icons.water_drop_outlined, const Color(0xFF2E7D32)),
        _ => (Icons.notifications_outlined, Colors.blueGrey),
      };
}
