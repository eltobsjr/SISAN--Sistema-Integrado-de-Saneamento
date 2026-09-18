import 'package:sisan/features/notificacoes/data/datasources/notificacao_supabase_datasource.dart';
import 'package:sisan/features/notificacoes/domain/entities/notificacao.dart';
import 'package:sisan/features/notificacoes/domain/repositories/i_notificacao_repository.dart';

class NotificacaoRepositoryImpl implements INotificacaoRepository {
  NotificacaoRepositoryImpl(this._ds);
  final NotificacaoSupabaseDatasource _ds;

  @override
  Future<List<Notificacao>> listarPorUsuario(String usuarioId) => _ds.listarPorUsuario(usuarioId);

  @override
  Future<void> marcarComoLida(String id) => _ds.marcarComoLida(id);

  @override
  Future<void> marcarTodasComoLidas(String usuarioId) => _ds.marcarTodasComoLidas(usuarioId);

  @override
  Future<void> excluir(String id) => _ds.excluir(id);
}
