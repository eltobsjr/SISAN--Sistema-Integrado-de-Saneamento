import 'package:flutter/material.dart';

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
        OcorrenciaUrgencia.normal => const Color(0xFF2E7D32),
        OcorrenciaUrgencia.atencao => const Color(0xFFEF6C00),
        OcorrenciaUrgencia.riscoSaude => const Color(0xFFC62828),
      };

  static OcorrenciaUrgencia fromString(String value) => switch (value) {
        'atencao' => OcorrenciaUrgencia.atencao,
        'risco_saude' => OcorrenciaUrgencia.riscoSaude,
        _ => OcorrenciaUrgencia.normal,
      };
}
