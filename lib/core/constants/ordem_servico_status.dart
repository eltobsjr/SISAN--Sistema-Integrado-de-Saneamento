import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

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
        OrdemServicoStatus.pendente => SisanCores.atencao,
        OrdemServicoStatus.aceita => SisanCores.info,
        OrdemServicoStatus.aCaminho => SisanCores.andamento,
        OrdemServicoStatus.concluida => SisanCores.sucesso,
      };

  IconData get icone => switch (this) {
        OrdemServicoStatus.pendente => Icons.hourglass_empty_rounded,
        OrdemServicoStatus.aceita => Icons.assignment_turned_in_outlined,
        OrdemServicoStatus.aCaminho => Icons.directions_car_filled_outlined,
        OrdemServicoStatus.concluida => Icons.check_circle_outline,
      };

  static OrdemServicoStatus fromString(String value) =>
      OrdemServicoStatus.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => OrdemServicoStatus.pendente,
      );
}
