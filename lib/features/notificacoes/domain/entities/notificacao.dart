class Notificacao {
  const Notificacao({
    required this.id,
    required this.municipioId,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.corpo,
    required this.lida,
    required this.criadoEm,
    this.dados,
  });

  final String id;
  final String municipioId;
  final String usuarioId;
  final String tipo;
  final String titulo;
  final String corpo;
  final bool lida;
  final Map<String, dynamic>? dados;
  final DateTime criadoEm;

  Notificacao copyWith({bool? lida}) => Notificacao(
        id: id,
        municipioId: municipioId,
        usuarioId: usuarioId,
        tipo: tipo,
        titulo: titulo,
        corpo: corpo,
        lida: lida ?? this.lida,
        dados: dados,
        criadoEm: criadoEm,
      );
}
