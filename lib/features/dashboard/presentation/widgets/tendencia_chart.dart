import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';

/// Adaptado de `TendenciaChart` do SIGAU: gráfico de barras dos últimos 6
/// meses, trocando resgates/avistamentos/adoções por ocorrências/resolvidas.
class TendenciaChart extends StatelessWidget {
  const TendenciaChart({super.key, required this.serie});

  final List<PontoTendencia> serie;

  static const _corOcorrencias = Color(0xFF0288D1);
  static const _corResolvidas = Color(0xFF2E7D32);

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

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.bar_chart_outlined, size: 18, color: Colors.black54),
                SizedBox(width: 8),
                Text('Tendência (6 meses)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          if (serie.isEmpty || maxValor == 0)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Text('Sem dados suficientes para o gráfico ainda.', style: TextStyle(color: Colors.black38, fontSize: 13)),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: SizedBox(height: 200, child: BarChart(_chartData(maxValor.toDouble()))),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 14), child: _Legenda()),
          ],
        ],
      ),
    );
  }

  BarChartData _chartData(double maxValor) {
    final maxY = (maxValor * 1.25).ceilToDouble().clamp(1, double.infinity).toDouble();
    final intervalY = (maxY / 4).ceilToDouble().clamp(1, double.infinity).toDouble();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: intervalY,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x11000000), strokeWidth: 1),
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
              if (value % intervalY != 0 && value != meta.max) return const SizedBox.shrink();
              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.black38, fontSize: 9));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= serie.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_abrev(serie[i].mesIso), style: const TextStyle(color: Colors.black45, fontSize: 10)),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < serie.length; i++)
          BarChartGroupData(
            x: i,
            barsSpace: 2,
            barRods: [_rod(serie[i].ocorrencias, _corOcorrencias), _rod(serie[i].resolvidas, _corResolvidas)],
          ),
      ],
    );
  }

  BarChartRodData _rod(int valor, Color cor) => BarChartRodData(
        toY: valor.toDouble(),
        width: 7,
        color: cor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      );
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendaItem(cor: TendenciaChart._corOcorrencias, label: 'Ocorrências registradas'),
        _LegendaItem(cor: TendenciaChart._corResolvidas, label: 'Resolvidas'),
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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}
