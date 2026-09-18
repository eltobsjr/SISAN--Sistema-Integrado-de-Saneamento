import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/domain/entities/municipio.dart';

/// Lista de municípios ativos, usada no seletor de município do cadastro.
/// Leitura pública (RLS `municipios_select USING (true)`), não exige sessão.
final municipiosProvider = FutureProvider<List<Municipio>>((ref) async {
  final data = await supabase
      .from('municipios')
      .select('id, nome, concessionaria')
      .eq('ativo', true)
      .order('nome');

  return (data as List)
      .map((e) => Municipio.fromJson(e as Map<String, dynamic>))
      .toList();
});
