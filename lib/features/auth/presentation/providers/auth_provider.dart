import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/core/notifications/push_notifications_service.dart';
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
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        ref.invalidateSelf();
      }
    });

    final session = supabase.auth.currentSession;
    if (session == null) {
      await PushNotificationsService.logout();
      return null;
    }
    Usuario? usuario;
    try {
      usuario = await _fetchUsuario(session.user.id);
      if (usuario != null) await _salvarCache(usuario);
    } catch (e) {
      // Sem rede na abertura do app: usa o último perfil conhecido deste
      // mesmo usuário, em vez de mandar quem tem sessão salva pro login.
      usuario = await _lerCache(session.user.id);
      if (usuario == null) rethrow;
    }
    if (usuario != null) {
      await PushNotificationsService.login(usuario.id);
    }
    return usuario;
  }

  static const _cacheKey = 'sisan_usuario_cache';
  static const _storage = FlutterSecureStorage();

  Future<void> _salvarCache(Usuario u) async {
    try {
      await _storage.write(key: _cacheKey, value: jsonEncode(u.toJson()));
    } catch (e) {
      debugPrint('cache de perfil indisponível: $e');
    }
  }

  Future<Usuario?> _lerCache(String id) async {
    try {
      final raw = await _storage.read(key: _cacheKey);
      if (raw == null) return null;
      final u = Usuario.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return u.id == id ? u : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _limparCache() async {
    try {
      await _storage.delete(key: _cacheKey);
    } catch (_) {}
  }

  Future<Usuario?> _fetchUsuario(String id) async {
    final data = await supabase.from('usuarios').select().eq('id', id).maybeSingle();
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
    await _limparCache();
    await PushNotificationsService.logout();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Usuario?>(AuthNotifier.new);
