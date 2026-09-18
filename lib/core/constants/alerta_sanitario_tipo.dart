import 'package:flutter/material.dart';

/// Tipo de alerta sanitário — correlaciona uma zona do município com
/// recorrência de ocorrências (ex.: esgoto a céu aberto voltando sempre no
/// mesmo lugar) a um indicador de risco à saúde pública (roadmap Fase 4).
enum AlertaSanitarioTipo {
  esgotoCeuAbertoRecorrente,
  riscoDoencaHidrica,
  aguaContaminadaRecorrente,
  outros;

  static AlertaSanitarioTipo fromString(String s) => AlertaSanitarioTipo.values.firstWhere(
        (t) => t.dbValue == s,
        orElse: () => AlertaSanitarioTipo.outros,
      );

  String get label => switch (this) {
        AlertaSanitarioTipo.esgotoCeuAbertoRecorrente => 'Esgoto a céu aberto recorrente',
        AlertaSanitarioTipo.riscoDoencaHidrica => 'Risco de doença hídrica',
        AlertaSanitarioTipo.aguaContaminadaRecorrente => 'Água contaminada recorrente',
        AlertaSanitarioTipo.outros => 'Outros',
      };

  String get dbValue => switch (this) {
        AlertaSanitarioTipo.esgotoCeuAbertoRecorrente => 'esgoto_ceu_aberto_recorrente',
        AlertaSanitarioTipo.riscoDoencaHidrica => 'risco_doenca_hidrica',
        AlertaSanitarioTipo.aguaContaminadaRecorrente => 'agua_contaminada_recorrente',
        AlertaSanitarioTipo.outros => 'outros',
      };

  Color get cor => switch (this) {
        AlertaSanitarioTipo.esgotoCeuAbertoRecorrente => const Color(0xFF6D4C41),
        AlertaSanitarioTipo.riscoDoencaHidrica => const Color(0xFFC62828),
        AlertaSanitarioTipo.aguaContaminadaRecorrente => const Color(0xFF6A1B9A),
        AlertaSanitarioTipo.outros => const Color(0xFF546E7A),
      };

  IconData get icone => switch (this) {
        AlertaSanitarioTipo.esgotoCeuAbertoRecorrente => Icons.warning_amber_rounded,
        AlertaSanitarioTipo.riscoDoencaHidrica => Icons.coronavirus_outlined,
        AlertaSanitarioTipo.aguaContaminadaRecorrente => Icons.water_drop_outlined,
        AlertaSanitarioTipo.outros => Icons.health_and_safety_outlined,
      };
}
