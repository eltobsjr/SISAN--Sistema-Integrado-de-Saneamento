import 'package:flutter/material.dart';

/// Estado de carregamento — 3 gotinhas pulando em sequência (padrão clássico
/// de "loading dots", só que com gota em vez de bolinha).
class SisanLoading extends StatefulWidget {
  const SisanLoading({super.key}) : tamanho = 14;

  const SisanLoading.compact({super.key, this.tamanho = 10});

  final double tamanho;

  @override
  State<SisanLoading> createState() => _SisanLoadingState();
}

class _SisanLoadingState extends State<SisanLoading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return Semantics(
      label: 'Carregando',
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(width: widget.tamanho * 0.4),
                _Gota(tamanho: widget.tamanho, cor: cor, altura: _altura(i)),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Cada gota pula com 0.15 de atraso da anterior — só a fase muda.
  double _altura(int indice) {
    final t = (_controller.value - indice * 0.15) % 1.0;
    // Sobe e desce numa curva suave (metade do ciclo pra cada lado).
    final fase = t < 0.5 ? t * 2 : (1 - t) * 2;
    return Curves.easeOut.transform(fase);
  }
}

class _Gota extends StatelessWidget {
  const _Gota({required this.tamanho, required this.cor, required this.altura});
  final double tamanho;
  final Color cor;

  /// 0 (parada, embaixo) a 1 (pico do pulo).
  final double altura;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -altura * tamanho * 0.6),
      child: Icon(Icons.water_drop_rounded, size: tamanho, color: cor),
    );
  }
}
