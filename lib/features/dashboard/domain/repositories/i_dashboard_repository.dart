import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';

abstract interface class IDashboardRepository {
  Future<DashboardStats> carregar(String municipioId);
}
