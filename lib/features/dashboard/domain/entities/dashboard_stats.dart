import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';

/// Totais de um mês (KPIs do topo).
class MesTotais {
  final int ocorrencias;
  final int resolvidas;
  final double tempoMedioHoras;

  const MesTotais({required this.ocorrencias, required this.resolvidas, required this.tempoMedioHoras});

  static const zero = MesTotais(ocorrencias: 0, resolvidas: 0, tempoMedioHoras: 0);

  factory MesTotais.fromJson(Map<String, dynamic> json) => MesTotais(
        ocorrencias: (json['ocorrencias'] as num?)?.toInt() ?? 0,
        resolvidas: (json['resolvidas'] as num?)?.toInt() ?? 0,
        tempoMedioHoras: (json['tempo_medio_horas'] as num?)?.toDouble() ?? 0,
      );
}

/// Um ponto da série de tendência (um mês). [mesIso] no formato 'YYYY-MM'.
class PontoTendencia {
  final String mesIso;
  final int ocorrencias;
  final int resolvidas;

  const PontoTendencia({required this.mesIso, required this.ocorrencias, required this.resolvidas});

  factory PontoTendencia.fromJson(Map<String, dynamic> json) => PontoTendencia(
        mesIso: json['mes'] as String,
        ocorrencias: (json['ocorrencias'] as num?)?.toInt() ?? 0,
        resolvidas: (json['resolvidas'] as num?)?.toInt() ?? 0,
      );
}

class DashboardStats {
  final MesTotais mesAtual;
  final MesTotais mesAnterior;
  final List<PontoTendencia> serie;
  final Map<String, int> porTipo;
  final Map<String, int> porStatus;
  final int alertasAtivos;
  final List<Ocorrencia> ultimasOcorrencias;

  const DashboardStats({
    required this.mesAtual,
    required this.mesAnterior,
    required this.serie,
    required this.porTipo,
    required this.porStatus,
    required this.alertasAtivos,
    required this.ultimasOcorrencias,
  });

  static const empty = DashboardStats(
    mesAtual: MesTotais.zero,
    mesAnterior: MesTotais.zero,
    serie: [],
    porTipo: {},
    porStatus: {},
    alertasAtivos: 0,
    ultimasOcorrencias: [],
  );
}
