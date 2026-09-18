import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';
import 'package:sisan/features/alertas_sanitarios/data/datasources/alerta_sanitario_supabase_datasource.dart';
import 'package:sisan/features/alertas_sanitarios/data/repositories/alerta_sanitario_repository_impl.dart';
import 'package:sisan/features/alertas_sanitarios/domain/entities/alerta_sanitario.dart';
import 'package:sisan/features/alertas_sanitarios/domain/repositories/i_alerta_sanitario_repository.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';

final alertaSanitarioRepositoryProvider = Provider<IAlertaSanitarioRepository>((ref) {
  return AlertaSanitarioRepositoryImpl(AlertaSanitarioSupabaseDatasource());
});

class AlertasSanitariosNotifier extends AsyncNotifier<List<AlertaSanitario>> {
  @override
  Future<List<AlertaSanitario>> build() async {
    final usuario = await ref.watch(authProvider.future);
    if (usuario == null) return [];
    return ref.read(alertaSanitarioRepositoryProvider).listar(usuario.municipioId);
  }

  Future<void> criar({
    required AlertaSanitarioTipo tipo,
    required String descricao,
    required double latitude,
    required double longitude,
    required double raioMetros,
  }) async {
    final usuario = await ref.read(authProvider.future);
    if (usuario == null) throw Exception('Usuário não autenticado.');
    final novo = await ref.read(alertaSanitarioRepositoryProvider).criar(
          municipioId: usuario.municipioId,
          tipo: tipo,
          descricao: descricao,
          latitude: latitude,
          longitude: longitude,
          raioMetros: raioMetros,
          criadoPor: usuario.id,
        );
    state = AsyncData([novo, ...(state.valueOrNull ?? [])]);
  }

  Future<void> encerrar(String id) async {
    final encerrado = await ref.read(alertaSanitarioRepositoryProvider).encerrar(id);
    state = AsyncData(
      (state.valueOrNull ?? []).map((a) => a.id == id ? encerrado : a).toList(),
    );
  }
}

final alertasSanitariosProvider =
    AsyncNotifierProvider<AlertasSanitariosNotifier, List<AlertaSanitario>>(
  AlertasSanitariosNotifier.new,
);
