import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';
import 'package:sisan/features/alertas_sanitarios/domain/entities/alerta_sanitario.dart';

abstract interface class IAlertaSanitarioRepository {
  /// Todos os alertas do município (RLS já restringe a gestor/técnico),
  /// ativos e encerrados, mais recentes primeiro.
  Future<List<AlertaSanitario>> listar(String municipioId);

  Future<AlertaSanitario> criar({
    required String municipioId,
    required AlertaSanitarioTipo tipo,
    required String descricao,
    required double latitude,
    required double longitude,
    required double raioMetros,
    required String criadoPor,
  });

  Future<AlertaSanitario> encerrar(String id);
}
