import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/municipio/domain/entities/meu_municipio.dart';

class MeuMunicipioNotifier extends AsyncNotifier<MeuMunicipio> {
  @override
  Future<MeuMunicipio> build() async {
    final raw = await supabase.rpc('meu_municipio_staff');
    return MeuMunicipio.fromJson((raw as Map).cast<String, dynamic>());
  }

  /// Gera um código novo (o antigo deixa de valer). Erros — inclusive o limite
  /// de trocas por hora — propagam pra tela mostrar a mensagem.
  Future<void> regenerarCodigo() async {
    final atual = state.valueOrNull;
    final novo = await supabase.rpc('regenerar_codigo_ativacao_staff') as String;
    if (atual != null) state = AsyncData(atual.copyWithCodigo(novo));
  }
}

final meuMunicipioProvider =
    AsyncNotifierProvider<MeuMunicipioNotifier, MeuMunicipio>(MeuMunicipioNotifier.new);
