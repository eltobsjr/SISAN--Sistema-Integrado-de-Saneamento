import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/features/dashboard/domain/entities/insight_dashboard.dart';

abstract interface class IDashboardRepository {
  Future<DashboardStats> carregar(String municipioId);
  Future<InsightDashboard?> carregarInsight();
}
