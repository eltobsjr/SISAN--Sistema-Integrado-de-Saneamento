// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Usuario _$UsuarioFromJson(Map<String, dynamic> json) => _Usuario(
  id: json['id'] as String,
  email: json['email'] as String,
  nome: json['nome'] as String,
  perfil: $enumDecode(_$PerfilUsuarioEnumMap, json['perfil']),
  municipioId: json['municipioId'] as String,
);

Map<String, dynamic> _$UsuarioToJson(_Usuario instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nome': instance.nome,
  'perfil': _$PerfilUsuarioEnumMap[instance.perfil]!,
  'municipioId': instance.municipioId,
};

const _$PerfilUsuarioEnumMap = {
  PerfilUsuario.cidadao: 'cidadao',
  PerfilUsuario.tecnico: 'tecnico',
  PerfilUsuario.gestor: 'gestor',
};
