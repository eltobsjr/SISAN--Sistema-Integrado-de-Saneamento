import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sisan/core/constants/ocorrencia_risco.dart';
import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/core/security/exif_remover.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';

class OcorrenciaSupabaseDatasource {
  /// `prioridade` é um campo computado no banco (função `prioridade(ocorrencias)`).
  static const select = '*, prioridade';

  Future<List<Ocorrencia>> listarMinhas(String usuarioId) async {
    final data = await supabase
        .from('ocorrencias')
        .select()
        .eq('denunciante_id', usuarioId)
        .order('criado_em', ascending: false);
    return (data as List).map((m) => fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<Ocorrencia>> listarDoMunicipio(String municipioId) async {
    final data = await supabase
        .from('ocorrencias')
        .select(select)
        .eq('municipio_id', municipioId)
        .neq('status', OcorrenciaStatus.arquivada.dbValue)
        .order('criado_em', ascending: false);
    return (data as List).map((m) => fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<Ocorrencia> buscarPorId(String id) async {
    final data = await supabase.from('ocorrencias').select(select).eq('id', id).single();
    return fromMap(data);
  }

  Future<Ocorrencia> criar({
    required String municipioId,
    required String denuncianteId,
    required OcorrenciaTipo tipo,
    required String descricao,
    List<File> fotos = const [],
    String? endereco,
    double? latitude,
    double? longitude,
  }) async {
    final id = _uuid();

    final fotosUrls = <String>[];
    if (!kIsWeb && fotos.isNotEmpty) {
      for (var i = 0; i < fotos.length; i++) {
        final foto = fotos[i];
        final raw = await foto.readAsBytes();
        final bytes = await ExifRemover.strip(raw);
        final ext = foto.path.split('.').last;
        final path = '$municipioId/${id}_$i.$ext';
        await supabase.storage.from('ocorrencias-fotos').uploadBinary(path, bytes);
        fotosUrls.add(supabase.storage.from('ocorrencias-fotos').getPublicUrl(path));
      }
    }

    final payload = <String, dynamic>{
      'id': id,
      'municipio_id': municipioId,
      'denunciante_id': denuncianteId,
      'tipo': tipo.dbValue,
      'descricao': descricao,
      'fotos': fotosUrls,
      'endereco': ?endereco,
      'latitude': ?latitude,
      'longitude': ?longitude,
    };

    final result = await supabase.from('ocorrencias').insert(payload).select().single();
    return fromMap(result);
  }

  /// Abertas do município do usuário, da mais prioritária para a menos.
  Future<List<Ocorrencia>> prioridadesAbertas({int limite = 5}) async {
    final data = await supabase.rpc('prioridades_abertas', params: {'p_limite': limite}).select(select);
    return (data as List).map((m) => fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<List<OcorrenciaProxima>> proximas({
    required double latitude,
    required double longitude,
    required OcorrenciaTipo tipo,
  }) async {
    final data = await supabase.rpc(
      'ocorrencias_proximas',
      params: {'p_latitude': latitude, 'p_longitude': longitude, 'p_tipo': tipo.dbValue},
    );
    return (data as List).map((e) {
      final m = e as Map<String, dynamic>;
      return OcorrenciaProxima(
        id: m['id'] as String,
        protocolo: m['protocolo'] as String?,
        descricao: m['descricao'] as String,
        endereco: m['endereco'] as String?,
        criadoEm: DateTime.parse(m['criado_em'] as String).toLocal(),
        confirmacoes: (m['confirmacoes'] as num?)?.toInt() ?? 0,
        distanciaM: (m['distancia_m'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  /// Devolve o total de confirmações depois desta.
  Future<int> confirmar(String ocorrenciaId) async {
    final total = await supabase.rpc('confirmar_ocorrencia', params: {'p_ocorrencia_id': ocorrenciaId});
    return (total as num).toInt();
  }

  Future<Ocorrencia> reclassificar(String ocorrenciaId, OcorrenciaUrgencia urgencia, OcorrenciaRisco risco) async {
    final data = await supabase
        .rpc(
          'reclassificar_ocorrencia',
          params: {'p_ocorrencia_id': ocorrenciaId, 'p_urgencia': urgencia.dbValue, 'p_risco_saude': risco.dbValue},
        )
        .select(select)
        .single();
    return fromMap(data);
  }

  Future<Ocorrencia> avaliarResolucao(String ocorrenciaId, {required bool resolvido}) async {
    final data = await supabase
        .rpc('avaliar_resolucao', params: {'p_ocorrencia_id': ocorrenciaId, 'p_resolvido': resolvido})
        .select(select)
        .single();
    return fromMap(data);
  }

  Future<EvidenciaResolucao?> evidenciasResolucao(String ocorrenciaId) async {
    final data = await supabase.rpc('evidencias_resolucao', params: {'p_ocorrencia_id': ocorrenciaId});
    final lista = data as List;
    if (lista.isEmpty) return null;
    final m = lista.first as Map<String, dynamic>;
    return EvidenciaResolucao(
      fotos: (m['fotos_depois'] as List?)?.cast<String>() ?? const [],
      concluidaEm: m['concluida_em'] != null ? DateTime.parse(m['concluida_em'] as String).toLocal() : null,
    );
  }

  /// Mapeamento único da linha de `ocorrencias` — também usado pelo join da OS.
  static Ocorrencia fromMap(Map<String, dynamic> m) {
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
      atualizadoEm: m['atualizado_em'] != null ? DateTime.parse(m['atualizado_em'] as String).toLocal() : null,
      riscoSaude: OcorrenciaRisco.fromString(m['risco_saude'] as String?),
      classificadoEm: m['classificado_em'] != null ? DateTime.parse(m['classificado_em'] as String).toLocal() : null,
      classificacaoManual: m['classificacao_manual'] as bool? ?? false,
      confirmacoes: (m['confirmacoes'] as num?)?.toInt() ?? 0,
      avaliacaoCidadao: m['avaliacao_cidadao'] as String?,
      prioridade: (m['prioridade'] as num?)?.toInt(),
    );
  }

  // Gera UUID v4 sem dependência externa (mesmo padrão do SIGAU) — usado
  // pra saber o id da ocorrência antes do INSERT e nomear as fotos no storage.
  static String _uuid() {
    final rng = Random.secure();
    final b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(List<int> s) => s.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${hex(b.sublist(0, 4))}-${hex(b.sublist(4, 6))}-'
        '${hex(b.sublist(6, 8))}-${hex(b.sublist(8, 10))}-${hex(b.sublist(10))}';
  }
}
