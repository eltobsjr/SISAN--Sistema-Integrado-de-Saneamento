import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';

class AlertaSanitario {
  final String id;
  final String municipioId;
  final AlertaSanitarioTipo tipo;
  final String descricao;
  final double latitude;
  final double longitude;
  final double raioMetros;
  final bool ativo;
  final String criadoPor;
  final DateTime criadoEm;
  final DateTime? encerradoEm;

  const AlertaSanitario({
    required this.id,
    required this.municipioId,
    required this.tipo,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    this.raioMetros = 500,
    this.ativo = true,
    required this.criadoPor,
    required this.criadoEm,
    this.encerradoEm,
  });
}
