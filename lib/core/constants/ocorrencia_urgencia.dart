import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

/// Cores semânticas de urgência — sempre separadas da identidade visual
/// "Água Viva" (decisions/008): nunca substituir por tons de azul, senão
/// perde a leitura rápida no mapa. Definida pela Edge Function
/// `classify-ocorrencia` (Fase 5); enquanto a IA não responde, a ocorrência
/// fica com o padrão `normal`.
enum OcorrenciaUrgencia {
  normal,
  atencao,
  riscoSaude;

  String get label => switch (this) {
    OcorrenciaUrgencia.normal => 'Normal',
    OcorrenciaUrgencia.atencao => 'Atenção',
    OcorrenciaUrgencia.riscoSaude => 'Risco à saúde',
  };

  String get dbValue => switch (this) {
    OcorrenciaUrgencia.normal => 'normal',
    OcorrenciaUrgencia.atencao => 'atencao',
    OcorrenciaUrgencia.riscoSaude => 'risco_saude',
  };

  Color get cor => switch (this) {
    OcorrenciaUrgencia.normal => SisanCores.sucesso,
    OcorrenciaUrgencia.atencao => SisanCores.atencao,
    OcorrenciaUrgencia.riscoSaude => SisanCores.perigo,
  };

  /// Ícone que acompanha a cor: a urgência nunca depende só do tom.
  IconData get icone => switch (this) {
    OcorrenciaUrgencia.normal => Icons.check_circle_outline,
    OcorrenciaUrgencia.atencao => Icons.warning_amber_rounded,
    OcorrenciaUrgencia.riscoSaude => Icons.health_and_safety_outlined,
  };

  static OcorrenciaUrgencia fromString(String value) => switch (value) {
    'atencao' => OcorrenciaUrgencia.atencao,
    'risco_saude' => OcorrenciaUrgencia.riscoSaude,
    _ => OcorrenciaUrgencia.normal,
  };
}
