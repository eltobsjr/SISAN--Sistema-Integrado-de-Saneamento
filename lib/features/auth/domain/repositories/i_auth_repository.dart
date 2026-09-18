import 'package:sisan/core/constants/perfil_usuario.dart';

abstract interface class IAuthRepository {
  Future<void> login({required String email, required String senha});

  /// [perfilDesejado] só é honrado pelo trigger `handle_new_user` quando for
  /// `tecnico`/`gestor` e [codigoAtivacao] bater com o código do município —
  /// caso contrário o backend cria o usuário como `cidadao` (ver migration
  /// `create_usuarios`).
  Future<void> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String municipioId,
    required PerfilUsuario perfilDesejado,
    String? codigoAtivacao,
  });

  /// Checagem de UX antes do cadastro — a validação que realmente importa
  /// acontece no trigger `handle_new_user`, no servidor.
  Future<bool> validarCodigoAtivacaoStaff({
    required String municipioId,
    required String codigo,
  });

  Future<void> logout();
}
