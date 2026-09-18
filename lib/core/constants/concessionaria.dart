enum Concessionaria {
  aguasPiaui,
  aguasTeresina,
  aguasTimon;

  static Concessionaria fromDb(String value) => switch (value) {
        'aguas_piaui' => Concessionaria.aguasPiaui,
        'aguas_teresina' => Concessionaria.aguasTeresina,
        'aguas_timon' => Concessionaria.aguasTimon,
        _ => throw ArgumentError('Concessionária desconhecida: $value'),
      };

  String toLabel() => switch (this) {
        Concessionaria.aguasPiaui => 'Águas do Piauí',
        Concessionaria.aguasTeresina => 'Águas de Teresina',
        Concessionaria.aguasTimon => 'Águas de Timon',
      };
}
