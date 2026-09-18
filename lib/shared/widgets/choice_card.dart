import 'package:flutter/material.dart';

/// Card de escolha única — adaptado do `_ChoiceCard` do onboarding do
/// polimata-concursos: borda grossa quando selecionado, indicador circular
/// à direita, acessível via `Semantics` (leitor de tela anuncia como botão
/// de um grupo mutuamente exclusivo).
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icone,
    this.cor,
  });

  final String title;
  final String? subtitle;
  final IconData? icone;
  final Color? cor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final corBase = cor ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(selected ? 13.5 : 14),
          decoration: BoxDecoration(
            color: selected ? corBase.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? corBase : Colors.black12, width: selected ? 2 : 1.5),
          ),
          child: Row(
            children: [
              if (icone != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: corBase.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, color: corBase, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: const TextStyle(fontSize: 12.5, color: Colors.black45)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RadioDot(selected: selected, cor: corBase),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.cor});
  final bool selected;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? cor : Colors.transparent,
        border: Border.all(color: selected ? cor : Colors.black26, width: 1.5),
      ),
      child: selected
          ? const Center(
              child: Icon(Icons.check, size: 14, color: Colors.white),
            )
          : null,
    );
  }
}
