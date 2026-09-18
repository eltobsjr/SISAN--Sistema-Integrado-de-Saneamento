import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/domain/repositories/i_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Stream de mudanças de sessão do Supabase. Usado pelo [AuthNotifier] para
/// reagir a login/logout e pelo `routerProvider` como `refreshListenable`.
final supabaseAuthStreamProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

class AuthNotifier extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    ref.listen<AsyncValue<AuthState>>(supabaseAuthStreamProvider, (prev, next) {
      final event = next.valueOrNull?.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.signedOut) {
        ref.invalidateSelf();
      }
    });

    final session = supabase.auth.currentSession;
    if (session == null) return null;
    return _fetchUsuario(session.user.id);
  }

  Future<Usuario?> _fetchUsuario(String id) async {
    final data = await supabase
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;

    return Usuario(
      id: data['id'] as String,
      email: data['email'] as String,
      nome: data['nome'] as String? ?? '',
      perfil: PerfilUsuario.values.firstWhere(
        (p) => p.name == (data['perfil'] as String? ?? ''),
        orElse: () => PerfilUsuario.cidadao,
      ),
      municipioId: data['municipio_id']?.toString() ?? '',
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Usuario?>(
  AuthNotifier.new,
);
