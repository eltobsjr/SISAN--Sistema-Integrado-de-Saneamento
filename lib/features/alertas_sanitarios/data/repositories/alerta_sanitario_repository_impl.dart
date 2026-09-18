import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';
import 'package:sisan/features/alertas_sanitarios/data/datasources/alerta_sanitario_supabase_datasource.dart';
import 'package:sisan/features/alertas_sanitarios/domain/entities/alerta_sanitario.dart';
import 'package:sisan/features/alertas_sanitarios/domain/repositories/i_alerta_sanitario_repository.dart';

class AlertaSanitarioRepositoryImpl implements IAlertaSanitarioRepository {
  AlertaSanitarioRepositoryImpl(this._ds);

  final AlertaSanitarioSupabaseDatasource _ds;

  @override
  Future<List<AlertaSanitario>> listar(String municipioId) => _ds.listar(municipioId);

  @override
  Future<AlertaSanitario> criar({
    required String municipioId,
    required AlertaSanitarioTipo tipo,
    required String descricao,
    required double latitude,
    required double longitude,
    required double raioMetros,
    required String criadoPor,
  }) =>
      _ds.criar(
        municipioId: municipioId,
        tipo: tipo,
        descricao: descricao,
        latitude: latitude,
        longitude: longitude,
        raioMetros: raioMetros,
        criadoPor: criadoPor,
      );

  @override
  Future<AlertaSanitario> encerrar(String id) => _ds.encerrar(id);
}
