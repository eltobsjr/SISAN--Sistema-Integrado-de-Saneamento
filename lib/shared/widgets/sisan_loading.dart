import 'package:flutter/material.dart';

/// Estado de carregamento animado do SISAN — adaptado do `SigauLoading` do
/// SIGAU (mesma arquitetura de animação e timing), trocando a pata que se
/// forma dedo a dedo por uma gota d'água que pulsa, para caber na
/// identidade "Água Viva" (decisions/008).
///
/// Duas variantes:
///
/// - [SisanLoading] — tela cheia: fundo azul claro, gota, wordmark "sisan" e
///   a linha "carregando...". Usada na splash.
/// - [SisanLoading.compact] — só a gota, sem fundo próprio, para
///   carregamentos que ocupam a área útil de uma página ou seção.
///
/// **Não** substitui `SkeletonList` em listas nem o `CircularProgressIndicator`
/// pequeno dentro de botões e placeholders de imagem.
class SisanLoading extends StatefulWidget {
  const SisanLoading({super.key, this.showText = true})
      : largura = _kLarguraGota,
        _telaCheia = true;

  const SisanLoading.compact({super.key, this.largura = 96})
      : showText = false,
        _telaCheia = false;

  /// Largura da gota em pixels lógicos. A altura acompanha a proporção 1:1.2.
  final double largura;

  /// Exibe a linha "carregando..." abaixo do wordmark. Só na versão cheia.
  final bool showText;

  final bool _telaCheia;

  @override
  State<SisanLoading> createState() => _SisanLoadingState();
}

class _SisanLoadingState extends State<SisanLoading> with TickerProviderStateMixin {
  late final AnimationController _gota =
      AnimationController(vsync: this, duration: _kCicloGota);
  late final AnimationController _pontos =
      AnimationController(vsync: this, duration: _kCicloPontos);

  bool _animada = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeita "reduzir animações" do sistema, igual ao SigauLoading.
    _animada = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (_animada && !_gota.isAnimating) {
      _gota.repeat();
      _pontos.repeat();
    } else if (!_animada && _gota.isAnimating) {
      _gota.stop();
      _pontos.stop();
    }
  }

  @override
  void dispose() {
    _gota.dispose();
    _pontos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gota = SizedBox(
      width: widget.largura,
      height: widget.largura * 1.2,
      child: CustomPaint(
        painter: _GotaPainter(progresso: _gota, animada: _animada),
      ),
    );

    if (!widget._telaCheia) {
      return Semantics(label: 'Carregando', liveRegion: true, child: gota);
    }

    return Semantics(
      label: 'Carregando',
      liveRegion: true,
      child: ColoredBox(
        color: _kFundo,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              gota,
              const SizedBox(height: 10),
              const Text(
                'sisan',
                style: TextStyle(
                  color: _kAzul,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  height: 1,
                ),
              ),
              if (widget.showText) ...[
                const SizedBox(height: 6),
                _LinhaCarregando(progresso: _pontos, animada: _animada),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaCarregando extends StatelessWidget {
  const _LinhaCarregando({required this.progresso, required this.animada});

  final Animation<double> progresso;
  final bool animada;

  static const _estilo = TextStyle(
    color: _kAzulSuave,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );

  static const _atrasos = <double>[0.0, 0.2, 0.4];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('carregando', style: _estilo),
        for (final atraso in _atrasos)
          AnimatedBuilder(
            animation: progresso,
            builder: (_, _) {
              final opacidade = animada
                  ? opacidadePontoSisanLoading(
                      _faseCiclo(progresso.value, atraso, _kCicloPontosSeg),
                    )
                  : 1.0;
              return Text(
                '.',
                style: _estilo.copyWith(color: _kAzulSuave.withValues(alpha: opacidade)),
              );
            },
          ),
      ],
    );
  }
}

/// Gota única que cresce e desvanece em loop — equivalente mais simples,
/// no tema de saneamento, das cinco formas da pata do `SigauLoading`.
class _GotaPainter extends CustomPainter {
  _GotaPainter({required this.progresso, required this.animada}) : super(repaint: progresso);

  final Animation<double> progresso;
  final bool animada;

  @override
  void paint(Canvas canvas, Size size) {
    final double fator;
    final double opacidade;
    if (animada) {
      final t = progresso.value;
      fator = escalaGotaSisanLoading(t);
      opacidade = opacidadeGotaSisanLoading(t);
    } else {
      fator = 1.0;
      opacidade = 1.0;
    }
    if (fator <= 0 || opacidade <= 0) return;

    final tinta = Paint()
      ..isAntiAlias = true
      ..color = _kAzul.withValues(alpha: opacidade);

    final w = size.width * fator;
    final h = size.height * fator;
    final cx = size.width / 2;
    final topo = (size.height - h) / 2;

    final caminho = Path()
      ..moveTo(cx, topo)
      ..quadraticBezierTo(cx + w * 0.55, topo + h * 0.55, cx, topo + h)
      ..quadraticBezierTo(cx - w * 0.55, topo + h * 0.55, cx, topo);

    canvas.drawPath(caminho, tinta);
  }

  @override
  bool shouldRepaint(_GotaPainter oldDelegate) => oldDelegate.animada != animada;
}

const _kAzul = Color(0xFF0288D1);
const _kAzulSuave = Color(0xFF6FB8E0);
const _kFundo = Color(0xFFE1F5FE);

const _kLarguraGota = 96.0;
const _kCicloGota = Duration(milliseconds: 2200);
const _kCicloPontos = Duration(milliseconds: 1200);
const _kCicloPontosSeg = 1.2;

double _faseCiclo(double t, double atraso, double cicloSegundos) =>
    (t - atraso / cicloSegundos) % 1.0;

/// Escala da gota: 0%→12% de 0 a 1,15 · 12%→18% de 1,15 a 1 · 18%→68% em 1 ·
/// 68%→80% de 1 a 0 · 80%→100% em 0 — mesma curva do `pawPop` do SIGAU.
@visibleForTesting
double escalaGotaSisanLoading(double t) {
  if (t < 0.12) return _entre(0.0, 1.15, t / 0.12);
  if (t < 0.18) return _entre(1.15, 1.0, (t - 0.12) / 0.06);
  if (t < 0.68) return 1.0;
  if (t < 0.80) return _entre(1.0, 0.0, (t - 0.68) / 0.12);
  return 0.0;
}

@visibleForTesting
double opacidadeGotaSisanLoading(double t) {
  if (t < 0.12) return _entre(0.0, 1.0, t / 0.12);
  if (t < 0.68) return 1.0;
  if (t < 0.80) return _entre(1.0, 0.0, (t - 0.68) / 0.12);
  return 0.0;
}

/// Opacidade dos pontos de "carregando...": 0%, 60% e 100% em 0,25; pico de
/// 1,0 em 30% — igual ao `sigauDot` do SIGAU.
@visibleForTesting
double opacidadePontoSisanLoading(double t) {
  if (t < 0.30) return _entre(0.25, 1.0, t / 0.30);
  if (t < 0.60) return _entre(1.0, 0.25, (t - 0.30) / 0.30);
  return 0.25;
}

double _entre(double de, double ate, double p) =>
    de + (ate - de) * Curves.ease.transform(p.clamp(0.0, 1.0));
