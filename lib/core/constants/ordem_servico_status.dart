import 'package:flutter/material.dart';

enum OrdemServicoStatus {
  pendente,
  aceita,
  aCaminho,
  concluida;

  String get label => switch (this) {
        OrdemServicoStatus.pendente => 'Pendente',
        OrdemServicoStatus.aceita => 'Aceita',
        OrdemServicoStatus.aCaminho => 'A caminho',
        OrdemServicoStatus.concluida => 'Concluída',
      };

  String get dbValue => switch (this) {
        OrdemServicoStatus.pendente => 'pendente',
        OrdemServicoStatus.aceita => 'aceita',
        OrdemServicoStatus.aCaminho => 'a_caminho',
        OrdemServicoStatus.concluida => 'concluida',
      };

  Color get cor => switch (this) {
        OrdemServicoStatus.pendente => Colors.orange,
        OrdemServicoStatus.aceita => Colors.blue,
        OrdemServicoStatus.aCaminho => Colors.purple,
        OrdemServicoStatus.concluida => Colors.green,
      };

  static OrdemServicoStatus fromString(String value) =>
      OrdemServicoStatus.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => OrdemServicoStatus.pendente,
      );
}
