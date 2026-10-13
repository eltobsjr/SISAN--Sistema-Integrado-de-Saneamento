import 'package:flutter/material.dart';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Barras horizontais por tipo de ocorrência no mês, ordenadas da mais
/// frequente para a menos. Cada barra usa a cor do tipo (a mesma do mapa).
class HeatmapTipoGrid extends StatelessWidget {
  const HeatmapTipoGrid({super.key, required this.porTipo});

  final Map<String, int> porTipo;

  @override
  Widget build(BuildContext context) {
    final itens = [for (final t in OcorrenciaTipo.values) (t, porTipo[t.dbValue] ?? 0)]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final maxValor = itens.isEmpty ? 0 : itens.first.$2;
    final total = itens.fold<int>(0, (a, e) => a + e.$2);

    return SisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 18, color: SisanCores.textoSecundario),
              SizedBox(width: SisanEspaco.sm),
              Expanded(child: Text('Ocorrências por tipo (mês)', style: SisanTexto.tituloCard)),
            ],
          ),
          const SizedBox(height: SisanEspaco.lg),
          if (maxValor == 0)
            const Text('Sem ocorrências registradas este mês.', style: SisanTexto.secundario)
          else
            for (final (i, (tipo, n)) in itens.indexed) ...[
              if (i > 0) const SizedBox(height: SisanEspaco.md),
              Row(
                children: [
                  Icon(tipo.icone, size: 16, color: tipo.cor),
                  const SizedBox(width: SisanEspaco.sm),
                  Expanded(
                    child: Text(
                      tipo.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: SisanCores.texto),
                    ),
                  ),
                  Text(
                    '$n',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: SisanCores.texto),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${total == 0 ? 0 : (n * 100 / total).round()}%',
                      textAlign: TextAlign.right,
                      style: SisanTexto.legenda,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(SisanRaio.pill),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: n / maxValor),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: tipo.cor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(tipo.cor),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}
