import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/notificacoes/domain/entities/notificacao.dart';

class NotificacaoSupabaseDatasource {
  Future<List<Notificacao>> listarPorUsuario(String usuarioId) async {
    final data = await supabase
        .from('notificacoes')
        .select()
        .eq('usuario_id', usuarioId)
        .order('criado_em', ascending: false);
    return (data as List).map((e) => fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> marcarComoLida(String id) async {
    await supabase.from('notificacoes').update({'lida': true}).eq('id', id);
  }

  Future<void> excluir(String id) async {
    await supabase.from('notificacoes').delete().eq('id', id);
  }

  Future<void> marcarTodasComoLidas(String usuarioId) async {
    await supabase
        .from('notificacoes')
        .update({'lida': true})
        .eq('usuario_id', usuarioId)
        .eq('lida', false);
  }

  static Notificacao fromMap(Map<String, dynamic> map) => Notificacao(
        id: map['id'] as String,
        municipioId: map['municipio_id'] as String,
        usuarioId: map['usuario_id'] as String,
        tipo: map['tipo'] as String,
        titulo: map['titulo'] as String,
        corpo: map['corpo'] as String,
        lida: map['lida'] as bool,
        dados: map['dados'] != null ? Map<String, dynamic>.from(map['dados'] as Map) : null,
        criadoEm: DateTime.parse(map['criado_em'] as String).toLocal(),
      );
}
