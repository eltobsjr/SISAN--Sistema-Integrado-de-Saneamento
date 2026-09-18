import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/core/security/exif_remover.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';

class OrdemServicoSupabaseDatasource {
  // Join com `ocorrencias` — a fila do técnico nunca é útil sem os dados da
  // ocorrência que originou a OS.
  static const _select = '*, ocorrencias(*)';

  Future<List<OrdemServico>> listarFila(String municipioId) async {
    final data = await supabase
        .from('ordens_servico')
        .select(_select)
        .eq('municipio_id', municipioId)
        .neq('status', OrdemServicoStatus.concluida.dbValue)
        .order('criado_em', ascending: true);
    return (data as List)
        .map((m) => _fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<OrdemServico> buscarPorId(String id) async {
    final data = await supabase
        .from('ordens_servico')
        .select(_select)
        .eq('id', id)
        .single();
    return _fromMap(data);
  }

  Future<OrdemServico> aceitar({
    required String osId,
    required String tecnicoId,
  }) async {
    final result = await supabase
        .from('ordens_servico')
        .update({
          'tecnico_id': tecnicoId,
          'status': OrdemServicoStatus.aceita.dbValue,
          'aceita_em': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', osId)
        .select(_select)
        .single();
    return _fromMap(result);
  }

  Future<OrdemServico> registrarChegada({
    required String osId,
    required double latitude,
    required double longitude,
  }) async {
    final result = await supabase
        .from('ordens_servico')
        .update({
          'status': OrdemServicoStatus.aCaminho.dbValue,
          'chegada_em': DateTime.now().toUtc().toIso8601String(),
          'chegada_latitude': latitude,
          'chegada_longitude': longitude,
        })
        .eq('id', osId)
        .select(_select)
        .single();
    return _fromMap(result);
  }

  Future<OrdemServico> concluir({
    required String osId,
    required Map<String, bool> checklist,
    required List<File> fotosDepois,
  }) async {
    final fotosUrls = <String>[];
    if (!kIsWeb) {
      for (var i = 0; i < fotosDepois.length; i++) {
        final foto = fotosDepois[i];
        final raw = await foto.readAsBytes();
        final bytes = await ExifRemover.strip(raw);
        final ext = foto.path.split('.').last;
        final path = 'depois/${osId}_$i.$ext';
        await supabase.storage.from('ocorrencias-fotos').uploadBinary(path, bytes);
        fotosUrls.add(supabase.storage.from('ocorrencias-fotos').getPublicUrl(path));
      }
    }

    final result = await supabase
        .from('ordens_servico')
        .update({
          'status': OrdemServicoStatus.concluida.dbValue,
          'checklist': checklist,
          'fotos_depois': fotosUrls,
          'concluida_em': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', osId)
        .select(_select)
        .single();
    return _fromMap(result);
  }

  OrdemServico _fromMap(Map<String, dynamic> m) {
    final checklistRaw = m['checklist'] as Map<String, dynamic>? ?? {};
    final fotosRaw = m['fotos_depois'] as List?;
    final ocorrenciaMap = m['ocorrencias'] as Map<String, dynamic>;

    return OrdemServico(
      id: m['id'] as String,
      ocorrenciaId: m['ocorrencia_id'] as String,
      municipioId: m['municipio_id'] as String,
      tecnicoId: m['tecnico_id'] as String?,
      status: OrdemServicoStatus.fromString(m['status'] as String),
      checklist: checklistRaw.map((k, v) => MapEntry(k, v as bool)),
      fotosDepois: fotosRaw?.cast<String>() ?? [],
      aceitaEm: m['aceita_em'] != null
          ? DateTime.parse(m['aceita_em'] as String).toLocal()
          : null,
      chegadaEm: m['chegada_em'] != null
          ? DateTime.parse(m['chegada_em'] as String).toLocal()
          : null,
      concluidaEm: m['concluida_em'] != null
          ? DateTime.parse(m['concluida_em'] as String).toLocal()
          : null,
      criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
      ocorrencia: _ocorrenciaFromMap(ocorrenciaMap),
    );
  }

  Ocorrencia _ocorrenciaFromMap(Map<String, dynamic> m) {
    final fotosRaw = m['fotos'] as List?;
    return Ocorrencia(
      id: m['id'] as String,
      municipioId: m['municipio_id'] as String,
      denuncianteId: m['denunciante_id'] as String,
      tipo: OcorrenciaTipo.fromString(m['tipo'] as String),
      descricao: m['descricao'] as String,
      fotos: fotosRaw?.cast<String>() ?? [],
      endereco: m['endereco'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      status: OcorrenciaStatus.fromString(m['status'] as String),
      urgencia: OcorrenciaUrgencia.fromString(m['urgencia'] as String? ?? 'normal'),
      protocolo: m['protocolo'] as String?,
      criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
      atualizadoEm: m['atualizado_em'] != null
          ? DateTime.parse(m['atualizado_em'] as String).toLocal()
          : null,
    );
  }
}
