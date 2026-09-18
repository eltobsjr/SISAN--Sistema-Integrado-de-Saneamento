import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/app/router.dart';
import 'package:sisan/core/theme/app_theme.dart';
import 'package:sisan/shared/providers/connectivity_provider.dart';
import 'package:sisan/shared/services/sync_service.dart';

class SisanApp extends ConsumerWidget {
  const SisanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Inicializa o SyncService pra começar a escutar conectividade e
    // processar a fila offline assim que houver rede.
    ref.watch(syncServiceProvider);

    return MaterialApp.router(
      title: 'SISAN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('pt', 'BR'),
      routerConfig: router,
      builder: (context, child) => _OfflineWrapper(child: child ?? const SizedBox()),
    );
  }
}

/// Envolve toda a árvore de rotas com um banner laranja quando offline —
/// adaptado do `_OfflineWrapper` do SIGAU.
class _OfflineWrapper extends ConsumerWidget {
  const _OfflineWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStreamProvider);
    final isOffline = connectivity.whenData((v) => !v).valueOrNull ?? false;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: isOffline
              ? Material(
                  color: Colors.orange.shade700,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sem conexão — dados serão sincronizados ao reconectar',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}
