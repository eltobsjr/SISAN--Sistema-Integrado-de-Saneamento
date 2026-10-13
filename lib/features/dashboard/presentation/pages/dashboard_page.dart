import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sisan/features/dashboard/presentation/widgets/heatmap_tipo_grid.dart';
import 'package:sisan/features/dashboard/presentation/widgets/insight_card.dart';
import 'package:sisan/features/dashboard/presentation/widgets/tendencia_chart.dart';
import 'package:sisan/features/dashboard/services/pdf_relatorio.dart';
import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/features/ocorrencias/presentation/widgets/ocorrencia_card.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Adaptado de `DashboardPage` do SIGAU (feature `dashboard`) — mesmos
/// blocos (KPIs, tendência, export PDF), simplificado pra um único layout
/// (o SISAN não tem uma variante desktop em nenhuma outra tela ainda) e
/// trocando o mapa de calor geográfico por [HeatmapTipoGrid].
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const _meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: SisanAppBar(
        title: const Text('Painel do município'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar relatório PDF',
            onPressed: () => _exportarPdf(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(insightDashboardProvider);
              ref.invalidate(prioridadesAbertasProvider);
              ref.read(dashboardProvider.notifier).recarregar();
            },
          ),
        ],
      ),
      body: statsState.when(
        loading: () => const Center(child: SisanLoading.compact()),
        error: (_, _) => SisanErrorState(onRetry: () => ref.read(dashboardProvider.notifier).recarregar()),
        data: (stats) => _buildContent(context, ref, stats),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, DashboardStats stats) {
    int status(OcorrenciaStatus s) => stats.porStatus[s.dbValue] ?? 0;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(insightDashboardProvider);
        ref.invalidate(prioridadesAbertasProvider);
        await ref.read(dashboardProvider.notifier).recarregar();
      },
      child: ListView(
        padding: const EdgeInsets.all(SisanEspaco.tela),
        children: [
          const InsightCard(),
          if (stats.alertasAtivos > 0) ...[
            AvisoBanner(
              mensagem:
                  '${stats.alertasAtivos} alerta${stats.alertasAtivos == 1 ? '' : 's'} sanitário${stats.alertasAtivos == 1 ? '' : 's'} ativo${stats.alertasAtivos == 1 ? '' : 's'} no município',
              cor: SisanCores.perigo,
              icone: Icons.health_and_safety_outlined,
              onTap: () => context.push('/alertas-sanitarios'),
            ),
            const SizedBox(height: SisanEspaco.lg),
          ],
          ..._prioridades(ref.watch(prioridadesAbertasProvider).valueOrNull ?? const []),
          const SectionHeader('Indicadores do mês', padding: EdgeInsets.only(bottom: SisanEspaco.sm)),
          _buildKpiGrid(stats),
          const SizedBox(height: SisanEspaco.md),
          DistribuicaoCard(
            titulo: 'Situação das ocorrências do mês',
            icone: Icons.donut_large_outlined,
            segmentos: [for (final s in OcorrenciaStatus.values) Segmento(s.label, status(s), s.cor)],
          ),
          const SectionHeader(
            'Evolução',
            padding: EdgeInsets.only(top: SisanEspaco.xl, bottom: SisanEspaco.sm),
          ),
          TendenciaChart(serie: stats.serie),
          const SizedBox(height: SisanEspaco.md),
          HeatmapTipoGrid(porTipo: stats.porTipo),
          SectionHeader(
            'Últimas ocorrências',
            padding: const EdgeInsets.only(top: SisanEspaco.xl, bottom: SisanEspaco.sm),
          ),
          if (stats.ultimasOcorrencias.isEmpty)
            const EmptyHint(
              icone: Icons.inbox_outlined,
              mensagem: 'Nenhuma ocorrência registrada ainda.',
              cor: SisanCores.neutro,
            )
          else
            for (final (i, o) in stats.ultimasOcorrencias.indexed) ...[
              if (i > 0) const SizedBox(height: SisanEspaco.sm),
              OcorrenciaCard(ocorrencia: o, compacto: true),
            ],
          const SizedBox(height: SisanEspaco.lg),
        ],
      ),
    );
  }

  /// "O que atacar hoje": abertas do município inteiro pela pontuação do
  /// banco (urgência + nível de risco + confirmações + dias em aberto).
  List<Widget> _prioridades(List<Ocorrencia> abertas) {
    if (abertas.isEmpty) return const [];
    return [
      SectionHeader(
        'Prioridades de hoje',
        subtitulo: 'Abertas com maior risco sanitário, pela pontuação de prioridade',
        padding: const EdgeInsets.only(bottom: SisanEspaco.sm),
      ),
      for (final (i, o) in abertas.take(3).indexed) ...[
        if (i > 0) const SizedBox(height: SisanEspaco.sm),
        OcorrenciaCard(ocorrencia: o, compacto: true),
      ],
      const SizedBox(height: SisanEspaco.lg),
    ];
  }

  Widget _buildKpiGrid(DashboardStats stats) {
    final agora = DateTime.now();
    final mesAnteriorLabel = _meses[(agora.month - 2 + 12) % 12];
    final atual = stats.mesAtual;
    final anterior = stats.mesAnterior;

    String comparacao(num a, num b) {
      final d = a - b;
      if (d > 0) return '+${d.toStringAsFixed(d == d.roundToDouble() ? 0 : 1)} vs. $mesAnteriorLabel';
      if (d < 0) return '${d.toStringAsFixed(d == d.roundToDouble() ? 0 : 1)} vs. $mesAnteriorLabel';
      return '= $mesAnteriorLabel';
    }

    Color comparacaoCor(num a, num b) => a > b ? SisanCores.sucesso : SisanCores.textoTerciario;

    final kpis = [
      KpiTile(
        titulo: 'Ocorrências no Mês',
        valor: atual.ocorrencias.toString(),
        icone: Icons.water_drop_outlined,
        cor: SisanCores.primaria,
        rodape: comparacao(atual.ocorrencias, anterior.ocorrencias),
        corRodape: comparacaoCor(atual.ocorrencias, anterior.ocorrencias),
      ),
      KpiTile(
        titulo: 'Resolvidas no Mês',
        valor: atual.resolvidas.toString(),
        icone: Icons.check_circle_outline,
        cor: SisanCores.sucesso,
        rodape: comparacao(atual.resolvidas, anterior.resolvidas),
        corRodape: comparacaoCor(atual.resolvidas, anterior.resolvidas),
      ),
      KpiTile(
        titulo: 'Tempo médio de resolução',
        valor: '${atual.tempoMedioHoras.toStringAsFixed(1)}h',
        icone: Icons.timer_outlined,
        cor: SisanCores.atencao,
        rodape: 'da criação à conclusão da OS',
      ),
      KpiTile(
        titulo: 'Alertas Sanitários Ativos',
        valor: stats.alertasAtivos.toString(),
        icone: Icons.health_and_safety_outlined,
        cor: SisanCores.perigo,
      ),
    ];

    return GradeDupla(children: kpis);
  }

  Future<void> _exportarPdf(BuildContext context, WidgetRef ref) async {
    final stats = ref.read(dashboardProvider).valueOrNull;
    if (stats == null) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export não disponível no web.')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Gerando relatório PDF...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final usuario = ref.read(authProvider).valueOrNull;
      final municipioId = usuario?.municipioId ?? '';

      var municipioNome = '';
      if (municipioId.isNotEmpty) {
        final m = await supabase.from('municipios').select('nome, estado').eq('id', municipioId).maybeSingle();
        if (m != null) municipioNome = '${m['nome'] ?? ''} — ${m['estado'] ?? ''}'.trim();
      }

      final pdfBytes = await gerarRelatorioPdf(stats: stats, municipioNome: municipioNome);

      final now = DateTime.now();
      final nomeArquivo = 'sisan_relatorio_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$nomeArquivo';
      await File(path).writeAsBytes(pdfBytes);

      if (municipioId.isNotEmpty) {
        try {
          await supabase.storage.from('relatorios').uploadBinary('$municipioId/$nomeArquivo', pdfBytes);
        } catch (_) {
          // Upload falhou — arquivo continua disponível localmente pro compartilhamento.
        }
      }

      if (context.mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

      await Share.shareXFiles([
        XFile(path, mimeType: 'application/pdf'),
      ], subject: 'Relatório SISAN — ${DateFormat('dd/MM/yyyy').format(now)}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Não foi possível gerar o relatório. Tente novamente.')));
      }
    }
  }
}
