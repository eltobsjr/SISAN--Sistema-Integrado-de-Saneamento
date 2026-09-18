import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/features/ocorrencias/data/datasources/ocorrencia_supabase_datasource.dart';

class DashboardSupabaseDatasource {
  final _ocorrenciasDs = OcorrenciaSupabaseDatasource();

  Future<DashboardStats> carregarStats(String municipioId) async {
    if (municipioId.isEmpty) return DashboardStats.empty;

    final statsRaw = await supabase.rpc('dashboard_stats', params: {'p_municipio_id': municipioId});
    final stats = statsRaw as Map<String, dynamic>;

    final recentes = await _ocorrenciasDs.listarDoMunicipio(municipioId);

    return DashboardStats(
      mesAtual: MesTotais.fromJson((stats['mes_atual'] as Map).cast<String, dynamic>()),
      mesAnterior: MesTotais.fromJson((stats['mes_anterior'] as Map).cast<String, dynamic>()),
      serie: ((stats['serie'] as List?) ?? const [])
          .map((e) => PontoTendencia.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      porTipo: (stats['por_tipo'] as Map? ?? const {}).map((k, v) => MapEntry(k as String, (v as num).toInt())),
      porStatus: (stats['por_status'] as Map? ?? const {}).map((k, v) => MapEntry(k as String, (v as num).toInt())),
      alertasAtivos: (stats['alertas_ativos'] as num?)?.toInt() ?? 0,
      ultimasOcorrencias: recentes.take(5).toList(),
    );
  }
}
