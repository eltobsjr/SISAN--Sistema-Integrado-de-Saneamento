enum PerfilUsuario {
  cidadao,
  tecnico,
  gestor;

  String toLabel() {
    switch (this) {
      case PerfilUsuario.cidadao:
        return 'Cidadão';
      case PerfilUsuario.tecnico:
        return 'Técnico';
      case PerfilUsuario.gestor:
        return 'Gestor';
    }
  }
}
