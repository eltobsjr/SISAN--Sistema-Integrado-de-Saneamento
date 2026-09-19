import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/alertas_sanitarios/presentation/providers/alertas_sanitarios_provider.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';

class GestorHomePage extends ConsumerWidget {
  const GestorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;
    final alertas = ref.watch(alertasSanitariosProvider).valueOrNull ?? const [];
    final alertasAtivos = alertas.where((a) => a.ativo).length;

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
            const Text('Visão geral do saneamento no seu município.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.dashboard_outlined, size: 32),
                title: const Text('Dashboard'),
                subtitle: const Text('KPIs, tendência e relatório em PDF'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/dashboard'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined, size: 32),
                title: const Text('Alertas Sanitários'),
                subtitle: Text(
                  alertasAtivos > 0 ? '$alertasAtivos ativo${alertasAtivos == 1 ? '' : 's'}' : 'Nenhum alerta ativo',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/alertas-sanitarios'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined, size: 32),
                title: const Text('Ordens de Serviço'),
                subtitle: const Text('Acompanhe o andamento no município'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/ordens-de-servico'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.location_city_outlined, size: 32),
                title: const Text('Meu município'),
                subtitle: const Text('Equipe e código de ativação'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/meu-municipio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
