import 'package:sisan/features/dashboard/data/datasources/dashboard_supabase_datasource.dart';
import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/features/dashboard/domain/entities/insight_dashboard.dart';
import 'package:sisan/features/dashboard/domain/repositories/i_dashboard_repository.dart';

class DashboardRepositoryImpl implements IDashboardRepository {
  DashboardRepositoryImpl(this._ds);

  final DashboardSupabaseDatasource _ds;

  @override
  Future<DashboardStats> carregar(String municipioId) => _ds.carregarStats(municipioId);

  @override
  Future<InsightDashboard?> carregarInsight() => _ds.carregarInsight();
}
