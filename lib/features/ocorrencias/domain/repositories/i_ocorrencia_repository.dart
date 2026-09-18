import 'dart:io';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
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
}
