import 'package:flutter/material.dart';

import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Sem lógica de navegação aqui de propósito: o `routerProvider` decide o
/// destino (login ou home do perfil certo) via `redirect`, assim que a
/// sessão e o perfil do usuário terminam de resolver.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: SisanLoading());
}
