import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/home/presentation/widgets/home_widgets.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/pages/ordens_servico_page.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/widgets/ordem_servico_card.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/shared/widgets/pending_sync_banner.dart';

/// Home do técnico: mesma casca do cidadão (bottom nav) com um painel
/// pessoal na aba Início — o que está com ele, o que é prioridade na fila,
/// onde a fila se concentra e o desempenho dos últimos 30 dias.
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
          pagina: _PainelTab(usuario: usuario, irPara: irPara),
        ),
        const HomeAba(
          label: 'Ordens',
          icone: Icons.assignment_outlined,
          iconeSelecionado: Icons.assignment,
          pagina: OrdensServicoPage(),
        ),
        const HomeAba(label: 'Mapa', icone: Icons.map_outlined, iconeSelecionado: Icons.map, pagina: MapaPage()),
        const HomeAba(
          label: 'Perfil',
          icone: Icons.person_outline,
          iconeSelecionado: Icons.person,
          pagina: PerfilTab(
            atalhos: [PerfilAtalho(icone: Icons.notifications_outlined, titulo: 'Notificações', rota: '/notificacoes')],
          ),
        ),
      ],
    );
  }
}

class _PainelTab extends ConsumerWidget {
  const _PainelTab({this.usuario, required this.irPara});

  final Usuario? usuario;
  final void Function(int) irPara;

  static const _dias = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

