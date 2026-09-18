import 'package:flutter/material.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';

/// Grade de intensidade por tipo de ocorrência no mês — a cor de cada célula
/// fica mais forte quanto maior a contagem relativa ao tipo mais frequente.
/// Sem precedente no SIGAU (roadmap pede "heatmap" só pro SISAN); aqui é uma
/// leitura simples, sem depender de um pacote de mapa de calor geográfico.
class HeatmapTipoGrid extends StatelessWidget {
  const HeatmapTipoGrid({super.key, required this.porTipo});

  final Map<String, int> porTipo;

  @override
  Widget build(BuildContext context) {
    final maxValor = porTipo.values.isEmpty ? 0 : porTipo.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grid_view_rounded, size: 18, color: Colors.black54),
                SizedBox(width: 8),
                Text('Ocorrências por tipo (mês)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            if (maxValor == 0)
              const Text('Sem ocorrências registradas este mês.', style: TextStyle(color: Colors.black38, fontSize: 13))
            else
              Column(
                children: OcorrenciaTipo.values.map((tipo) {
                  final total = porTipo[tipo.dbValue] ?? 0;
                  final intensidade = maxValor == 0 ? 0.0 : total / maxValor;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            tipo.label,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: tipo.cor.withValues(alpha: 0.08 + 0.5 * intensidade),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '$total',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: intensidade > 0.5 ? Colors.white : tipo.cor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
