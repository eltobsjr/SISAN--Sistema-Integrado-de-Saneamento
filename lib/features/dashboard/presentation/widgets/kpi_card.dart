import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.subtitulo,
    this.comparacao,
    this.comparacaoCor,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final String? subtitulo;

  /// Linha de comparação vs. mês anterior (ex.: "+3 vs. mês anterior").
  final String? comparacao;
  final Color? comparacaoCor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: cor.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cor, height: 1),
                ),
                const Spacer(),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icone, color: cor, size: 17),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (comparacao != null) ...[
              const SizedBox(height: 3),
              Text(
                comparacao!,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: comparacaoCor ?? Colors.black38),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else if (subtitulo != null) ...[
              const SizedBox(height: 1),
              Text(subtitulo!, style: const TextStyle(fontSize: 9, color: Colors.black38), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }
}
