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
import 'package:sisan/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:sisan/features/dashboard/presentation/widgets/tendencia_chart.dart';
import 'package:sisan/features/dashboard/services/pdf_relatorio.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Adaptado de `DashboardPage` do SIGAU (feature `dashboard`) — mesmos
/// blocos (KPIs, tendência, export PDF), simplificado pra um único layout
/// (o SISAN não tem uma variante desktop em nenhuma outra tela ainda) e
/// trocando o mapa de calor geográfico por [HeatmapTipoGrid].
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar relatório PDF',
            onPressed: () => _exportarPdf(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).recarregar(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiGrid(stats),
          const SizedBox(height: 16),
          TendenciaChart(serie: stats.serie),
          const SizedBox(height: 16),
          HeatmapTipoGrid(porTipo: stats.porTipo),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.health_and_safety_outlined, color: Color(0xFFC62828)),
              title: const Text('Alertas Sanitários'),
              subtitle: Text('${stats.alertasAtivos} ativo${stats.alertasAtivos == 1 ? '' : 's'} no município'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/alertas-sanitarios'),
            ),
          ),
          const SizedBox(height: 16),
          _UltimasOcorrenciasCard(ocorrencias: stats.ultimasOcorrencias),
          const SizedBox(height: 8),
        ],
      ),
    );
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

    Color comparacaoCor(num a, num b) => a > b ? const Color(0xFF2E7D32) : Colors.black38;

    final kpis = [
      KpiCard(
        titulo: 'Ocorrências no Mês',
        valor: atual.ocorrencias.toString(),
        icone: Icons.water_drop_outlined,
        cor: const Color(0xFF0288D1),
        comparacao: comparacao(atual.ocorrencias, anterior.ocorrencias),
        comparacaoCor: comparacaoCor(atual.ocorrencias, anterior.ocorrencias),
      ),
      KpiCard(
        titulo: 'Resolvidas no Mês',
        valor: atual.resolvidas.toString(),
        icone: Icons.check_circle_outline,
        cor: const Color(0xFF2E7D32),
        comparacao: comparacao(atual.resolvidas, anterior.resolvidas),
        comparacaoCor: comparacaoCor(atual.resolvidas, anterior.resolvidas),
      ),
      KpiCard(
        titulo: 'Tempo médio de resolução',
        valor: '${atual.tempoMedioHoras.toStringAsFixed(1)}h',
        icone: Icons.timer_outlined,
        cor: const Color(0xFFEF6C00),
        subtitulo: 'da criação até a conclusão da OS',
      ),
      KpiCard(
        titulo: 'Alertas Sanitários Ativos',
        valor: stats.alertasAtivos.toString(),
        icone: Icons.health_and_safety_outlined,
        cor: const Color(0xFFC62828),
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: kpis[0]), const SizedBox(width: 12), Expanded(child: kpis[1])],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: kpis[2]), const SizedBox(width: 12), Expanded(child: kpis[3])],
        ),
      ],
    );
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

      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/pdf')],
        subject: 'Relatório SISAN — ${DateFormat('dd/MM/yyyy').format(now)}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível gerar o relatório. Tente novamente.')),
        );
      }
    }
  }
}

class _UltimasOcorrenciasCard extends StatelessWidget {
  const _UltimasOcorrenciasCard({required this.ocorrencias});
  final List<Ocorrencia> ocorrencias;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.history_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Últimas Ocorrências', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
          if (ocorrencias.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text('Nenhuma ocorrência registrada ainda.', style: TextStyle(color: Colors.black38, fontSize: 13)),
            )
          else
            ...ocorrencias.map((o) => _OcorrenciaListTile(ocorrencia: o)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OcorrenciaListTile extends StatelessWidget {
  const _OcorrenciaListTile({required this.ocorrencia});
  final Ocorrencia ocorrencia;

  @override
  Widget build(BuildContext context) {
    final tipo = ocorrencia.tipo;
    final diff = DateTime.now().difference(ocorrencia.criadoEm);
    final tempo = diff.inMinutes < 1
        ? 'agora'
        : diff.inMinutes < 60
            ? 'há ${diff.inMinutes} min'
            : diff.inHours < 24
                ? 'há ${diff.inHours}h'
                : DateFormat('dd/MM HH:mm').format(ocorrencia.criadoEm);

    return InkWell(
      onTap: () => context.push('/ocorrencias/${ocorrencia.id}', extra: ocorrencia),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: tipo.cor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(tipo.icone, color: tipo.cor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tipo.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(ocorrencia.status.label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
                ],
              ),
            ),
            Text(tempo, style: const TextStyle(fontSize: 11, color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}
