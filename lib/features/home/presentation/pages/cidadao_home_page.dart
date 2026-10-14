import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/home/presentation/widgets/home_widgets.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/mapa/presentation/providers/mapa_provider.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/features/ocorrencias/presentation/widgets/ocorrencia_card.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Home do cidadão — adaptada do `HomePage` do SIGAU: bottom nav de 4 abas
/// (Início/Mapa/Registrar/Perfil). O Início é um painel: o que ele
/// registrou e ainda está em andamento, e como está o município no mês.
class CidadaoHomePage extends ConsumerWidget {
  const CidadaoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;

    return HomeShell(
      abasBuilder: (irPara) => [
        HomeAba(
          label: 'Início',
          icone: Icons.home_outlined,
          iconeSelecionado: Icons.home,
          pagina: _InicioTab(usuario: usuario, irPara: irPara),
        ),
        const HomeAba(
          label: 'Mapa',
          icone: Icons.map_outlined,
          iconeSelecionado: Icons.map,
          pagina: MapaPage(),
        ),
        const HomeAba(
          label: 'Registrar',
          icone: Icons.add_circle_outline,
          iconeSelecionado: Icons.add_circle,
          pagina: _RegistrarTab(),
        ),
        const HomeAba(
          label: 'Perfil',
          icone: Icons.person_outline,
          iconeSelecionado: Icons.person,
          pagina: PerfilTab(
            atalhos: [
              PerfilAtalho(icone: Icons.history_outlined, titulo: 'Minhas ocorrências', rota: '/ocorrencias'),
              PerfilAtalho(icone: Icons.notifications_outlined, titulo: 'Notificações', rota: '/notificacoes'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── ABA INÍCIO ───────────────────────────────────────────────────────────

class _InicioTab extends ConsumerWidget {
  const _InicioTab({this.usuario, required this.irPara});
  final Usuario? usuario;
  final void Function(int) irPara;

  static bool _emAndamento(Ocorrencia o) =>
      o.status == OcorrenciaStatus.pendente || o.status == OcorrenciaStatus.emAnalise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minhasState = ref.watch(ocorrenciasProvider);
    final minhas = minhasState.valueOrNull ?? const <Ocorrencia>[];
    final municipio = ref.watch(mapaProvider).ocorrencias;

    final andamento = minhas.where(_emAndamento).toList();
    final resolvidas = minhas.where((o) => o.status == OcorrenciaStatus.resolvida).length;

    final agora = DateTime.now();
    final doMes = municipio.where((o) => o.criadoEm.year == agora.year && o.criadoEm.month == agora.month).toList();
    int contar(OcorrenciaStatus s) => doMes.where((o) => o.status == s).length;
    final porTipo = <OcorrenciaTipo, int>{};
    for (final o in doMes) {
      porTipo[o.tipo] = (porTipo[o.tipo] ?? 0) + 1;
    }
    final rankingTipos = porTipo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ocorrenciasProvider);
          await ref.read(mapaProvider.notifier).recarregar();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HomeHeader(
              usuario: usuario,
              subtitulo: 'Como podemos ajudar hoje?',
              onAvatarTap: () => irPara(3),
              rodape: StatStrip(
                itens: [
                  StatItem('${minhas.length}', 'Registradas'),
                  StatItem('${andamento.length}', 'Em\nandamento'),
                  StatItem('$resolvidas', 'Resolvidas'),
                ],
              ),
            ),
            const SectionHeader('O que deseja fazer?'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SisanEspaco.tela),
              child: GradeDupla(
                children: [
                  ActionTile(
                    titulo: 'Nova ocorrência',
                    subtitulo: 'Foto, GPS e descrição do problema',
                    icone: Icons.add_location_alt_outlined,
                    cor: SisanCores.primaria,
                    onTap: () => context.push('/ocorrencias/nova'),
                  ),
                  ActionTile(
                    titulo: 'Minhas ocorrências',
                    subtitulo: 'Histórico e status dos registros',
                    icone: Icons.history_rounded,
                    cor: SisanCores.teal,
                    onTap: () => context.push('/ocorrencias'),
                  ),
                ],
              ),
            ),
            SectionHeader(
              'Acompanhe seus registros',
              subtitulo: 'Ocorrências ainda em andamento',
              acaoLabel: minhas.isEmpty ? null : 'Ver todas',
              onAcao: () => context.push('/ocorrencias'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SisanEspaco.tela),
              child: minhasState.isLoading && minhas.isEmpty
                  ? const LinearProgressIndicator()
                  : minhasState.hasError && minhas.isEmpty
                  ? const AvisoBanner(
                      mensagem: 'Não foi possível carregar seus registros. Verifique a conexão e puxe a tela para atualizar.',
                      cor: SisanCores.atencao,
                      icone: Icons.cloud_off_outlined,
                    )
                  : andamento.isEmpty
                      ? EmptyHint(
                          icone: minhas.isEmpty ? Icons.water_drop_outlined : Icons.verified_outlined,
                          cor: minhas.isEmpty ? SisanCores.primaria : SisanCores.sucesso,
                          mensagem: minhas.isEmpty
                              ? 'Você ainda não registrou nenhuma ocorrência. Viu um problema? Registre em menos de 1 minuto.'
                              : 'Nenhuma ocorrência sua em aberto. Obrigado por ajudar o município!',
                        )
                      : Column(
                          children: [
                            for (final (i, o) in andamento.take(3).indexed) ...[
                              if (i > 0) const SizedBox(height: SisanEspaco.sm + 2),
                              OcorrenciaCard(
                                ocorrencia: o,
                                aguardandoSync: o.protocolo == kProtocoloOffline,
                              ),
                            ],
                          ],
                        ),
            ),
            const SectionHeader('Seu município este mês', subtitulo: 'Todas as ocorrências registradas pela população'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SisanEspaco.tela),
              child: Column(
                children: [
                  DistribuicaoCard(
                    titulo: 'Situação das ocorrências',
                    icone: Icons.donut_large_outlined,
                    segmentos: [
                      Segmento('Resolvidas', contar(OcorrenciaStatus.resolvida), OcorrenciaStatus.resolvida.cor),
                      Segmento('Em análise', contar(OcorrenciaStatus.emAnalise), OcorrenciaStatus.emAnalise.cor),
                      Segmento('Pendentes', contar(OcorrenciaStatus.pendente), OcorrenciaStatus.pendente.cor),
                    ],
                  ),
                  const SizedBox(height: SisanEspaco.md),
                  RankingCard(
                    titulo: 'Problemas mais registrados',
                    icone: Icons.leaderboard_outlined,
                    itens: [for (final e in rankingTipos.take(4)) (e.key.label, e.value)],
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

// ─── ABA REGISTRAR ────────────────────────────────────────────────────────

class _RegistrarTab extends StatelessWidget {
  const _RegistrarTab();

  static const _passos = [
    (Icons.category_outlined, 'Escolha o tipo do problema'),
    (Icons.photo_camera_outlined, 'Tire uma foto (opcional)'),
    (Icons.my_location, 'Confirme a localização'),
    (Icons.send_outlined, 'Envie — funciona mesmo sem internet'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisanAppBar(title: Text('Registrar ocorrência')),
      body: ListView(
        padding: const EdgeInsets.all(SisanEspaco.tela),
        children: [
          SisanCard(
            padding: const EdgeInsets.all(SisanEspaco.xl),
            child: Column(
              children: [
                const IconTile(Icons.water_drop_outlined, cor: SisanCores.primaria, tamanho: 72),
                const SizedBox(height: SisanEspaco.lg),
                const Text(
                  'Viu um problema de água ou esgoto?',
                  textAlign: TextAlign.center,
                  style: SisanTexto.tituloTela,
                ),
                const SizedBox(height: SisanEspaco.sm),
                const Text(
                  'Seu registro vai direto para a concessionária, que abre uma ordem de serviço e acompanha até resolver.',
                  textAlign: TextAlign.center,
                  style: SisanTexto.secundario,
                ),
                const SizedBox(height: SisanEspaco.xl),
                FilledButton.icon(
                  onPressed: () => context.push('/ocorrencias/nova'),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Iniciar registro'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ],
            ),
          ),
          const SectionHeader('Como funciona', padding: EdgeInsets.fromLTRB(0, SisanEspaco.xl, 0, SisanEspaco.sm)),
          SisanCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, (icone, texto)) in _passos.indexed) ...[
                  if (i > 0) const Divider(indent: 64),
                  ListTile(
                    leading: IconTile(icone, cor: SisanCores.primaria, tamanho: 36),
                    title: Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: Text('${i + 1}', style: SisanTexto.rotulo),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
