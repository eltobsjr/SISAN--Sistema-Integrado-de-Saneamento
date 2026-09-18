import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/notificacoes/data/datasources/notificacao_supabase_datasource.dart';
import 'package:sisan/features/notificacoes/data/repositories/notificacao_repository_impl.dart';
import 'package:sisan/features/notificacoes/domain/entities/notificacao.dart';
import 'package:sisan/features/notificacoes/domain/repositories/i_notificacao_repository.dart';

final notificacaoRepositoryProvider = Provider<INotificacaoRepository>((ref) {
  return NotificacaoRepositoryImpl(NotificacaoSupabaseDatasource());
});

class NotificacoesNotifier extends AsyncNotifier<List<Notificacao>> {
  @override
  Future<List<Notificacao>> build() async {
    final usuario = ref.watch(authProvider).valueOrNull;
    if (usuario == null) return [];

    final userId = usuario.id;
    final repo = ref.read(notificacaoRepositoryProvider);

    // `.stream()` é mais estável que `onPostgresChanges` — emite a lista
    // completa a cada INSERT/UPDATE/DELETE (ver referencia/erros-herdados-do-sigau.md).
    final sub = supabase
        .from('notificacoes')
        .stream(primaryKey: ['id'])
        .eq('usuario_id', userId)
        .order('criado_em', ascending: false)
        .listen((rows) {
      state = AsyncData(rows.map((e) => NotificacaoSupabaseDatasource.fromMap(e)).toList());
    });
    ref.onDispose(sub.cancel);

    return repo.listarPorUsuario(userId);
  }

  Future<void> marcarComoLida(String id) async {
    await ref.read(notificacaoRepositoryProvider).marcarComoLida(id);
    state = AsyncData(
      (state.valueOrNull ?? []).map((n) => n.id == id ? n.copyWith(lida: true) : n).toList(),
    );
  }

  Future<void> excluir(String id) async {
    final anterior = state.valueOrNull ?? [];
    state = AsyncData(anterior.where((n) => n.id != id).toList());
    try {
      await ref.read(notificacaoRepositoryProvider).excluir(id);
    } catch (_) {
      state = AsyncData(anterior);
      rethrow;
    }
  }

  Future<void> marcarTodasComoLidas() async {
    final usuario = ref.read(authProvider).valueOrNull;
    if (usuario == null) return;
    await ref.read(notificacaoRepositoryProvider).marcarTodasComoLidas(usuario.id);
    state = AsyncData((state.valueOrNull ?? []).map((n) => n.copyWith(lida: true)).toList());
  }
}

final notificacoesProvider = AsyncNotifierProvider<NotificacoesNotifier, List<Notificacao>>(
  NotificacoesNotifier.new,
);

/// Conta de notificações não lidas — alimenta o badge no sininho.
final notificacoesNaoLidasProvider = Provider<int>((ref) {
  final lista = ref.watch(notificacoesProvider).valueOrNull ?? [];
  return lista.where((n) => !n.lida).length;
});
