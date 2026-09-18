import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/auth/presentation/providers/municipios_provider.dart';

enum _TipoConta { cidadao, concessionaria }

class CadastroPage extends ConsumerStatefulWidget {
  const CadastroPage({super.key});

  @override
  ConsumerState<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends ConsumerState<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _codigoController = TextEditingController();

  _TipoConta _tipoConta = _TipoConta.cidadao;
  PerfilUsuario _perfilStaff = PerfilUsuario.tecnico;
  String? _municipioId;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_municipioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um município.')),
      );
      return;
    }

    setState(() => _carregando = true);
    final repo = ref.read(authRepositoryProvider);
    final ehStaff = _tipoConta == _TipoConta.concessionaria;

    try {
      if (ehStaff) {
        final codigoValido = await repo.validarCodigoAtivacaoStaff(
          municipioId: _municipioId!,
          codigo: _codigoController.text.trim(),
        );
        if (!codigoValido) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código de ativação inválido.')),
          );
          setState(() => _carregando = false);
          return;
        }
      }

      await repo.cadastrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        nome: _nomeController.text.trim(),
        municipioId: _municipioId!,
        perfilDesejado: ehStaff ? _perfilStaff : PerfilUsuario.cidadao,
        codigoAtivacao: ehStaff ? _codigoController.text.trim() : null,
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
    final municipiosAsync = ref.watch(municipiosProvider);
    final ehStaff = _tipoConta == _TipoConta.concessionaria;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<_TipoConta>(
                  segments: const [
                    ButtonSegment(
                      value: _TipoConta.cidadao,
                      label: Text('Cidadão'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: _TipoConta.concessionaria,
                      label: Text('Concessionária'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                  ],
                  selected: {_tipoConta},
                  onSelectionChanged: (s) =>
                      setState(() => _tipoConta = s.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo de 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
                municipiosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    'Não foi possível carregar os municípios.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  data: (municipios) => DropdownButtonFormField<String>(
                    initialValue: _municipioId,
                    decoration: const InputDecoration(labelText: 'Município'),
                    items: municipios
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text('${m.nome} — ${m.concessionaria.toLabel()}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _municipioId = v),
                    validator: (v) => v == null ? 'Selecione um município' : null,
                  ),
                ),
                if (ehStaff) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PerfilUsuario>(
                    initialValue: _perfilStaff,
                    decoration: const InputDecoration(labelText: 'Perfil'),
                    items: const [
                      DropdownMenuItem(
                        value: PerfilUsuario.tecnico,
                        child: Text('Técnico'),
                      ),
                      DropdownMenuItem(
                        value: PerfilUsuario.gestor,
                        child: Text('Gestor'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _perfilStaff = v ?? PerfilUsuario.tecnico),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de ativação',
                      helperText: 'Fornecido pela concessionária do seu município',
                    ),
                    validator: (v) => (ehStaff && (v == null || v.trim().isEmpty))
                        ? 'Informe o código de ativação'
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Criar conta'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Já tem conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
