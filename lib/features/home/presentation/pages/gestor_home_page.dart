import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/providers/alertas_sanitarios_provider.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sisan/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sisan/features/dashboard/presentation/widgets/insight_card.dart';
import 'package:sisan/features/home/presentation/widgets/home_widgets.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/pages/ordens_servico_page.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/widgets/ordem_servico_card.dart';

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
    final emCampo = fila.where((os) => os.tecnicoId != null).length;
    final criticas = semTecnico.where((os) => os.ocorrencia.urgencia == OcorrenciaUrgencia.riscoSaude).toList()
      ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(insightDashboardProvider);
            await Future.wait([
              ref.read(dashboardProvider.notifier).recarregar(),
              ref.read(ordensServicoProvider.notifier).recarregar(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  usuario: usuario,
                  subtitulo: 'Gestão de saneamento do município',
                  onAvatarTap: () => irPara(_abaPerfil),
                  rodape: HeaderResumo(
                    itens: [
                      (stats == null ? '—' : '${stats.mesAtual.ocorrencias}', 'Ocorrências\nno mês'),
                      ('${semTecnico.length}', 'Aguardando\ntécnico'),
                      ('$emCampo', 'Em\natendimento'),
                    ],
                  ),
                ),
              ),

              // ── Resumo da IA ────────────────────────────────────────────
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(child: InsightCard()),
              ),

              // ── Precisa de atenção ──────────────────────────────────────
              SliverToBoxAdapter(
                child: SecaoTitulo(
                  'Risco à saúde sem técnico',
                  acaoLabel: criticas.length > 3 ? 'Ver fila' : null,
                  onAcao: () => irPara(_abaOrdens),
                ),
              ),
              if (criticas.isEmpty)
                const SliverToBoxAdapter(
                  child: SecaoVazia(
                    icone: Icons.verified_outlined,
                    mensagem: 'Nenhuma ocorrência com risco à saúde aguardando atendimento.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: criticas.length > 3 ? 3 : criticas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => OrdemServicoCard(
                      ordemServico: criticas[i],
                      onTap: () => context.push('/ordens-de-servico/${criticas[i].id}'),
                    ),
                  ),
                ),

              // ── Gestão ──────────────────────────────────────────────────
              const SliverToBoxAdapter(child: SecaoTitulo('Gestão')),
              AcoesGrid(
                children: [
                  AcaoCard(
                    titulo: 'Painel',
                    subtitulo: 'KPIs, tendência e relatório PDF',
                    icone: Icons.insights_outlined,
                    cor: Theme.of(context).colorScheme.primary,
                    onTap: () => irPara(_abaPainel),
                  ),
                  AcaoCard(
                    titulo: 'Alertas Sanitários',
                    subtitulo: alertasAtivos > 0
                        ? '$alertasAtivos ativo${alertasAtivos == 1 ? '' : 's'} no município'
                        : 'Criar e encerrar alertas',
                    icone: Icons.health_and_safety_outlined,
                    cor: const Color(0xFFC62828),
                    badge: alertasAtivos,
                    onTap: () => context.push('/alertas-sanitarios'),
                  ),
                  AcaoCard(
                    titulo: 'Ordens de Serviço',
                    subtitulo: 'Acompanhe a fila do município',
                    icone: Icons.assignment_outlined,
                    cor: const Color(0xFFEF6C00),
                    badge: semTecnico.length,
                    onTap: () => irPara(_abaOrdens),
                  ),
                  AcaoCard(
                    titulo: 'Mapa',
                    subtitulo: 'Ocorrências por localização',
                    icone: Icons.map_outlined,
                    cor: const Color(0xFF00796B),
                    onTap: () => irPara(_abaMapa),
                  ),
                  AcaoCard(
                    titulo: 'Meu município',
                    subtitulo: 'Equipe e código de ativação',
                    icone: Icons.location_city_outlined,
                    cor: const Color(0xFF5E35B1),
                    onTap: () => context.push('/meu-municipio'),
                  ),
                  AcaoCard(
                    titulo: 'Novo alerta',
                    subtitulo: 'Avisar a população de um risco',
                    icone: Icons.campaign_outlined,
                    cor: const Color(0xFFAD1457),
                    onTap: () => context.push('/alertas-sanitarios/criar'),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
