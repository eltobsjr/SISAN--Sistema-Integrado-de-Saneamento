import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:sisan/shared/design/sisan_tokens.dart';

/// Cabeçalho em gradiente "Água Viva" + folha branca com o formulário
/// (ver [AuthScaffold]).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await ref.read(authRepositoryProvider).login(email: _emailController.text.trim(), senha: _senhaController.text);
      // Navegação é responsabilidade do routerProvider (refreshListenable).
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.parse(e))));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titulo: 'Que bom te ver\nde novo',
      subtitulo: 'Entre pra continuar cuidando da água e do esgoto do seu município.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthCampo(
                label: 'E-mail',
                hint: 'seu@email.com',
                controller: _emailController,
                icone: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              AuthCampo(
                label: 'Senha',
                hint: 'Sua senha',
                controller: _senhaController,
                icone: Icons.lock_outline_rounded,
                senha: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _entrar(),
                validator: (v) => (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
              ),
              const SizedBox(height: 28),
              AuthBotao(label: 'Entrar', carregando: _carregando, onTap: _entrar),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Não tem conta?', style: SisanTexto.secundario),
            TextButton(
              // `push`, não `go` — cadastro tem botão de voltar que precisa de algo na pilha.
              onPressed: () => context.push('/cadastro'),
              child: const Text('Cadastre-se', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}
