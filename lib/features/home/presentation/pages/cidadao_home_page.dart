import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';

class CidadaoHomePage extends ConsumerWidget {
  const CidadaoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SISAN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${usuario?.nome ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Viu um problema de água ou esgoto? Registre agora.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.add_circle_outline, size: 32),
                title: const Text('Nova ocorrência'),
                subtitle: const Text('Foto, GPS e descrição do problema'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/ocorrencias/nova'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.history_rounded, size: 32),
                title: const Text('Minhas ocorrências'),
                subtitle: const Text('Acompanhe o status dos seus registros'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/ocorrencias'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
