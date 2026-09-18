import 'package:sisan/features/notificacoes/domain/entities/notificacao.dart';

abstract interface class INotificacaoRepository {
  Future<List<Notificacao>> listarPorUsuario(String usuarioId);

  Future<void> marcarComoLida(String id);

  Future<void> marcarTodasComoLidas(String usuarioId);

  Future<void> excluir(String id);
}
