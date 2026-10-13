import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

/// Nível de risco à saúde (coluna `risco_saude`), definido pela Edge Function
/// `classify-ocorrencia` ou corrigido pelo gestor. Na interface é sempre
/// "nível de risco", pra não confundir com a urgência "Risco à saúde".
enum OcorrenciaRisco {
  baixo,
  medio,
  alto;

  String get label => switch (this) {
    OcorrenciaRisco.baixo => 'Baixo',
    OcorrenciaRisco.medio => 'Médio',
    OcorrenciaRisco.alto => 'Alto',
  };

  String get dbValue => name;

  Color get cor => switch (this) {
    OcorrenciaRisco.baixo => SisanCores.sucesso,
    OcorrenciaRisco.medio => SisanCores.atencao,
    OcorrenciaRisco.alto => SisanCores.perigo,
  };

  static OcorrenciaRisco? fromString(String? value) => switch (value) {
    'baixo' => OcorrenciaRisco.baixo,
    'medio' => OcorrenciaRisco.medio,
    'alto' => OcorrenciaRisco.alto,
    _ => null,
  };
}
