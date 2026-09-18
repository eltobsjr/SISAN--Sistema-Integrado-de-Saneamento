import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/core/security/exif_remover.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';

class OcorrenciaSupabaseDatasource {
  Future<List<Ocorrencia>> listarMinhas(String usuarioId) async {
    final data = await supabase
        .from('ocorrencias')
        .select()
        .eq('denunciante_id', usuarioId)
        .order('criado_em', ascending: false);
    return (data as List)
        .map((m) => _fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<Ocorrencia> buscarPorId(String id) async {
    final data =
        await supabase.from('ocorrencias').select().eq('id', id).single();
    return _fromMap(data);
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

    final result =
        await supabase.from('ocorrencias').insert(payload).select().single();
    return _fromMap(result);
  }

  Ocorrencia _fromMap(Map<String, dynamic> m) {
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

  // Gera UUID v4 sem dependência externa (mesmo padrão do SIGAU) — usado
  // pra saber o id da ocorrência antes do INSERT e nomear as fotos no storage.
  static String _uuid() {
    final rng = Random.secure();
    final b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(List<int> s) =>
        s.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${hex(b.sublist(0, 4))}-${hex(b.sublist(4, 6))}-'
        '${hex(b.sublist(6, 8))}-${hex(b.sublist(8, 10))}-${hex(b.sublist(10))}';
  }
}
