import 'dart:io';

import 'package:sisan/features/ordens_de_servico/data/datasources/ordem_servico_supabase_datasource.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/domain/repositories/i_ordem_servico_repository.dart';

class OrdemServicoRepositoryImpl implements IOrdemServicoRepository {
  OrdemServicoRepositoryImpl(this._ds);

  final OrdemServicoSupabaseDatasource _ds;

  @override
  Future<List<OrdemServico>> listarFila(String municipioId) =>
      _ds.listarFila(municipioId);

  @override
  Future<OrdemServico> buscarPorId(String id) => _ds.buscarPorId(id);

  @override
  Future<OrdemServico> aceitar({
    required String osId,
    required String tecnicoId,
  }) => _ds.aceitar(osId: osId, tecnicoId: tecnicoId);

  @override
  Future<OrdemServico> registrarChegada({
    required String osId,
    required double latitude,
    required double longitude,
  }) => _ds.registrarChegada(osId: osId, latitude: latitude, longitude: longitude);

  @override
  Future<OrdemServico> concluir({
    required String osId,
    required Map<String, bool> checklist,
    required List<File> fotosDepois,
  }) => _ds.concluir(osId: osId, checklist: checklist, fotosDepois: fotosDepois);
}
