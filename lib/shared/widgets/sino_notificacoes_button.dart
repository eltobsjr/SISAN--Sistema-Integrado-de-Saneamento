import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/notificacoes/presentation/providers/notificacoes_provider.dart';

/// Sino com badge de não lidas — adaptado do `_SinhinhoButton` do SIGAU.
class SinoNotificacoesButton extends ConsumerWidget {
  const SinoNotificacoesButton({super.key, this.corIcone = Colors.white});

  final Color corIcone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(notificacoesNaoLidasProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: corIcone),
          onPressed: () {
            ref.invalidate(notificacoesProvider);
            context.push('/notificacoes');
          },
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
