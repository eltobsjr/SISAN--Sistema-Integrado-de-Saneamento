import 'package:flutter/material.dart';

/// Widget reutilizável que exibe um overlay de carregamento sobre [child].
///
/// Quando [isLoading] é `true`, um overlay semitransparente com um
/// [CircularProgressIndicator] (e opcionalmente uma [message]) é renderizado
/// por cima do conteúdo. Quando `false`, [child] é retornado diretamente.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  /// Controla se o overlay de carregamento está visível.
  final bool isLoading;

  /// Widget filho exibido abaixo do overlay (sempre presente no layout).
  final Widget child;

  /// Mensagem opcional exibida abaixo do indicador de progresso.
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.45),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
