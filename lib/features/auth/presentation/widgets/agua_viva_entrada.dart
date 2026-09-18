import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:sisan/core/theme/branding/agua_viva_reveal_painter.dart';

/// Animação de abertura: a água-viva se forma (cabeça, rosto e tentáculos),
/// nas mesmas cores e traçado do ícone de verdade — adaptado do mecanismo do
/// `IntroSplashScreen` do Confia (`AnimationController` + `CustomPainter`
/// com contorno-depois-preenchimento), mas sem navegação própria: o
/// `SplashPage` já sai da tela sozinho via `routerProvider` assim que a
/// sessão resolve. Toca uma vez e segura no quadro final até isso acontecer.
class AguaVivaEntrada extends StatefulWidget {
  const AguaVivaEntrada({super.key, this.tamanho = 220});

  final double tamanho;

  @override
  State<AguaVivaEntrada> createState() => _AguaVivaEntradaState();
}

class _AguaVivaEntradaState extends State<AguaVivaEntrada> with SingleTickerProviderStateMixin {
  static const _duracao = Duration(milliseconds: 2200);

  late final AnimationController _controller = AnimationController(vsync: this, duration: _duracao);

  @override
  void initState() {
    super.initState();
    final reduzida = SchedulerBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduzida) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SISAN',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ClipOval(
            child: SizedBox(
              width: widget.tamanho,
              height: widget.tamanho,
              child: CustomPaint(painter: AguaVivaRevealPainter(progress: _controller.value)),
            ),
          );
        },
      ),
    );
  }
}
