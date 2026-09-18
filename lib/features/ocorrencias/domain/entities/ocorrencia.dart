import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';

class Ocorrencia {
  final String id;
  final String municipioId;
  final String denuncianteId;
  final OcorrenciaTipo tipo;
  final String descricao;
  final List<String> fotos;
  final String? endereco;
  final double? latitude;
  final double? longitude;
  final OcorrenciaStatus status;
  final OcorrenciaUrgencia urgencia;
  final String? protocolo;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  const Ocorrencia({
    required this.id,
    required this.municipioId,
    required this.denuncianteId,
    required this.tipo,
    required this.descricao,
    this.fotos = const [],
    this.endereco,
    this.latitude,
    this.longitude,
    required this.status,
    this.urgencia = OcorrenciaUrgencia.normal,
    this.protocolo,
    required this.criadoEm,
    this.atualizadoEm,
  });
}
