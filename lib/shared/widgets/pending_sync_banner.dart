import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisan/shared/design/sisan_tokens.dart';

import 'package:sisan/shared/services/sync_service.dart';

/// Aviso compacto de quantas ações locais ainda não foram enviadas ao
/// servidor (fila offline via drift) — some sozinho quando a lista esvazia.
class PendingSyncBanner extends ConsumerWidget {
  const PendingSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: SisanCores.atencaoClara,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, size: 16, color: SisanCores.atencao),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count ação${count == 1 ? '' : 'ões'} aguardando conexão para sincronizar',
              style: TextStyle(fontSize: 12, color: SisanCores.atencao, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
