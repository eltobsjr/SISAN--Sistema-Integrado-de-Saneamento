import 'package:sisan/core/constants/ocorrencia_risco.dart';
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

  /// Classificação: nível de risco e quando foi feita (null = IA ainda não
  /// respondeu). [classificacaoManual] = corrigida pelo gestor.
  final OcorrenciaRisco? riscoSaude;
  final DateTime? classificadoEm;
  final bool classificacaoManual;

  /// Outros moradores que confirmaram o mesmo problema.
  final int confirmacoes;

  /// 'resolvido' / 'nao_resolvido', respondido pelo cidadão após a conclusão.
  final String? avaliacaoCidadao;

  /// Pontuação calculada no banco (`prioridade(ocorrencias)`); null quando a
  /// consulta não pediu o campo.
  final int? prioridade;

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
    this.riscoSaude,
    this.classificadoEm,
    this.classificacaoManual = false,
    this.confirmacoes = 0,
    this.avaliacaoCidadao,
    this.prioridade,
  });

  /// Concluída pelo técnico e esperando o cidadão dizer se resolveu de fato
  /// (também depois de reaberta e concluída de novo).
  bool get aguardandoAvaliacao => status == OcorrenciaStatus.resolvida && avaliacaoCidadao != 'resolvido';
}

/// Relato aberto do mesmo tipo perto do ponto escolhido (RPC
/// `ocorrencias_proximas`), oferecido pra confirmação em vez de duplicar.
class OcorrenciaProxima {
  final String id;
  final String? protocolo;
  final String descricao;
  final String? endereco;
  final DateTime criadoEm;
  final int confirmacoes;
  final int distanciaM;

  const OcorrenciaProxima({
    required this.id,
    this.protocolo,
    required this.descricao,
    this.endereco,
    required this.criadoEm,
    required this.confirmacoes,
    required this.distanciaM,
  });
}

/// Fotos e data do reparo, mostradas ao cidadão na hora de avaliar.
class EvidenciaResolucao {
  final List<String> fotos;
  final DateTime? concluidaEm;

  const EvidenciaResolucao({this.fotos = const [], this.concluidaEm});
}

extension OcorrenciaLocal on Ocorrencia {
  /// Bairro extraído do endereço no formato do app/seed
  /// ("Rua X, 85 - Bairro, Cidade - UF"); null quando não dá pra inferir.
  String? get bairro {
    final e = endereco;
    if (e == null) return null;
    final partes = e.split(' - ');
    if (partes.length < 2) return null;
    final b = partes[1].split(',').first.trim();
    return b.isEmpty ? null : b;
  }
}
