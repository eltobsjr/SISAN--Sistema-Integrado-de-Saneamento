import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

/// AppBar padrão das telas internas: gradiente da marca, título à esquerda.
/// Mesmos parâmetros do [AppBar] que as telas usam, pra troca direta.
class SisanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SisanAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: false,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
      backgroundColor: SisanCores.primariaEscura,
      flexibleSpace: const SizedBox.expand(
        child: DecoratedBox(decoration: BoxDecoration(gradient: SisanCores.gradiente)),
      ),
    );
  }
}

/// Superfície base de todo card: branco, borda sutil, raio 16. [corDestaque]
/// desenha uma faixa vertical à esquerda (urgência, tipo, estado).
class SisanCard extends StatelessWidget {
  const SisanCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SisanEspaco.lg),
    this.onTap,
    this.corDestaque,
    this.cor = SisanCores.superficie,
    this.corBorda = SisanCores.borda,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? corDestaque;
  final Color cor;
  final Color corBorda;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(SisanRaio.lg);
    Widget conteudo = Padding(padding: padding, child: child);
    if (corDestaque != null) {
      conteudo = Stack(
        children: [
          conteudo,
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: corDestaque)),
        ],
      );
    }
    return Material(
      color: cor,
      shape: RoundedRectangleBorder(borderRadius: raio, side: BorderSide(color: corBorda)),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? conteudo : InkWell(onTap: onTap, child: conteudo),
    );
  }
}

/// Pílula de estado (status da OS, status da ocorrência, urgência, "Novo").
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, required this.cor, this.icone, this.solido = false});

  final String label;
  final Color cor;
  final IconData? icone;
  final bool solido;

  @override
  Widget build(BuildContext context) {
    final fg = solido ? Colors.white : cor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: solido ? cor : cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SisanRaio.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 12, color: fg), const SizedBox(width: 3)],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

/// Ícone dentro de um quadrado arredondado colorido.
class IconTile extends StatelessWidget {
  const IconTile(this.icone, {super.key, required this.cor, this.tamanho = 40, this.solido = false});

  final IconData icone;
  final Color cor;
  final double tamanho;
  final bool solido;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: solido ? cor : cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tamanho * 0.3),
      ),
      child: Icon(icone, color: solido ? Colors.white : cor, size: tamanho * 0.52),
    );
  }
}

/// Ícone pequeno + texto — linha de metadados dos cards.
class MetaInfo extends StatelessWidget {
  const MetaInfo(this.icone, this.texto, {super.key, this.cor = SisanCores.textoTerciario, this.flex = false});

  final IconData icone;
  final String texto;
  final Color cor;

  /// Quando true, o texto ocupa o espaço restante e corta com reticências.
  final bool flex;

  @override
  Widget build(BuildContext context) {
    final t = Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.w500),
    );
    return Row(
      mainAxisSize: flex ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: cor),
        const SizedBox(width: 4),
        if (flex) Expanded(child: t) else Flexible(child: t),
      ],
    );
  }
}

/// Título de seção, com subtítulo e ação opcionais ("Ver todas").
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.titulo, {
    super.key,
    this.subtitulo,
    this.acaoLabel,
    this.onAcao,
    this.padding = const EdgeInsets.fromLTRB(SisanEspaco.tela, SisanEspaco.xl, SisanEspaco.sm, SisanEspaco.sm),
  });

  final String titulo;
  final String? subtitulo;
  final String? acaoLabel;
  final VoidCallback? onAcao;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: SisanTexto.tituloSecao),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitulo!, style: SisanTexto.legenda),
                ],
              ],
            ),
          ),
          if (acaoLabel != null)
            TextButton(
              onPressed: onAcao,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(acaoLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
            )
          else
            const SizedBox(width: SisanEspaco.sm),
        ],
      ),
    );
  }
}

/// Estado vazio compacto dentro de uma seção.
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.icone, required this.mensagem, this.cor = SisanCores.sucesso});

  final IconData icone;
  final String mensagem;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return SisanCard(
      cor: cor.withValues(alpha: 0.05),
      corBorda: cor.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(SisanEspaco.lg),
      child: Row(
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: SisanEspaco.md),
          Expanded(child: Text(mensagem, style: SisanTexto.secundario)),
        ],
      ),
    );
  }
}

/// Faixa de aviso (risco, offline, alerta ativo).
class AvisoBanner extends StatelessWidget {
  const AvisoBanner({super.key, required this.mensagem, required this.cor, this.icone = Icons.info_outline, this.onTap});

  final String mensagem;
  final Color cor;
  final IconData icone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SisanCard(
      cor: cor.withValues(alpha: 0.07),
      corBorda: cor.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: SisanEspaco.md, vertical: SisanEspaco.md),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: SisanEspaco.sm + 2),
          Expanded(
            child: Text(mensagem, style: TextStyle(color: cor, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          if (onTap != null) Icon(Icons.chevron_right, color: cor, size: 20),
        ],
      ),
    );
  }
}
