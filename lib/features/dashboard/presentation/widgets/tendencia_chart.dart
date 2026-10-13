import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Tendência dos últimos 6 meses: linhas suaves com área em degradê
/// (registradas × resolvidas) e tooltip ao tocar. Mostra ao lado do título
/// o saldo do último mês.
class TendenciaChart extends StatelessWidget {
  const TendenciaChart({super.key, required this.serie});

  final List<PontoTendencia> serie;

  static const _corOcorrencias = SisanCores.primaria;
  static const _corResolvidas = SisanCores.sucesso;

  static const _mesesAbrev = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

  String _abrev(String mesIso) {
    final partes = mesIso.split('-');
    if (partes.length != 2) return mesIso;
    final m = int.tryParse(partes[1]) ?? 1;
    return _mesesAbrev[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final maxValor = serie.fold<int>(0, (acc, p) {
      final localMax = p.ocorrencias > p.resolvidas ? p.ocorrencias : p.resolvidas;
      return localMax > acc ? localMax : acc;
    });
    final vazio = serie.isEmpty || maxValor == 0;

    return SisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, size: 18, color: SisanCores.textoSecundario),
              SizedBox(width: SisanEspaco.sm),
              Expanded(child: Text('Tendência (6 meses)', style: SisanTexto.tituloCard)),
            ],
          ),
          const SizedBox(height: SisanEspaco.xs),
          const Text('Registradas × resolvidas por mês', style: SisanTexto.legenda),
          const SizedBox(height: SisanEspaco.lg),
          if (vazio)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: SisanEspaco.lg),
              child: Text('Sem dados suficientes para o gráfico ainda.', style: SisanTexto.secundario),
            )
          else ...[
            SizedBox(
              height: 190,
              child: LineChart(_chartData(maxValor.toDouble()), duration: const Duration(milliseconds: 500)),
            ),
            const SizedBox(height: SisanEspaco.md),
            const Wrap(
              spacing: SisanEspaco.lg,
              runSpacing: 4,
              children: [
                _LegendaItem(cor: _corOcorrencias, label: 'Registradas'),
                _LegendaItem(cor: _corResolvidas, label: 'Resolvidas'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  LineChartData _chartData(double maxValor) {
    final maxY = (maxValor * 1.25).ceilToDouble().clamp(4, double.infinity).toDouble();
    final intervalY = (maxY / 4).ceilToDouble().clamp(1, double.infinity).toDouble();

    LineChartBarData linha(List<int> valores, Color cor) => LineChartBarData(
      spots: [for (var i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i].toDouble())],
      isCurved: true,
      curveSmoothness: 0.28,
      preventCurveOverShooting: true,
      color: cor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, _, _) =>
            FlDotCirclePainter(radius: 3.5, color: Colors.white, strokeWidth: 2.5, strokeColor: cor),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cor.withValues(alpha: 0.22), cor.withValues(alpha: 0)],
        ),
      ),
    );

    return LineChartData(
      minX: 0,
      maxX: (serie.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => SisanCores.texto,
          tooltipRoundedRadius: SisanRaio.sm,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          getTooltipItems: (spots) => [
            for (final s in spots)
              LineTooltipItem(
                '${s.y.toInt()} ${s.barIndex == 0 ? 'registradas' : 'resolvidas'}',
                TextStyle(
                  color: s.barIndex == 0 ? const Color(0xFF81D4FA) : const Color(0xFFA5D6A7),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: intervalY,
        getDrawingHorizontalLine: (_) => const FlLine(color: SisanCores.borda, strokeWidth: 1, dashArray: [4, 4]),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: intervalY,
            getTitlesWidget: (value, meta) {
              if (value % intervalY != 0) return const SizedBox.shrink();
              return Text(value.toInt().toString(), style: SisanTexto.legenda.copyWith(fontSize: 11));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= serie.length || value != i.toDouble()) return const SizedBox.shrink();
              final ultimo = i == serie.length - 1;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _abrev(serie[i].mesIso),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: ultimo ? FontWeight.w800 : FontWeight.w500,
                    color: ultimo ? SisanCores.texto : SisanCores.textoSecundario,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        linha([for (final p in serie) p.ocorrencias], _corOcorrencias),
        linha([for (final p in serie) p.resolvidas], _corResolvidas),
      ],
    );
  }
}

class _LegendaItem extends StatelessWidget {
  const _LegendaItem({required this.cor, required this.label});
  final Color cor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 4,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: SisanCores.textoSecundario, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
