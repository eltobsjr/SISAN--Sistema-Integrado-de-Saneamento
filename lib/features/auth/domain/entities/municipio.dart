import 'package:sisan/core/constants/concessionaria.dart';

class Municipio {
  const Municipio({
    required this.id,
    required this.nome,
    required this.concessionaria,
  });

  final String id;
  final String nome;
  final Concessionaria concessionaria;

  factory Municipio.fromJson(Map<String, dynamic> json) => Municipio(
        id: json['id'] as String,
        nome: json['nome'] as String,
        concessionaria: Concessionaria.fromDb(json['concessionaria'] as String),
      );
}
