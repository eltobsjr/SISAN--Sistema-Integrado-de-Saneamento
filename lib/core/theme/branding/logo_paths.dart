import 'package:flutter/material.dart';

/// Caminhos vetoriais da água-viva do ícone real (`assets/images/app_icon_fg.svg`),
/// traçados no mesmo espaço de coordenadas do SVG (1024×1024) — mesma lógica
/// do `logo_paths.dart` do Confia: usar os caminhos de verdade do ícone pra
/// a animação terminar idêntica a ele, não uma aproximação.

/// Cúpula da cabeça, com a borda inferior arredondada (8 "gomos").
Path buildCabecaPath() {
  final path = Path()..moveTo(300, 460);
  path.cubicTo(300, 340, 350, 260, 512, 260);
  path.cubicTo(674, 260, 724, 340, 724, 460);
  var x = 724.0;
  const y = 460.0;
  for (var i = 0; i < 8; i++) {
    final nx = x - 53;
    path.arcToPoint(Offset(nx, y), radius: const Radius.circular(26.5), clockwise: true);
    x = nx;
  }
  path.close();
  return path;
}

/// Mancha clara de brilho na cabeça (decorativa, some junto do preenchimento).
Path buildBrilhoPath() {
  return Path()
    ..addOval(Rect.fromCenter(center: const Offset(440, 330), width: 140, height: 76));
}

/// Boca — curva simples sob os olhos.
Path buildBocaPath() {
  return Path()
    ..moveTo(475, 400)
    ..quadraticBezierTo(512, 420, 549, 400);
}

/// Um dos 5 tentáculos, no mesmo traçado do SVG original.
class TentaculoSpec {
  const TentaculoSpec(this.path, this.largura, this.opacidade);
  final Path path;
  final double largura;
  final double opacidade;
}

List<TentaculoSpec> buildTentaculos() {
  // Traçado exato de cada tentáculo do SVG original.
  Path path1 = Path()
    ..moveTo(350, 460)
    ..cubicTo(315, 540, 385, 600, 350, 660)
    ..cubicTo(325, 700, 375, 720, 350, 740);
  Path path2 = Path()
    ..moveTo(430, 460)
    ..cubicTo(395, 540, 465, 600, 430, 660)
    ..cubicTo(405, 700, 455, 750, 430, 780);
  Path path3 = Path()
    ..moveTo(512, 460)
    ..cubicTo(477, 540, 547, 600, 512, 660)
    ..cubicTo(487, 700, 537, 760, 512, 800);
  Path path4 = Path()
    ..moveTo(594, 460)
    ..cubicTo(629, 540, 559, 600, 594, 660)
    ..cubicTo(619, 700, 569, 750, 594, 780);
  Path path5 = Path()
    ..moveTo(674, 460)
    ..cubicTo(709, 540, 639, 600, 674, 660)
    ..cubicTo(699, 700, 649, 720, 674, 740);

  return [
    TentaculoSpec(path1, 22, 0.9),
    TentaculoSpec(path2, 18, 0.75),
    TentaculoSpec(path3, 26, 1.0),
    TentaculoSpec(path4, 18, 0.75),
    TentaculoSpec(path5, 22, 0.9),
  ];
}
