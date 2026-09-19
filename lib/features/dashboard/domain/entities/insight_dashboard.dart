/// Resumo executivo do mês gerado por IA (Edge Function `insight-dashboard`)
/// a partir de agregados anônimos do município.
class InsightDashboard {
  const InsightDashboard({required this.titulo, required this.frases, this.geradoEm});

  final String titulo;
  final List<String> frases;
  final DateTime? geradoEm;

  factory InsightDashboard.fromJson(Map<String, dynamic> json) => InsightDashboard(
        titulo: json['titulo'] as String,
        frases: (json['frases'] as List).cast<String>(),
        geradoEm: DateTime.tryParse(json['gerado_em'] as String? ?? '')?.toLocal(),
      );
}
