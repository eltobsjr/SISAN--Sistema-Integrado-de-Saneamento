import 'package:flutter/material.dart';

/// Barra de progresso por etapas — adaptada do `_ProgressBar` do onboarding
/// do polimata-concursos (uma pergunta por tela). Acessível: anuncia
/// "Passo N de M" pro leitor de tela em vez de deixar cada barrinha ser lida.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({super.key, required this.position, required this.total});

  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Passo $position de $total',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: i < position ? primary : primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
