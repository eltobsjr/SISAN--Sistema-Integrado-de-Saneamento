import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/shared/widgets/app_text_field.dart';
import 'package:sisan/shared/widgets/primary_pill_button.dart';

/// Visual inspirado no `auth_screen.dart` do polimata-concursos: mascote no
/// topo, campos preenchidos sem borda, botão pílula de largura total, tom
/// mais pessoal no texto — mantendo a cor "Água Viva" e o fluxo do SISAN.
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
      await ref.read(authRepositoryProvider).login(
            email: _emailController.text.trim(),
            senha: _senhaController.text,
          );
      // Navegação é responsabilidade do routerProvider (refreshListenable).
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.parse(e))),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: Image.asset(
                            'assets/images/app_icon_full.png',
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Que bom te ver de novo',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Entre pra continuar cuidando do seu município.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.55)),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: 'E-mail',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              prefixIcon: Icons.email_outlined,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                                if (!v.contains('@')) return 'E-mail inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Senha',
                              controller: _senhaController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              prefixIcon: Icons.lock_outline,
                              onFieldSubmitted: (_) => _entrar(),
                              validator: (v) => (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
                            ),
                            const SizedBox(height: 24),
                            PrimaryPillButton(
                              label: _carregando ? 'Entrando...' : 'Entrar',
                              loading: _carregando,
                              onTap: _entrar,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Não tem conta?',
                                    style: TextStyle(color: Colors.black.withValues(alpha: 0.55), fontSize: 14),
                                  ),
                                  TextButton(
                                    // `push`, não `go` — cadastro tem botão de voltar (`context.pop()`
                                    // no AppBar) que precisa de algo na pilha pra voltar.
                                    onPressed: () => context.push('/cadastro'),
                                    style: TextButton.styleFrom(foregroundColor: primary),
                                    child: const Text('Cadastre-se', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
