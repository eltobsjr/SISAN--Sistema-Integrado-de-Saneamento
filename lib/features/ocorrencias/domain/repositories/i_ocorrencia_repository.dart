import 'dart:io';

import 'package:sisan/core/constants/ocorrencia_risco.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';

abstract interface class IOcorrenciaRepository {
  /// Ocorrências do cidadão [usuarioId] (RLS já restringe ao dono de qualquer forma).
  Future<List<Ocorrencia>> listarMinhas(String usuarioId);

  /// Todas as ocorrências ativas do município [municipioId] — usado no mapa
  /// (transparência pública, decisions em `ocorrencias_select_publica_no_municipio`).
  Future<List<Ocorrencia>> listarDoMunicipio(String municipioId);

  Future<Ocorrencia> buscarPorId(String id);

  Future<Ocorrencia> criar({
    required String municipioId,
    required String denuncianteId,
    required OcorrenciaTipo tipo,
    required String descricao,
    List<File> fotos = const [],
    String? endereco,
    double? latitude,
    double? longitude,
  });

  /// Abertas do município, ordenadas pela prioridade calculada no banco.
  Future<List<Ocorrencia>> prioridadesAbertas({int limite = 5});

  /// Relatos abertos do mesmo tipo perto do ponto — evita duplicar.
  Future<List<OcorrenciaProxima>> proximas({
    required double latitude,
    required double longitude,
    required OcorrenciaTipo tipo,
  });

  /// Morador confirma um relato existente; devolve o total de confirmações.
  Future<int> confirmar(String ocorrenciaId);

  /// Gestor corrige a classificação da IA.
  Future<Ocorrencia> reclassificar(String ocorrenciaId, OcorrenciaUrgencia urgencia, OcorrenciaRisco risco);

  /// Cidadão diz se o problema foi resolvido; "não" reabre a OS.
  Future<Ocorrencia> avaliarResolucao(String ocorrenciaId, {required bool resolvido});

  Future<EvidenciaResolucao?> evidenciasResolucao(String ocorrenciaId);
}
