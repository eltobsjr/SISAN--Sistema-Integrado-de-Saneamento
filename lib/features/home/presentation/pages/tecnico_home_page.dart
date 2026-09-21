import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:sisan/features/home/presentation/widgets/home_widgets.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/pages/ordens_servico_page.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/widgets/ordem_servico_card.dart';
import 'package:sisan/shared/widgets/pending_sync_banner.dart';

/// Home do técnico: mesma casca do cidadão (bottom nav) com um painel
/// pessoal na aba Início — o que está com ele, o que é prioridade na fila e
/// o desempenho dos últimos 30 dias.
class TecnicoHomePage extends ConsumerWidget {
  const TecnicoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;

    return HomeShell(
      abasBuilder: (irPara) => [
        HomeAba(
          label: 'Início',
          icone: Icons.space_dashboard_outlined,
          iconeSelecionado: Icons.space_dashboard,
          pagina: _PainelTab(
            usuario: usuario,
            onVerFila: () => irPara(1),
            onPerfilTap: () => irPara(3),
          ),
        ),
        const HomeAba(
          label: 'Ordens',
          icone: Icons.assignment_outlined,
          iconeSelecionado: Icons.assignment,
          pagina: OrdensServicoPage(),
        ),
        const HomeAba(
          label: 'Mapa',
          icone: Icons.map_outlined,
          iconeSelecionado: Icons.map,
          pagina: MapaPage(),
        ),
        const HomeAba(
          label: 'Perfil',
          icone: Icons.person_outline,
          iconeSelecionado: Icons.person,
          pagina: PerfilTab(
            atalhos: [
              PerfilAtalho(icone: Icons.notifications_outlined, titulo: 'Notificações', rota: '/notificacoes'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PainelTab extends ConsumerWidget {
  const _PainelTab({this.usuario, required this.onVerFila, this.onPerfilTap});

  final Usuario? usuario;
  final VoidCallback onVerFila;
  final VoidCallback? onPerfilTap;

  List<OrdemServico> _porPrioridade(Iterable<OrdemServico> lista) {
    final copia = lista.toList();
    copia.sort((a, b) {
      final u = b.ocorrencia.urgencia.index.compareTo(a.ocorrencia.urgencia.index);
      return u != 0 ? u : a.criadoEm.compareTo(b.criadoEm);
    });
    return copia;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filaState = ref.watch(ordensServicoProvider);
    final fila = filaState.valueOrNull ?? const <OrdemServico>[];
    final concluidas = ref.watch(minhasConcluidasProvider).valueOrNull ?? const <OrdemServico>[];

    final minhas = fila.where((os) => os.tecnicoId == usuario?.id).toList();
    final livres = _porPrioridade(fila.where((os) => os.tecnicoId == null));
    final riscoNaFila = livres.where((os) => os.ocorrencia.urgencia == OcorrenciaUrgencia.riscoSaude).length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(ordensServicoProvider.notifier).recarregar(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  usuario: usuario,
                  subtitulo: 'Técnico de campo',
                  onAvatarTap: onPerfilTap,
                  rodape: HeaderResumo(
                    itens: [
                      ('${minhas.length}', 'Com você'),
                      ('${livres.length}', 'Na fila'),
                      ('${concluidas.length}', 'Concluídas\n(30 dias)'),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: PendingSyncBanner()),
              if (filaState.isLoading && fila.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: LinearProgressIndicator(),
                  ),
                ),

              // ── Em andamento ────────────────────────────────────────────
              const SliverToBoxAdapter(child: SecaoTitulo('Em andamento com você')),
              if (minhas.isEmpty)
                const SliverToBoxAdapter(
                  child: SecaoVazia(
                    icone: Icons.inbox_outlined,
                    mensagem: 'Nenhuma OS com você agora. Aceite uma da fila abaixo.',
                    cor: Colors.blueGrey,
                  ),
                )
              else
                _listaOs(context, minhas),

              // ── Prioridade na fila ──────────────────────────────────────
              SliverToBoxAdapter(
                child: SecaoTitulo(
                  'Prioridade na fila',
                  acaoLabel: livres.length > 3 ? 'Ver todas (${livres.length})' : null,
                  onAcao: onVerFila,
                ),
              ),
              if (riscoNaFila > 0)
                SliverToBoxAdapter(child: _AvisoRisco(quantidade: riscoNaFila)),
              if (livres.isEmpty)
                const SliverToBoxAdapter(
                  child: SecaoVazia(
                    icone: Icons.check_circle_outline,
                    mensagem: 'Fila zerada. Todas as ocorrências do município estão atendidas.',
                  ),
                )
              else
                _listaOs(context, livres.take(3).toList()),

              // ── Desempenho ──────────────────────────────────────────────
              const SliverToBoxAdapter(child: SecaoTitulo('Seu desempenho')),
              SliverToBoxAdapter(child: _Desempenho(concluidas: concluidas)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaOs(BuildContext context, List<OrdemServico> lista) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: lista.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => OrdemServicoCard(
          ordemServico: lista[i],
          onTap: () => context.push('/ordens-de-servico/${lista[i].id}'),
        ),
      ),
    );
  }
}

class _AvisoRisco extends StatelessWidget {
  const _AvisoRisco({required this.quantidade});
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final cor = OcorrenciaUrgencia.riscoSaude.cor;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety_outlined, color: cor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$quantidade ocorrência${quantidade == 1 ? '' : 's'} com risco à saúde aguardando técnico',
              style: TextStyle(color: cor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// KPIs pessoais + barras dos últimos 7 dias.
class _Desempenho extends StatelessWidget {
  const _Desempenho({required this.concluidas});
  final List<OrdemServico> concluidas;

  static const _dias = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    final duracoes = concluidas
        .where((os) => os.aceitaEm != null && os.concluidaEm != null)
        .map((os) => os.concluidaEm!.difference(os.aceitaEm!).inMinutes)
        .toList();
    final mediaHoras = duracoes.isEmpty ? 0.0 : duracoes.reduce((a, b) => a + b) / duracoes.length / 60;
    final noMes = concluidas.where((os) {
      final c = os.concluidaEm!.toLocal();
      return c.year == agora.year && c.month == agora.month;
    }).length;

    // Concluídas por dia, dos 6 dias atrás até hoje.
    final porDia = List<int>.filled(7, 0);
    for (final os in concluidas) {
      final c = os.concluidaEm!.toLocal();
      final d = hoje.difference(DateTime(c.year, c.month, c.day)).inDays;
      if (d >= 0 && d < 7) porDia[6 - d]++;
    }
    final maximo = porDia.fold<int>(0, (a, b) => a > b ? a : b);
    final semana = porDia.fold<int>(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KpiCard(
                  titulo: 'Concluídas no mês',
                  valor: '$noMes',
                  icone: Icons.check_circle_outline,
                  cor: OrdemServicoStatus.concluida.cor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  titulo: 'Tempo médio de atendimento',
                  valor: duracoes.isEmpty ? '—' : '${mediaHoras.toStringAsFixed(1)}h',
                  icone: Icons.timer_outlined,
                  cor: const Color(0xFFEF6C00),
                  subtitulo: 'do aceite à conclusão',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Últimos 7 dias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      Text(
                        '$semana concluída${semana == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: _Barra(
                              valor: porDia[i],
                              fracao: maximo == 0 ? 0 : porDia[i] / maximo,
                              rotulo: i == 6
                                  ? 'hoje'
                                  : _dias[hoje.subtract(Duration(days: 6 - i)).weekday - 1],
                              destaque: i == 6,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.valor, required this.fracao, required this.rotulo, this.destaque = false});

  final int valor;
  final double fracao;
  final String rotulo;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (valor > 0)
          Text('$valor', style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Container(
          width: 18,
          height: 4 + 56 * fracao,
          decoration: BoxDecoration(
            color: destaque ? primary : primary.withValues(alpha: valor > 0 ? 0.45 : 0.12),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          rotulo,
          style: TextStyle(
            fontSize: 10,
            color: destaque ? primary : Colors.black45,
            fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
