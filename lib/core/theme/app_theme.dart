import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

/// Identidade visual "Água Viva" (decisions/008): azul/ciano remetendo a
/// água limpa. Cores semânticas de urgência (verde/laranja/vermelho) ficam
/// fora daqui de propósito — nunca substituir por tons de azul, senão perde
/// a leitura rápida no mapa (ver decisions/008).
class AppTheme {
  AppTheme._();

  static const Color _primary = SisanCores.primaria;
  static const Color _secondary = SisanCores.primariaEscura;
  static const Color _error = SisanCores.perigo;
  static const Color _background = SisanCores.fundo;
  static const Color _onPrimary = Colors.white;

  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      error: _error,
      surface: Colors.white,
      onPrimary: _onPrimary,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: SisanCores.texto,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _secondary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SisanRaio.md)),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SisanRaio.md)),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: _primary)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SisanRaio.md),
          borderSide: const BorderSide(color: SisanCores.bordaForte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SisanRaio.md),
          borderSide: const BorderSide(color: SisanCores.bordaForte),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SisanRaio.md),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SisanRaio.md),
          borderSide: const BorderSide(color: _error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: SisanCores.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SisanRaio.lg),
          side: const BorderSide(color: SisanCores.borda),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SisanCores.superficie,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: SisanCores.primariaClara,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? SisanCores.primariaEscura : SisanCores.textoSecundario,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? SisanCores.primariaEscura : SisanCores.textoSecundario,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: SisanCores.borda, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SisanRaio.md)),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SisanCores.texto,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SisanRaio.md)),
      ),
      chipTheme: ChipThemeData(
        side: const BorderSide(color: SisanCores.borda),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SisanRaio.pill)),
      ),
    );
  }
}
