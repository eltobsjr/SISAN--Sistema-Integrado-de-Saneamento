import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';

class GestorHomePage extends ConsumerWidget {
  const GestorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SISAN — Gestor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Text('Olá, ${usuario?.nome ?? ''}!\nHome do gestor.'),
      ),
    );
  }
}
