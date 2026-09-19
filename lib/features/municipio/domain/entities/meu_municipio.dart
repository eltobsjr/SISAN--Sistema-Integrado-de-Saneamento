/// Dados do município do gestor + código de ativação de equipe (RPC
/// `meu_municipio_staff`, restrita a gestor).
class MeuMunicipio {
  const MeuMunicipio({
    required this.nome,
    required this.estado,
    required this.concessionaria,
    required this.codigoAtivacao,
    required this.gestores,
    required this.tecnicos,
    required this.cidadaos,
    this.codigoAtualizadoEm,
  });

  final String nome;
  final String estado;
  final String concessionaria; // valor do enum no banco (ex.: aguas_teresina)
  final String? codigoAtivacao;
  final DateTime? codigoAtualizadoEm;
  final int gestores;
  final int tecnicos;
  final int cidadaos;

  factory MeuMunicipio.fromJson(Map<String, dynamic> json) => MeuMunicipio(
        nome: json['nome'] as String,
        estado: json['estado'] as String,
        concessionaria: json['concessionaria'] as String,
        codigoAtivacao: json['codigo_ativacao'] as String?,
        codigoAtualizadoEm: DateTime.tryParse(json['codigo_atualizado_em'] as String? ?? '')?.toLocal(),
        gestores: (json['gestores'] as num?)?.toInt() ?? 0,
        tecnicos: (json['tecnicos'] as num?)?.toInt() ?? 0,
        cidadaos: (json['cidadaos'] as num?)?.toInt() ?? 0,
      );

  MeuMunicipio copyWithCodigo(String codigo) => MeuMunicipio(
        nome: nome,
        estado: estado,
        concessionaria: concessionaria,
        codigoAtivacao: codigo,
        codigoAtualizadoEm: DateTime.now(),
        gestores: gestores,
        tecnicos: tecnicos,
        cidadaos: cidadaos,
      );
}
