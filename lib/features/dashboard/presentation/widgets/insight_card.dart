import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sisan/features/dashboard/presentation/providers/dashboard_provider.dart';

/// Resumo executivo do mês por IA. Falhas ficam contidas aqui: o card mostra
/// um aviso discreto com "tentar de novo" e o resto do dashboard não é afetado.
class InsightCard extends ConsumerWidget {
  const InsightCard({super.key});

  static const _azul = Color(0xFF0288D1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightDashboardProvider);

    return state.when(
      loading: () => _moldura(
        child: const Row(
          children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _azul)),
            SizedBox(width: 12),
            Expanded(child: Text('Gerando resumo do mês...', style: TextStyle(color: Colors.black54, fontSize: 13))),
          ],
        ),
      ),
      error: (_, _) => _moldura(
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 18, color: Colors.black38),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Resumo por IA indisponível no momento.', style: TextStyle(color: Colors.black54, fontSize: 13)),
            ),
            TextButton(onPressed: () => ref.invalidate(insightDashboardProvider), child: const Text('Tentar de novo')),
          ],
        ),
      ),
      data: (insight) {
        // null = não é gestor ou o mês ainda não tem ocorrências.
        if (insight == null) return const SizedBox.shrink();
        return _moldura(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: _azul),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'RESUMO DO MÊS POR IA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: _azul),
                    ),
                  ),
                  if (insight.geradoEm != null)
                    Text(
                      'atualizado ${DateFormat('dd/MM HH:mm').format(insight.geradoEm!)}',
                      style: const TextStyle(fontSize: 11, color: Colors.black38),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(insight.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.25)),
              const SizedBox(height: 8),
              for (final frase in insight.frases)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 8),
                        child: Icon(Icons.circle, size: 6, color: _azul),
                      ),
                      Expanded(child: Text(frase, style: const TextStyle(fontSize: 13.5, height: 1.4))),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _moldura({required Widget child}) => Card(
        color: const Color(0xFFE3F2FD),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFBBDEFB)),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
}
