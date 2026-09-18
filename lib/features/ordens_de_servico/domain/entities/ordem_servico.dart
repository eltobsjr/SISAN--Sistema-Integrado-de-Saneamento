import 'package:sisan/core/constants/checklist_encerramento.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';

class OrdemServico {
  final String id;
  final String ocorrenciaId;
  final String municipioId;
  final String? tecnicoId;
  final OrdemServicoStatus status;
  final Map<String, bool> checklist;
  final List<String> fotosDepois;
  final DateTime? aceitaEm;
  final DateTime? chegadaEm;
  final DateTime? concluidaEm;
  final DateTime criadoEm;

  /// A ocorrência que originou esta OS — sempre vem junto (join), já que a
  /// fila do técnico não faz sentido sem tipo/descrição/localização.
  final Ocorrencia ocorrencia;

  const OrdemServico({
    required this.id,
    required this.ocorrenciaId,
    required this.municipioId,
    this.tecnicoId,
    required this.status,
    this.checklist = const {},
    this.fotosDepois = const [],
    this.aceitaEm,
    this.chegadaEm,
    this.concluidaEm,
    required this.criadoEm,
    required this.ocorrencia,
  });

  /// Verdadeiro só quando todo item exigido pro tipo desta ocorrência
  /// (decisions/005) está presente no checklist e marcado.
  bool get checklistCompleto {
    final itens = ChecklistEncerramento.itensPara(ocorrencia.tipo);
    if (itens.isEmpty) return false;
    return itens.every((item) => checklist[item] == true);
  }

  /// Usado pra atualização otimista local (offline e enquanto aguarda o
  /// round-trip online) — nunca sobrescreve [ocorrencia], que só muda via
  /// refetch real.
  OrdemServico copyWith({
    String? tecnicoId,
    OrdemServicoStatus? status,
    Map<String, bool>? checklist,
    List<String>? fotosDepois,
    DateTime? aceitaEm,
    DateTime? chegadaEm,
    DateTime? concluidaEm,
  }) {
    return OrdemServico(
      id: id,
      ocorrenciaId: ocorrenciaId,
      municipioId: municipioId,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      status: status ?? this.status,
      checklist: checklist ?? this.checklist,
      fotosDepois: fotosDepois ?? this.fotosDepois,
      aceitaEm: aceitaEm ?? this.aceitaEm,
      chegadaEm: chegadaEm ?? this.chegadaEm,
      concluidaEm: concluidaEm ?? this.concluidaEm,
      criadoEm: criadoEm,
      ocorrencia: ocorrencia,
    );
  }
}
