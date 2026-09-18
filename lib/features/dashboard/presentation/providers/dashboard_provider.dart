import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/dashboard/data/datasources/dashboard_supabase_datasource.dart';
import 'package:sisan/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/features/dashboard/domain/repositories/i_dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  return DashboardRepositoryImpl(DashboardSupabaseDatasource());
});

class DashboardNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    final usuario = await ref.watch(authProvider.future);
    if (usuario == null || usuario.municipioId.isEmpty) return DashboardStats.empty;
    return ref.read(dashboardRepositoryProvider).carregar(usuario.municipioId);
  }

  Future<void> recarregar() async {
    ref.invalidateSelf();
    await future;
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardNotifier, DashboardStats>(DashboardNotifier.new);
