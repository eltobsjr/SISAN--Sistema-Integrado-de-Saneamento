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
  final _confirmarSenhaController = TextEditingController();
  final _codigoController = TextEditingController();

  _TipoConta _tipoConta = _TipoConta.cidadao;
  PerfilUsuario _perfilStaff = PerfilUsuario.tecnico;
  String? _municipioId;
  bool _obscureSenha = true;
  bool _obscureConfirmar = true;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
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
    final theme = Theme.of(context);
    final municipiosAsync = ref.watch(municipiosProvider);
    final ehStaff = _tipoConta == _TipoConta.concessionaria;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.water_drop_rounded, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 24),

                _TipoContaSelector(
                  tipo: _tipoConta,
                  onChanged: (v) => setState(() => _tipoConta = v),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nomeController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                    if (v.trim().length < 3) return 'Nome muito curto';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seu@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscureSenha,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo de 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: _obscureConfirmar,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmar
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirme a senha';
                    if (v != _senhaController.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                municipiosAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    'Não foi possível carregar os municípios.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  data: (municipios) => DropdownButtonFormField<String>(
                    initialValue: _municipioId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Município',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: municipios
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(
                                '${m.nome} — ${m.concessionaria.toLabel()}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _municipioId = v),
                    validator: (v) => v == null ? 'Selecione um município' : null,
                  ),
                ),

                if (ehStaff) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Código de ativação da concessionária',
                    style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PerfilUsuario>(
                    initialValue: _perfilStaff,
                    decoration: const InputDecoration(
                      labelText: 'Perfil',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: PerfilUsuario.tecnico, child: Text('Técnico')),
                      DropdownMenuItem(value: PerfilUsuario.gestor, child: Text('Gestor')),
                    ],
                    onChanged: (v) => setState(() => _perfilStaff = v ?? PerfilUsuario.tecnico),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de ativação',
                      helperText: 'Fornecido pela concessionária do seu município',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    validator: (v) => (ehStaff && (v == null || v.trim().isEmpty))
                        ? 'Informe o código de ativação'
                        : null,
                  ),
                ],

                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Criar conta'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem conta?', style: theme.textTheme.bodyMedium),
                    TextButton(
                      // Login já existe na pilha (chegamos aqui via `push`) — `pop`
                      // volta pra ele em vez de recriar a tela; `go` só como sobra.
                      onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TIPO DE CONTA ────────────────────────────────────────────────────────

class _TipoContaSelector extends StatelessWidget {
  const _TipoContaSelector({required this.tipo, required this.onChanged});
  final _TipoConta tipo;
  final ValueChanged<_TipoConta> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: _TipoCard(
            label: 'Sou Cidadão',
            icon: Icons.person_outline,
            selected: tipo == _TipoConta.cidadao,
            cor: primary,
            onTap: () => onChanged(_TipoConta.cidadao),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TipoCard(
            label: 'Sou da Concessionária',
            icon: Icons.badge_outlined,
            selected: tipo == _TipoConta.concessionaria,
            cor: const Color(0xFF01579B),
            onTap: () => onChanged(_TipoConta.concessionaria),
          ),
        ),
      ],
    );
  }
}

class _TipoCard extends StatelessWidget {
  const _TipoCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.cor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? cor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cor : Colors.black26, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? cor : Colors.black45, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? cor : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
