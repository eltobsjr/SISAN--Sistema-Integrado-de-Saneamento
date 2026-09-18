import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  @override
  Future<void> login({required String email, required String senha}) async {
    await supabase.auth.signInWithPassword(email: email, password: senha);
  }

  @override
  Future<void> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String municipioId,
    required PerfilUsuario perfilDesejado,
    String? codigoAtivacao,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: senha,
      data: {
        'nome': nome,
        'municipio_id': municipioId,
        'perfil': perfilDesejado.name,
        'codigo_ativacao': ?codigoAtivacao,
      },
    );
  }

  @override
  Future<bool> validarCodigoAtivacaoStaff({
    required String municipioId,
    required String codigo,
  }) async {
    final result = await supabase.rpc(
      'validar_codigo_ativacao_staff',
      params: {'p_municipio_id': municipioId, 'p_codigo': codigo},
    );
    return result as bool;
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
