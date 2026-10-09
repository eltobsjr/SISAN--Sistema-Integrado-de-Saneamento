import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';

/// Moldura das telas de login e cadastro: cabeçalho em gradiente da marca com
/// ondas decorativas e uma folha branca de cantos arredondados sobreposta,
/// onde fica o formulário. Rola inteira (cabeçalho + folha) com o teclado.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.children,
    this.onVoltar,
    this.compacto = false,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> children;
  final VoidCallback? onVoltar;

  /// Cabeçalho menor (cadastro), pra sobrar mais área pro formulário.
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SisanCores.primariaEscura,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(gradient: SisanCores.gradiente)),
          ),
          const Positioned(top: -70, right: -50, child: _Bolha(tamanho: 220, opacidade: 0.10)),
          const Positioned(top: 90, left: -60, child: _Bolha(tamanho: 150, opacidade: 0.07)),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Cabecalho(titulo: titulo, subtitulo: subtitulo, onVoltar: onVoltar, compacto: compacto),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: SisanCores.superficie,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                            ),
                            padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + MediaQuery.of(context).padding.bottom),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.titulo, required this.subtitulo, required this.onVoltar, required this.compacto});

  final String titulo;
  final String subtitulo;
  final VoidCallback? onVoltar;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, onVoltar != null ? 4 : (compacto ? 20 : 36), 24, compacto ? 24 : 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onVoltar != null)
            Transform.translate(
              offset: const Offset(-12, 0),
              child: IconButton(
                onPressed: onVoltar,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Voltar',
              ),
            ),
          Row(
            children: [
              Container(
                width: compacto ? 44 : 56,
                height: compacto ? 44 : 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(compacto ? 14 : 18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                ),
                child: Icon(Icons.water_drop_rounded, color: Colors.white, size: compacto ? 24 : 30),
              ),
              const SizedBox(width: 12),
              const Text(
                'SISAN',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2.4),
              ),
            ],
          ),
          SizedBox(height: compacto ? 18 : 32),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white,
              fontSize: compacto ? 26 : 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitulo, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}

class _Bolha extends StatelessWidget {
  const _Bolha({required this.tamanho, required this.opacidade});
  final double tamanho;
  final double opacidade;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacidade),
      ),
    );
  }
}

/// Campo de formulário das telas de autenticação: fundo cinza-azulado suave,
/// borda fina que ganha a cor da marca no foco, ícone à esquerda e (se
/// [senha]) botão de mostrar/ocultar.
class AuthCampo extends StatefulWidget {
  const AuthCampo({
    super.key,
    required this.label,
    required this.controller,
    required this.icone,
    this.hint,
    this.ajuda,
    this.senha = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icone;
  final String? hint;
  final String? ajuda;
  final bool senha;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  State<AuthCampo> createState() => _AuthCampoState();
}

class _AuthCampoState extends State<AuthCampo> {
  late bool _oculta = widget.senha;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: SisanTexto.secundario.copyWith(fontWeight: FontWeight.w600, color: SisanCores.texto),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _oculta,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          textCapitalization: widget.textCapitalization,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          style: const TextStyle(fontSize: 15, color: SisanCores.texto),
          decoration: authDecoracao(
            hint: widget.hint,
            ajuda: widget.ajuda,
            icone: widget.icone,
            sufixo: widget.senha
                ? IconButton(
                    icon: Icon(
                      _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: SisanCores.textoTerciario,
                    ),
                    tooltip: _oculta ? 'Mostrar senha' : 'Ocultar senha',
                    onPressed: () => setState(() => _oculta = !_oculta),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Decoração compartilhada pelos campos e dropdowns das telas de autenticação.
InputDecoration authDecoracao({String? hint, String? ajuda, IconData? icone, Widget? sufixo}) {
  OutlineInputBorder borda(Color cor, [double largura = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: cor, width: largura),
  );

  return InputDecoration(
    hintText: hint,
    helperText: ajuda,
    helperMaxLines: 2,
    hintStyle: const TextStyle(color: SisanCores.textoTerciario, fontSize: 15),
    filled: true,
    fillColor: SisanCores.fundo,
    prefixIcon: icone != null ? Icon(icone, size: 20, color: SisanCores.textoTerciario) : null,
    suffixIcon: sufixo,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: borda(SisanCores.borda),
    enabledBorder: borda(SisanCores.borda),
    focusedBorder: borda(SisanCores.primaria, 1.8),
    errorBorder: borda(SisanCores.perigo),
    focusedErrorBorder: borda(SisanCores.perigo, 1.8),
  );
}

/// Rótulo acima de um campo que não é [AuthCampo] (ex.: dropdown).
class AuthRotulo extends StatelessWidget {
  const AuthRotulo(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      texto,
      style: SisanTexto.secundario.copyWith(fontWeight: FontWeight.w600, color: SisanCores.texto),
    ),
  );
}

/// Botão principal das telas de autenticação: largura total, gradiente da
/// marca, estado de carregamento.
class AuthBotao extends StatelessWidget {
  const AuthBotao({super.key, required this.label, required this.onTap, this.carregando = false});

  final String label;
  final VoidCallback onTap;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: carregando ? 0.75 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: SisanCores.gradiente,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: SisanCores.primaria.withValues(alpha: 0.30), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: carregando ? null : onTap,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              child: carregando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
