import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/providers/alertas_sanitarios_provider.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sisan/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sisan/features/dashboard/presentation/widgets/insight_card.dart';
import 'package:sisan/features/home/presentation/widgets/home_widgets.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/pages/ordens_servico_page.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/widgets/ordem_servico_card.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Home do gestor — adaptada da `_buildGestorView` do `HomePage` do SIGAU:
/// mesma casca com bottom nav do cidadão; o Início prioriza o que precisa
/// de decisão (risco à saúde sem técnico) e o resumo da IA, e o Painel
/// completo (KPIs, tendência, PDF) fica numa aba própria.
class GestorHomePage extends ConsumerWidget {
  const GestorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;

    return HomeShell(
      abasBuilder: (irPara) => [
        HomeAba(
          label: 'Início',
          icone: Icons.home_outlined,
          iconeSelecionado: Icons.home,
          pagina: _InicioTab(
            usuario: usuario,
            irPara: irPara,
          ),
        ),
        const HomeAba(
          label: 'Painel',
          icone: Icons.insights_outlined,
          iconeSelecionado: Icons.insights,
          pagina: DashboardPage(),
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
              PerfilAtalho(icone: Icons.location_city_outlined, titulo: 'Meu município', rota: '/meu-municipio'),
              PerfilAtalho(
                icone: Icons.health_and_safety_outlined,
                titulo: 'Alertas sanitários',
                rota: '/alertas-sanitarios',
              ),
              PerfilAtalho(icone: Icons.notifications_outlined, titulo: 'Notificações', rota: '/notificacoes'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InicioTab extends ConsumerWidget {
  const _InicioTab({this.usuario, required this.irPara});

  final Usuario? usuario;
  final void Function(int) irPara;

  static const _abaPainel = 1;
  static const _abaOrdens = 2;
  static const _abaMapa = 3;
  static const _abaPerfil = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardProvider).valueOrNull;
    final fila = ref.watch(ordensServicoProvider).valueOrNull ?? const <OrdemServico>[];
    final alertas = ref.watch(alertasSanitariosProvider).valueOrNull ?? const [];
    final alertasAtivos = alertas.where((a) => a.ativo).length;

    final semTecnico = fila.where((os) => os.tecnicoId == null).toList();
    int porStatus(OrdemServicoStatus s) => fila.where((os) => os.status == s).length;
    int porUrgencia(OcorrenciaUrgencia u) => fila.where((os) => os.ocorrencia.urgencia == u).length;
    final paradas = semTecnico.where((os) => DateTime.now().difference(os.criadoEm).inHours >= 48).length;
    final criticas = semTecnico.where((os) => os.ocorrencia.urgencia == OcorrenciaUrgencia.riscoSaude).toList()
      ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));

    final porBairro = <String, int>{};
    for (final os in fila) {
      final b = os.ocorrencia.bairro;
      if (b != null) porBairro[b] = (porBairro[b] ?? 0) + 1;
    }
    final bairros = porBairro.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    const lateral = EdgeInsets.symmetric(horizontal: SisanEspaco.tela);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(insightDashboardProvider);
          await Future.wait([
            ref.read(dashboardProvider.notifier).recarregar(),
            ref.read(ordensServicoProvider.notifier).recarregar(),
          ]);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HomeHeader(
              usuario: usuario,
              subtitulo: 'Gestão de saneamento do município',
              onAvatarTap: () => irPara(_abaPerfil),
              rodape: StatStrip(
                itens: [
                  StatItem(stats == null ? '—' : '${stats.mesAtual.ocorrencias}', 'Ocorrências\nno mês', onTap: () => irPara(_abaPainel)),
                  StatItem('${semTecnico.length}', 'Aguardando\ntécnico', onTap: () => irPara(_abaOrdens)),
                  StatItem('$alertasAtivos', 'Alertas\nativos', onTap: () => context.push('/alertas-sanitarios')),
                ],
              ),
            ),

            // ── Resumo da IA ──────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(SisanEspaco.tela, SisanEspaco.xl, SisanEspaco.tela, 0),
              child: InsightCard(),
            ),

            // ── Precisa de decisão ────────────────────────────────────────
            SectionHeader(
              'Precisa da sua atenção',
              subtitulo: 'Risco à saúde sem técnico designado',
              acaoLabel: criticas.length > 3 ? 'Ver fila' : null,
              onAcao: () => irPara(_abaOrdens),
            ),
            Padding(
              padding: lateral,
              child: Column(
                children: [
                  if (paradas > 0) ...[
                    AvisoBanner(
                      mensagem: '$paradas OS aguardando técnico há mais de 48h',
                      cor: SisanCores.atencao,
                      icone: Icons.schedule,
                      onTap: () => irPara(_abaOrdens),
                    ),
                    const SizedBox(height: SisanEspaco.sm + 2),
                  ],
                  if (criticas.isEmpty)
                    const EmptyHint(
                      icone: Icons.verified_outlined,
                      mensagem: 'Nenhuma ocorrência com risco à saúde aguardando atendimento.',
                    )
                  else
                    for (final (i, os) in criticas.take(3).indexed) ...[
                      if (i > 0) const SizedBox(height: SisanEspaco.sm + 2),
                      OrdemServicoCard(ordemServico: os, onTap: () => context.push('/ordens-de-servico/${os.id}')),
                    ],
                ],
              ),
            ),

            // ── Operação ──────────────────────────────────────────────────
            const SectionHeader('Operação agora', subtitulo: 'Ordens de serviço abertas no município'),
            Padding(
              padding: lateral,
              child: Column(
                children: [
                  DistribuicaoCard(
                    titulo: 'Funil de atendimento',
                    icone: Icons.filter_alt_outlined,
                    vazio: 'Nenhuma OS aberta.',
                    segmentos: [
                      for (final s in [OrdemServicoStatus.pendente, OrdemServicoStatus.aceita, OrdemServicoStatus.aCaminho])
                        Segmento(s.label, porStatus(s), s.cor),
                    ],
                  ),
                  const SizedBox(height: SisanEspaco.md),
                  DistribuicaoCard(
                    titulo: 'Abertas por urgência',
                    icone: Icons.stacked_bar_chart,
                    vazio: 'Nenhuma OS aberta.',
                    segmentos: [
                      for (final u in OcorrenciaUrgencia.values.reversed) Segmento(u.label, porUrgencia(u), u.cor),
                    ],
                  ),
                  const SizedBox(height: SisanEspaco.md),
                  RankingCard(
                    titulo: 'Bairros mais afetados',
                    icone: Icons.place_outlined,
                    subtitulo: 'OS abertas por bairro',
                    cor: SisanCores.perigo,
                    itens: [for (final e in bairros.take(5)) (e.key, e.value)],
                  ),
                ],
              ),
            ),

            // ── Gestão ────────────────────────────────────────────────────
            const SectionHeader('Gestão'),
            Padding(
              padding: lateral,
              child: GradeDupla(
                children: [
                  ActionTile(
                    titulo: 'Painel completo',
                    subtitulo: 'KPIs, tendência e relatório PDF',
                    icone: Icons.insights_outlined,
                    cor: SisanCores.primaria,
                    onTap: () => irPara(_abaPainel),
                  ),
                  ActionTile(
                    titulo: 'Alertas sanitários',
                    subtitulo: alertasAtivos > 0
                        ? '$alertasAtivos ativo${alertasAtivos == 1 ? '' : 's'} no município'
                        : 'Criar e encerrar alertas',
                    icone: Icons.health_and_safety_outlined,
                    cor: SisanCores.perigo,
                    badge: alertasAtivos,
                    onTap: () => context.push('/alertas-sanitarios'),
                  ),
                  ActionTile(
                    titulo: 'Novo alerta',
                    subtitulo: 'Avisar a população de um risco',
                    icone: Icons.campaign_outlined,
                    cor: SisanCores.rosa,
                    onTap: () => context.push('/alertas-sanitarios/criar'),
                  ),
                  ActionTile(
                    titulo: 'Mapa',
                    subtitulo: 'Ocorrências por localização',
                    icone: Icons.map_outlined,
                    cor: SisanCores.teal,
                    onTap: () => irPara(_abaMapa),
                  ),
                  ActionTile(
                    titulo: 'Meu município',
                    subtitulo: 'Equipe e código de ativação',
                    icone: Icons.location_city_outlined,
                    cor: SisanCores.indigo,
                    onTap: () => context.push('/meu-municipio'),
                  ),
                  ActionTile(
                    titulo: 'Ordens de serviço',
                    subtitulo: 'Fila completa do município',
                    icone: Icons.assignment_outlined,
                    cor: SisanCores.atencao,
                    badge: semTecnico.length,
                    onTap: () => irPara(_abaOrdens),
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
