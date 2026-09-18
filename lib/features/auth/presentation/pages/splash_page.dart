import 'package:flutter/material.dart';

/// Sem lógica de navegação aqui de propósito: o `routerProvider` decide o
/// destino (login ou home do perfil certo) via `redirect`, assim que a
/// sessão e o perfil do usuário terminam de resolver.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_rounded, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              'SISAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
