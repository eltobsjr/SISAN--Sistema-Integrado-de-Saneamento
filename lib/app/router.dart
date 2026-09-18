import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/pages/alerta_detalhe_page.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/pages/alertas_sanitarios_page.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/pages/criar_alerta_page.dart';
import 'package:sisan/features/auth/presentation/pages/cadastro_page.dart';
import 'package:sisan/features/auth/presentation/pages/login_page.dart';
import 'package:sisan/features/auth/presentation/pages/splash_page.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/home/presentation/pages/cidadao_home_page.dart';
import 'package:sisan/features/home/presentation/pages/gestor_home_page.dart';
import 'package:sisan/features/home/presentation/pages/tecnico_home_page.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/pages/minhas_ocorrencias_page.dart';
import 'package:sisan/features/ocorrencias/presentation/pages/nova_ocorrencia_page.dart';
import 'package:sisan/features/ocorrencias/presentation/pages/ocorrencia_detalhe_page.dart';
import 'package:sisan/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sisan/features/notificacoes/presentation/pages/notificacoes_page.dart';
import 'package:sisan/features/ordens_de_servico/presentation/pages/ordem_servico_detalhe_page.dart';
import 'package:sisan/features/ordens_de_servico/presentation/pages/ordens_servico_page.dart';

// `/` (splash) de propósito NÃO entra aqui: é um estado transitório só
// enquanto `authProvider` resolve, nunca um destino válido — se entrasse,
// um usuário sem sessão nenhuma (primeiro uso do app) ficaria preso na
// splash pra sempre, porque nada nunca o tiraria de uma "rota pública".
const _rotasPublicas = ['/login', '/cadastro'];
const _rotasHome = ['/cidadao', '/tecnico', '/gestor'];

String _homePara(PerfilUsuario perfil) => switch (perfil) {
      PerfilUsuario.cidadao => '/cidadao',
      PerfilUsuario.tecnico => '/tecnico',
      PerfilUsuario.gestor => '/gestor',
    };

/// Notifica o GoRouter tanto em mudanças de sessão (login/logout) quanto em
/// mudanças do [authProvider] (perfil resolvido de forma assíncrona após o
/// login) — sem o segundo listener, o redirect rodaria com o perfil ainda em
/// `AsyncLoading` e o usuário ficaria preso na splash.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _authSub = supabase.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
      onError: (_, _) {},
    );
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }

  StreamSubscription? _authSub;

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final authState = ref.read(authProvider);

      if (authState.isLoading) {
        // Sessão/perfil ainda resolvendo: só a splash pode ficar parada.
        return loc == '/' ? null : '/';
      }

      final usuario = authState.valueOrNull;
      if (usuario == null) {
        // Sem sessão, ou sessão sem linha em `usuarios` (edge case) — em
        // ambos os casos não há perfil pra decidir a home.
        return _rotasPublicas.contains(loc) ? null : '/login';
      }

      final home = _homePara(usuario.perfil);

      // Splash/login/cadastro com sessão já resolvida: manda pra home certa.
      if (loc == '/' || _rotasPublicas.contains(loc)) return home;

      // Guard de rota por perfil: cada home só é acessível pelo próprio perfil.
      if (_rotasHome.contains(loc) && loc != home) return home;

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: '/cidadao',
        builder: (context, state) => const CidadaoHomePage(),
      ),
      GoRoute(
        path: '/tecnico',
        builder: (context, state) => const TecnicoHomePage(),
      ),
      GoRoute(
        path: '/gestor',
        builder: (context, state) => const GestorHomePage(),
      ),
      GoRoute(
        path: '/ocorrencias/nova',
        builder: (context, state) => const NovaOcorrenciaPage(),
      ),
      GoRoute(
        path: '/ocorrencias',
        builder: (context, state) => const MinhasOcorrenciasPage(),
      ),
      GoRoute(
        path: '/ocorrencias/:id',
        builder: (context, state) => OcorrenciaDetalhePage(
          id: state.pathParameters['id']!,
          ocorrencia: state.extra as Ocorrencia?,
        ),
      ),
      GoRoute(
        path: '/ordens-de-servico',
        builder: (context, state) => const OrdensServicoPage(),
      ),
      GoRoute(
        path: '/ordens-de-servico/:id',
        builder: (context, state) => OrdemServicoDetalhePage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/notificacoes',
        builder: (context, state) => const NotificacoesPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/alertas-sanitarios',
        builder: (context, state) => const AlertasSanitariosPage(),
      ),
      GoRoute(
        path: '/alertas-sanitarios/criar',
        builder: (context, state) => const CriarAlertaPage(),
      ),
      GoRoute(
        path: '/alertas-sanitarios/:id',
        builder: (context, state) => AlertaDetalhePage(id: state.pathParameters['id']!),
      ),
    ],
  );
});
