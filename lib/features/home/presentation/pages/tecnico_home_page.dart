import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/shared/widgets/sino_notificacoes_button.dart';

class TecnicoHomePage extends ConsumerWidget {
  const TecnicoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;
    final fila = ref.watch(ordensServicoProvider).valueOrNull ?? const [];
    final pendentes = fila.where((os) => os.tecnicoId == null).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SISAN — Técnico'),
        actions: [
          const SinoNotificacoesButton(corIcone: Colors.black87),
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
              'Ordens de serviço do seu município.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined, size: 32),
                title: const Text('Ordens de Serviço'),
                subtitle: Text(
                  pendentes > 0
                      ? '$pendentes pendente${pendentes == 1 ? '' : 's'} aguardando'
                      : 'Fila do município',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/ordens-de-servico'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
