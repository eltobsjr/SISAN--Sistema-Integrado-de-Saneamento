import 'package:flutter/material.dart';

enum OcorrenciaTipo {
  vazamento,
  esgotoCeuAberto,
  faltaDagua,
  aguaContaminada,
  baixaPressao,
  outros;

  String get label => switch (this) {
        OcorrenciaTipo.vazamento => 'Vazamento',
        OcorrenciaTipo.esgotoCeuAberto => 'Esgoto a céu aberto',
        OcorrenciaTipo.faltaDagua => 'Falta d\'água',
        OcorrenciaTipo.aguaContaminada => 'Água contaminada',
        OcorrenciaTipo.baixaPressao => 'Baixa pressão',
        OcorrenciaTipo.outros => 'Outros',
      };

  String get dbValue => switch (this) {
        OcorrenciaTipo.vazamento => 'vazamento',
        OcorrenciaTipo.esgotoCeuAberto => 'esgoto_ceu_aberto',
        OcorrenciaTipo.faltaDagua => 'falta_dagua',
        OcorrenciaTipo.aguaContaminada => 'agua_contaminada',
        OcorrenciaTipo.baixaPressao => 'baixa_pressao',
        OcorrenciaTipo.outros => 'outros',
      };

  Color get cor => switch (this) {
        OcorrenciaTipo.vazamento => const Color(0xFF0288D1),
        OcorrenciaTipo.esgotoCeuAberto => const Color(0xFF6D4C41),
        OcorrenciaTipo.faltaDagua => const Color(0xFFEF6C00),
        OcorrenciaTipo.aguaContaminada => const Color(0xFF6A1B9A),
        OcorrenciaTipo.baixaPressao => const Color(0xFF00838F),
        OcorrenciaTipo.outros => const Color(0xFF546E7A),
      };

  IconData get icone => switch (this) {
        OcorrenciaTipo.vazamento => Icons.water_drop_outlined,
        OcorrenciaTipo.esgotoCeuAberto => Icons.warning_amber_rounded,
        OcorrenciaTipo.faltaDagua => Icons.water_drop_outlined,
        OcorrenciaTipo.aguaContaminada => Icons.coronavirus_outlined,
        OcorrenciaTipo.baixaPressao => Icons.speed_outlined,
        OcorrenciaTipo.outros => Icons.help_outline_rounded,
      };

  static OcorrenciaTipo fromString(String value) => OcorrenciaTipo.values
      .firstWhere((e) => e.dbValue == value, orElse: () => OcorrenciaTipo.outros);
}
