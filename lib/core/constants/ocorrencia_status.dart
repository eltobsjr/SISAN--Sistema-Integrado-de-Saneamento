import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

enum OcorrenciaStatus {
  pendente,
  emAnalise,
  resolvida,
  arquivada;

  String get label => switch (this) {
        OcorrenciaStatus.pendente => 'Pendente',
        OcorrenciaStatus.emAnalise => 'Em análise',
        OcorrenciaStatus.resolvida => 'Resolvida',
        OcorrenciaStatus.arquivada => 'Arquivada',
      };

  Color get cor => switch (this) {
        OcorrenciaStatus.pendente => SisanCores.atencao,
        OcorrenciaStatus.emAnalise => SisanCores.info,
        OcorrenciaStatus.resolvida => SisanCores.sucesso,
        OcorrenciaStatus.arquivada => SisanCores.neutro,
      };

  IconData get icone => switch (this) {
        OcorrenciaStatus.pendente => Icons.hourglass_empty_rounded,
        OcorrenciaStatus.emAnalise => Icons.engineering_outlined,
        OcorrenciaStatus.resolvida => Icons.check_circle_outline,
        OcorrenciaStatus.arquivada => Icons.archive_outlined,
      };

  String get dbValue => switch (this) {
        OcorrenciaStatus.pendente => 'pendente',
        OcorrenciaStatus.emAnalise => 'em_analise',
        OcorrenciaStatus.resolvida => 'resolvida',
        OcorrenciaStatus.arquivada => 'arquivada',
      };

  static OcorrenciaStatus fromString(String value) => OcorrenciaStatus.values
      .firstWhere((e) => e.dbValue == value, orElse: () => OcorrenciaStatus.pendente);
}
