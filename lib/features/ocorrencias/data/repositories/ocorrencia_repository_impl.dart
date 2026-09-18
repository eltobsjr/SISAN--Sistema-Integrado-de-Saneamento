import 'dart:io';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/features/ocorrencias/data/datasources/ocorrencia_supabase_datasource.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/domain/repositories/i_ocorrencia_repository.dart';

class OcorrenciaRepositoryImpl implements IOcorrenciaRepository {
  OcorrenciaRepositoryImpl(this._ds);

  final OcorrenciaSupabaseDatasource _ds;

  @override
  Future<List<Ocorrencia>> listarMinhas(String usuarioId) =>
      _ds.listarMinhas(usuarioId);

  @override
  Future<List<Ocorrencia>> listarDoMunicipio(String municipioId) =>
      _ds.listarDoMunicipio(municipioId);

  @override
  Future<Ocorrencia> buscarPorId(String id) => _ds.buscarPorId(id);

  @override
  Future<Ocorrencia> criar({
    required String municipioId,
    required String denuncianteId,
    required OcorrenciaTipo tipo,
    required String descricao,
    List<File> fotos = const [],
    String? endereco,
    double? latitude,
    double? longitude,
  }) => _ds.criar(
        municipioId: municipioId,
        denuncianteId: denuncianteId,
        tipo: tipo,
        descricao: descricao,
        fotos: fotos,
        endereco: endereco,
        latitude: latitude,
        longitude: longitude,
      );
}
