import 'package:flutter/material.dart';

/// Botão pílula de largura total — adaptado do `PrimaryButton` do
/// polimata-concursos (mesmo peso visual de CTA principal), na cor
/// primária "Água Viva" em vez do preto do Polymata.
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final habilitado = enabled && !loading;

    return GestureDetector(
      onTap: habilitado ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: habilitado ? primary : primary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
      ),
    );
  }
}