  /// Pontuação do banco (urgência + risco + confirmações + dias), depois urgência e antiguidade.
  List<OrdemServico> _porPrioridade(Iterable<OrdemServico> lista) {
    final copia = lista.toList();
    copia.sort((a, b) {
      final p = (b.ocorrencia.prioridade ?? 0).compareTo(a.ocorrencia.prioridade ?? 0);
      if (p != 0) return p;
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
    int porUrgencia(OcorrenciaUrgencia u) => livres.where((os) => os.ocorrencia.urgencia == u).length;
    final paradas = livres.where((os) => DateTime.now().difference(os.criadoEm).inHours >= 48).length;

    final porBairro = <String, int>{};
    for (final os in livres) {
      final b = os.ocorrencia.bairro;
      if (b != null) porBairro[b] = (porBairro[b] ?? 0) + 1;
    }
    final bairros = porBairro.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Desempenho
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
    final porDia = List<int>.filled(7, 0);
    for (final os in concluidas) {
      final c = os.concluidaEm!.toLocal();
      final d = hoje.difference(DateTime(c.year, c.month, c.day)).inDays;
      if (d >= 0 && d < 7) porDia[6 - d]++;
    }
    final semana = porDia.fold<int>(0, (a, b) => a + b);

    Widget listaOs(List<OrdemServico> lista) => Column(
      children: [
        for (final (i, os) in lista.indexed) ...[
          if (i > 0) const SizedBox(height: SisanEspaco.sm + 2),
          OrdemServicoCard(ordemServico: os, onTap: () => context.push('/ordens-de-servico/${os.id}')),
        ],
      ],
    );

    const lateral = EdgeInsets.symmetric(horizontal: SisanEspaco.tela);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(ordensServicoProvider.notifier).recarregar(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HomeHeader(
              usuario: usuario,
              subtitulo: 'Técnico de campo',
              onAvatarTap: () => irPara(3),
              rodape: StatStrip(
                itens: [
                  StatItem('${minhas.length}', 'Com você'),
                  StatItem('${livres.length}', 'Na fila', onTap: () => irPara(1)),
                  StatItem('${concluidas.length}', 'Concluídas\n(30 dias)'),
                ],
              ),
            ),
            const PendingSyncBanner(),
            if (filaState.isLoading && fila.isEmpty)
              const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: LinearProgressIndicator()),

            // ── Em andamento ──────────────────────────────────────────────
            const SectionHeader('Em andamento com você'),
            Padding(
              padding: lateral,
              child: minhas.isEmpty
                  ? const EmptyHint(
                      icone: Icons.inbox_outlined,
                      mensagem: 'Nenhuma OS com você agora. Aceite uma da fila abaixo.',
                      cor: SisanCores.neutro,
                    )
                  : listaOs(minhas),
            ),

            // ── Prioridade na fila ────────────────────────────────────────
            SectionHeader(
              'Prioridade na fila',
              subtitulo: 'Ordenada pela pontuação de risco sanitário',
              acaoLabel: livres.length > 3 ? 'Ver todas (${livres.length})' : null,
              onAcao: () => irPara(1),
            ),
            Padding(
              padding: lateral,
              child: Column(
                children: [
                  if (porUrgencia(OcorrenciaUrgencia.riscoSaude) > 0) ...[
                    AvisoBanner(
                      mensagem: '${porUrgencia(OcorrenciaUrgencia.riscoSaude)} com risco à saúde aguardando técnico',
                      cor: SisanCores.perigo,
                      icone: Icons.health_and_safety_outlined,
                      onTap: () => irPara(1),
                    ),
                    const SizedBox(height: SisanEspaco.sm + 2),
                  ],
                  livres.isEmpty
                      ? const EmptyHint(
                          icone: Icons.check_circle_outline,
                          mensagem: 'Fila zerada. Todas as ocorrências do município estão atendidas.',
                        )
                      : listaOs(livres.take(3).toList()),
                ],
              ),
            ),

            // ── Visão da fila ─────────────────────────────────────────────
            const SectionHeader('Visão da fila'),
            Padding(
              padding: lateral,
              child: Column(
                children: [
                  DistribuicaoCard(
                    titulo: 'Fila por urgência',
                    icone: Icons.stacked_bar_chart,
                    subtitulo: paradas > 0 ? '$paradas aguardando há mais de 48h' : 'Nenhuma OS parada há mais de 48h',
                    vazio: 'Nenhuma OS aguardando técnico.',
                    segmentos: [
                      for (final u in OcorrenciaUrgencia.values.reversed) Segmento(u.label, porUrgencia(u), u.cor),
                    ],
                  ),
                  const SizedBox(height: SisanEspaco.md),
                  RankingCard(
                    titulo: 'Bairros com mais OS abertas',
                    icone: Icons.place_outlined,
                    subtitulo: 'Ajuda a planejar a rota do dia',
                    itens: [for (final e in bairros.take(4)) (e.key, e.value)],
                  ),
                ],
              ),
            ),

            // ── Desempenho ────────────────────────────────────────────────
            const SectionHeader('Seu desempenho', subtitulo: 'Últimos 30 dias'),
            Padding(
              padding: lateral,
              child: Column(
                children: [
                  GradeDupla(
                    children: [
                      KpiTile(
                        titulo: 'Concluídas no mês',
                        valor: '$noMes',
                        icone: Icons.check_circle_outline,
                        cor: OrdemServicoStatus.concluida.cor,
                      ),
                      KpiTile(
                        titulo: 'Tempo médio de atendimento',
                        valor: duracoes.isEmpty ? '—' : '${mediaHoras.toStringAsFixed(1)}h',
                        icone: Icons.timer_outlined,
                        cor: SisanCores.atencao,
                        rodape: 'do aceite à conclusão',
                      ),
                    ],
                  ),
                  const SizedBox(height: SisanEspaco.md),
                  SisanCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bar_chart_rounded, size: 18, color: SisanCores.textoSecundario),
                            const SizedBox(width: SisanEspaco.sm),
                            const Expanded(child: Text('Concluídas nos últimos 7 dias', style: SisanTexto.tituloCard)),
                            Text('$semana', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: SisanEspaco.lg),
                        MiniBarChart(
                          valores: porDia,
                          rotulos: [
                            for (var i = 0; i < 7; i++)
                              i == 6 ? 'hoje' : _dias[hoje.subtract(Duration(days: 6 - i)).weekday - 1],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SisanEspaco.xl),
          ],
        ),
      ),
    );
  }
}
