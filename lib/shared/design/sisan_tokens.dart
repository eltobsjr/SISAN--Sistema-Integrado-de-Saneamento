import 'package:flutter/material.dart';

/// Tokens do design system do SISAN (identidade "Água Viva", decisions/008).
///
/// Toda cor, raio e espaçamento de tela sai daqui. As cores semânticas
/// (sucesso/atenção/perigo) são as mesmas da urgência no mapa: nunca trocar
/// por tons de azul, senão perde a leitura rápida.
abstract final class SisanCores {
  // Marca
  static const primaria = Color(0xFF0288D1);
  static const primariaEscura = Color(0xFF01579B);
  static const primariaClara = Color(0xFFE1F2FB);

  // Superfícies
  static const fundo = Color(0xFFF3F6F9);
  static const superficie = Colors.white;
  static const borda = Color(0xFFE3E9EF);

  // Texto
  static const texto = Color(0xFF15222D);
  static const textoSecundario = Color(0xFF5A6A77);
  static const textoTerciario = Color(0xFF94A2AE);

  // Semânticas
  static const sucesso = Color(0xFF2E7D32);
  static const atencao = Color(0xFFEF6C00);
  static const perigo = Color(0xFFC62828);
  static const info = Color(0xFF0288D1);
  static const andamento = Color(0xFF6A1B9A);
  static const neutro = Color(0xFF78909C);

  // Acentos de categoria (atalhos, gráficos)
  static const teal = Color(0xFF00796B);
  static const indigo = Color(0xFF3949AB);
  static const rosa = Color(0xFFAD1457);

  static const gradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaria, primariaEscura],
  );
}

abstract final class SisanRaio {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

abstract final class SisanEspaco {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;

  /// Margem lateral padrão das telas.
  static const tela = 16.0;
}

abstract final class SisanTexto {
  static const tituloTela = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: SisanCores.texto);
  static const tituloSecao = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SisanCores.texto);
  static const tituloCard = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: SisanCores.texto);
  static const corpo = TextStyle(fontSize: 14, color: SisanCores.texto, height: 1.4);
  static const secundario = TextStyle(fontSize: 13, color: SisanCores.textoSecundario, height: 1.35);
  static const legenda = TextStyle(fontSize: 12, color: SisanCores.textoTerciario);
  static const rotulo = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: SisanCores.textoTerciario,
    letterSpacing: 0.6,
  );
}

/// Tempo relativo curto usado em todos os cards ("agora", "há 5 min",
/// "há 3h", "ontem", "há 12 dias"; data a partir de 60 dias).
String tempoRelativo(DateTime quando) {
  final diff = DateTime.now().difference(quando);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours}h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 60) return 'há ${diff.inDays} dias';
  final l = quando.toLocal();
  return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}';
}
