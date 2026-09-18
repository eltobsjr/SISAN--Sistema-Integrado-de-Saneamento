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

  String get dbValue => switch (this) {
        OcorrenciaStatus.pendente => 'pendente',
        OcorrenciaStatus.emAnalise => 'em_analise',
        OcorrenciaStatus.resolvida => 'resolvida',
        OcorrenciaStatus.arquivada => 'arquivada',
      };

  static OcorrenciaStatus fromString(String value) => OcorrenciaStatus.values
      .firstWhere((e) => e.dbValue == value, orElse: () => OcorrenciaStatus.pendente);
}
