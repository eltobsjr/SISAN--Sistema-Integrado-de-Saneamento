import 'dart:io';

import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';

abstract interface class IOrdemServicoRepository {
  /// Fila do município do técnico autenticado (RLS já restringe): pendentes
  /// e as que já estão com ele (aceita/a_caminho), nunca as concluídas.
  Future<List<OrdemServico>> listarFila(String municipioId);

  Future<OrdemServico> buscarPorId(String id);

  Future<OrdemServico> aceitar({required String osId, required String tecnicoId});

  Future<OrdemServico> registrarChegada({
    required String osId,
    required double latitude,
    required double longitude,
  });

  Future<OrdemServico> concluir({
    required String osId,
    required Map<String, bool> checklist,
    required List<File> fotosDepois,
  });
}
