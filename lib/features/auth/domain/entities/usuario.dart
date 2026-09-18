// Run: dart run build_runner build --delete-conflicting-outputs
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sisan/core/constants/perfil_usuario.dart';

part 'usuario.freezed.dart';
part 'usuario.g.dart';

@freezed
sealed class Usuario with _$Usuario {
  const factory Usuario({
    required String id,
    required String email,
    required String nome,
    required PerfilUsuario perfil,
    required String municipioId,
  }) = _Usuario;

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);
}
