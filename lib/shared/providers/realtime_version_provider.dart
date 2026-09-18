import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';

/// Incrementado sempre que uma linha da tabela [table] muda no município do
/// usuário logado. Outros providers escutam este counter pra recarregar
/// dados sem acoplar lógica de stream em cada notifier — requer a tabela
/// com `REPLICA IDENTITY FULL` + publication `supabase_realtime` (migration
/// `add_municipio_centro_latlng_e_realtime`/`create_notificacoes`).
class RealtimeVersionNotifier extends FamilyNotifier<int, String> {
  @override
  int build(String table) {
    final usuario = ref.watch(authProvider).valueOrNull;
    if (usuario == null) return 0;

    final sub = supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('municipio_id', usuario.municipioId)
        .listen((_) => state++);

    ref.onDispose(sub.cancel);
    return 0;
  }
}

final realtimeVersionProvider =
    NotifierProvider.family<RealtimeVersionNotifier, int, String>(
  RealtimeVersionNotifier.new,
);
