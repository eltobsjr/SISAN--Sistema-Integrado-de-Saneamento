import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/notificacoes/domain/entities/notificacao.dart';
import 'package:sisan/features/notificacoes/presentation/providers/notificacoes_provider.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/shared/widgets/empty_state.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

class NotificacoesPage extends ConsumerStatefulWidget {
  const NotificacoesPage({super.key});

  @override
  ConsumerState<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends ConsumerState<NotificacoesPage> {
  bool _soNaoLidas = false;

  List<(String, List<Notificacao>)> _agrupar(List<Notificacao> lista) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final semana = hoje.subtract(const Duration(days: 7));
    final grupos = <String, List<Notificacao>>{'Hoje': [], 'Últimos 7 dias': [], 'Anteriores': []};
    for (final n in lista) {
      final c = n.criadoEm.toLocal();
      final chave = !c.isBefore(hoje) ? 'Hoje' : (!c.isBefore(semana) ? 'Últimos 7 dias' : 'Anteriores');
      grupos[chave]!.add(n);
    }
    return [for (final e in grupos.entries) if (e.value.isNotEmpty) (e.key, e.value)];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificacoesProvider);
    final naoLidas = ref.watch(notificacoesNaoLidasProvider);

    return Scaffold(
      appBar: SisanAppBar(
        title: const Text('Notificações'),
        actions: [
          if (naoLidas > 0)
            TextButton.icon(
              onPressed: () => ref.read(notificacoesProvider.notifier).marcarTodasComoLidas(),
              icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
              label: const Text('Ler todas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: state.when(
        loading: () => const SkeletonList(itemCount: 6),
        error: (_, _) => SisanErrorState(onRetry: () => ref.invalidate(notificacoesProvider)),
        data: (todas) {
          final notificacoes = _soNaoLidas ? todas.where((n) => !n.lida).toList() : todas;
          return Column(
            children: [
              Container(
                color: SisanCores.superficie,
                padding: const EdgeInsets.fromLTRB(SisanEspaco.tela, SisanEspaco.md, SisanEspaco.tela, SisanEspaco.md),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: SisanCores.primariaClara,
                    selectedForegroundColor: SisanCores.primariaEscura,
                  ),
                  segments: [
                    ButtonSegment(value: false, label: Text('Todas (${todas.length})')),
                    ButtonSegment(value: true, label: Text('Não lidas ($naoLidas)')),
                  ],
                  selected: {_soNaoLidas},
                  onSelectionChanged: (v) => setState(() => _soNaoLidas = v.first),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: notificacoes.isEmpty
                    ? EmptyState(
                        icon: _soNaoLidas ? Icons.mark_email_read_outlined : Icons.notifications_none_rounded,
                        message: _soNaoLidas
                            ? 'Tudo lido por aqui.'
                            : 'Nenhuma notificação.\nVocê será avisado sobre ocorrências, ordens de serviço e alertas.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(notificacoesProvider),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(SisanEspaco.tela, 0, SisanEspaco.tela, SisanEspaco.xl),
                          children: [
                            for (final (titulo, itens) in _agrupar(notificacoes)) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, SisanEspaco.lg, 0, SisanEspaco.sm),
                                child: Text(titulo.toUpperCase(), style: SisanTexto.rotulo),
                              ),
                              for (final (i, n) in itens.indexed) ...[
                                if (i > 0) const SizedBox(height: SisanEspaco.sm),
                                Dismissible(
                                  key: ValueKey(n.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: SisanCores.perigo,
                                      borderRadius: BorderRadius.circular(SisanRaio.lg),
                                    ),
                                    child: const Icon(Icons.delete_outline, color: Colors.white),
                                  ),
                                  onDismissed: (_) => ref.read(notificacoesProvider.notifier).excluir(n.id),
                                  child: _NotificacaoCard(notificacao: n, onTap: () => _onTap(context, ref, n)),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
              ),
            ],
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
      case 'alerta_sanitario':
        final id = dados['alerta_sanitario_id'] as String?;
        if (id != null) context.push('/alertas-sanitarios/$id');
    }
  }
}

class _NotificacaoCard extends StatelessWidget {
  const _NotificacaoCard({required this.notificacao, required this.onTap});

  final Notificacao notificacao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notificacao;
    final (icone, cor, rotulo, acao) = _estilo(n.tipo);

    return SisanCard(
      onTap: onTap,
      corDestaque: n.lida ? null : cor,
      cor: n.lida ? SisanCores.superficie : cor.withValues(alpha: 0.04),
      padding: EdgeInsets.fromLTRB(n.lida ? SisanEspaco.md + 2 : SisanEspaco.lg + 2, SisanEspaco.md + 2, SisanEspaco.md + 2, SisanEspaco.md + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icone, cor: cor, tamanho: 40, solido: !n.lida),
          const SizedBox(width: SisanEspaco.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(rotulo, cor: cor),
                    const Spacer(),
                    Text(tempoRelativo(n.criadoEm), style: SisanTexto.legenda),
                    if (!n.lida) ...[
                      const SizedBox(width: 6),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
                    ],
                  ],
                ),
                const SizedBox(height: SisanEspaco.sm),
                Text(
                  n.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    color: SisanCores.texto,
                    fontWeight: n.lida ? FontWeight.w600 : FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(n.corpo, maxLines: 3, overflow: TextOverflow.ellipsis, style: SisanTexto.secundario),
                if (acao != null && n.dados != null) ...[
                  const SizedBox(height: SisanEspaco.sm),
                  Row(
                    children: [
                      Text(acao, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cor)),
                      Icon(Icons.chevron_right, size: 16, color: cor),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (IconData, Color, String, String?) _estilo(String tipo) => switch (tipo) {
        'nova_os' => (Icons.assignment_outlined, SisanCores.primaria, 'Nova OS', 'Abrir ordem de serviço'),
        'status_os' => (Icons.water_drop_outlined, SisanCores.sucesso, 'Atualização', 'Ver ocorrência'),
        'alerta_sanitario' => (Icons.health_and_safety_outlined, SisanCores.perigo, 'Alerta sanitário', 'Ver alerta'),
        _ => (Icons.notifications_outlined, SisanCores.neutro, 'Aviso', null),
      };
}
