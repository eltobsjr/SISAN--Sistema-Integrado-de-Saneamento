import 'package:flutter/material.dart';

import 'logo_paths.dart';

/// Desenha a água-viva do ícone se formando a partir de [progress] (0 a 1):
/// cabeça primeiro (contorno → preenchimento, técnica do `LogoRevealPainter`
/// do Confia), depois olhos/boca, depois os 5 tentáculos ondulando pra
/// dentro em sequência — terminando idêntica ao ícone de verdade
/// (`assets/images/app_icon_full.png`).
class AguaVivaRevealPainter extends CustomPainter {
  AguaVivaRevealPainter({required this.progress})
      : cabecaPath = buildCabecaPath(),
        brilhoPath = buildBrilhoPath(),
        bocaPath = buildBocaPath(),
        tentaculos = buildTentaculos();

  final double progress;
  final Path cabecaPath;
  final Path brilhoPath;
  final Path bocaPath;
  final List<TentaculoSpec> tentaculos;

  static const _branco = Colors.white;
  static const _azulEscuro = Color(0xFF01579B);
  static const _brilho = Color(0xFFB3E5FC);

  static const _canvasSize = 1024.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _canvasSize, size.height / _canvasSize);

    // Fundo azul circular, igual ao ícone real.
    canvas.drawCircle(const Offset(512, 512), 512, Paint()..color = const Color(0xFF0288D1));

    _paintForma(canvas, cabecaPath, _branco, drawStart: 0.00, drawEnd: 0.32, fillStart: 0.26, fillEnd: 0.42);

    final brilhoOpacidade = ((progress - 0.36) / 0.14).clamp(0.0, 1.0);
    if (brilhoOpacidade > 0) {
      canvas.drawPath(brilhoPath, Paint()..color = _brilho.withValues(alpha: 0.55 * brilhoOpacidade));
    }

    final rostoOpacidade = ((progress - 0.42) / 0.16).clamp(0.0, 1.0);
    if (rostoOpacidade > 0) {
      final tinta = Paint()..color = _azulEscuro.withValues(alpha: rostoOpacidade);
      canvas.drawCircle(const Offset(472, 360), 13, tinta);
      canvas.drawCircle(const Offset(552, 360), 13, tinta);
      canvas.drawPath(
        bocaPath,
        Paint()
          ..color = _azulEscuro.withValues(alpha: rostoOpacidade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Tentáculos: começam em sequência (0.55 a 0.90), cada um levando 0.30
    // do progresso total pra se desenhar por inteiro.
    const inicioTentaculos = 0.55;
    const passo = 0.07;
    const duracaoCadaUm = 0.30;
    for (var i = 0; i < tentaculos.length; i++) {
      final t = tentaculos[i];
      final inicio = inicioTentaculos + i * passo;
      final fim = (inicio + duracaoCadaUm).clamp(0.0, 1.0);
      final fracao = ((progress - inicio) / (fim - inicio)).clamp(0.0, 1.0);
      if (fracao <= 0) continue;
      final tinta = Paint()
        ..color = _branco.withValues(alpha: t.opacidade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = t.largura
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_extrairFracao(t.path, fracao), tinta);
    }

    canvas.restore();
  }

  void _paintForma(
    Canvas canvas,
    Path path,
    Color color, {
    required double drawStart,
    required double drawEnd,
    required double fillStart,
    required double fillEnd,
  }) {
    final drawFrac = ((progress - drawStart) / (drawEnd - drawStart)).clamp(0.0, 1.0);
    final fillFrac = ((progress - fillStart) / (fillEnd - fillStart)).clamp(0.0, 1.0);
    if (drawFrac <= 0 && fillFrac <= 0) return;

    if (drawFrac > 0 && fillFrac < 1) {
      final tracoPaint = Paint()
        ..color = color.withValues(alpha: 1 - fillFrac)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_extrairFracao(path, drawFrac), tracoPaint);
    }
    if (fillFrac > 0) {
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: fillFrac)..style = PaintingStyle.fill);
    }
  }

  Path _extrairFracao(Path origem, double fracao) {
    final resultado = Path();
    for (final metrica in origem.computeMetrics()) {
      resultado.addPath(metrica.extractPath(0, metrica.length * fracao), Offset.zero);
    }
    return resultado;
  }

  @override
  bool shouldRepaint(covariant AguaVivaRevealPainter oldDelegate) => oldDelegate.progress != progress;
}
