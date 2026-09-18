import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/alertas_sanitarios/domain/entities/alerta_sanitario.dart';

class AlertaSanitarioSupabaseDatasource {
  Future<List<AlertaSanitario>> listar(String municipioId) async {
    final data = await supabase
        .from('alertas_sanitarios')
        .select()
        .eq('municipio_id', municipioId)
        .order('criado_em', ascending: false);
    return (data as List).map((e) => _fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<AlertaSanitario> criar({
    required String municipioId,
    required AlertaSanitarioTipo tipo,
    required String descricao,
    required double latitude,
    required double longitude,
    required double raioMetros,
    required String criadoPor,
  }) async {
    final data = await supabase
        .from('alertas_sanitarios')
        .insert({
          'municipio_id': municipioId,
          'tipo': tipo.dbValue,
          'descricao': descricao,
          'latitude': latitude,
          'longitude': longitude,
          'raio_metros': raioMetros,
          'criado_por': criadoPor,
        })
        .select()
        .single();
    return _fromMap(data);
  }

  Future<AlertaSanitario> encerrar(String id) async {
    final data = await supabase
        .from('alertas_sanitarios')
        .update({'ativo': false, 'encerrado_em': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return _fromMap(data);
  }

  AlertaSanitario _fromMap(Map<String, dynamic> map) => AlertaSanitario(
        id: map['id'] as String,
        municipioId: map['municipio_id'] as String,
        tipo: AlertaSanitarioTipo.fromString(map['tipo'] as String),
        descricao: map['descricao'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        raioMetros: (map['raio_metros'] as num).toDouble(),
        ativo: map['ativo'] as bool,
        criadoPor: map['criado_por'] as String,
        criadoEm: DateTime.parse(map['criado_em'] as String).toLocal(),
        encerradoEm: map['encerrado_em'] != null
            ? DateTime.parse(map['encerrado_em'] as String).toLocal()
            : null,
      );
}
