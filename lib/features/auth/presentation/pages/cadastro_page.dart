import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sisan/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:sisan/shared/design/sisan_tokens.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um município.')));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código de ativação inválido.')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.parse(e))));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _voltar() => context.canPop() ? context.pop() : context.go('/login');

  @override
  Widget build(BuildContext context) {
    final municipiosAsync = ref.watch(municipiosProvider);
    final ehStaff = _tipoConta == _TipoConta.concessionaria;

    return AuthScaffold(
      compacto: true,
      onVoltar: _voltar,
      titulo: 'Criar conta',
      subtitulo: 'Leva um minuto. Comece a acompanhar a água e o esgoto da sua cidade.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthRotulo('Como você vai usar o SISAN?'),
              _TipoContaSelector(tipo: _tipoConta, onChanged: (v) => setState(() => _tipoConta = v)),
              const SizedBox(height: 22),
              AuthCampo(
                label: 'Nome completo',
                controller: _nomeController,
                icone: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                  if (v.trim().length < 3) return 'Nome muito curto';
                  return null;
                },
              ),
              const SizedBox(height: 18),
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
                hint: 'Mínimo de 6 caracteres',
                controller: _senhaController,
                icone: Icons.lock_outline_rounded,
                senha: true,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
              ),
              const SizedBox(height: 18),
              AuthCampo(
                label: 'Confirmar senha',
                hint: 'Repita a senha',
                controller: _confirmarSenhaController,
                icone: Icons.lock_outline_rounded,
                senha: true,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirme a senha';
                  if (v != _senhaController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const AuthRotulo('Município'),
              municipiosAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) =>
                    const Text('Não foi possível carregar os municípios.', style: TextStyle(color: SisanCores.perigo)),
                data: (municipios) => DropdownButtonFormField<String>(
                  initialValue: _municipioId,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  icon: const Icon(Icons.expand_more_rounded, color: SisanCores.textoTerciario),
                  decoration: authDecoracao(hint: 'Selecione seu município', icone: Icons.location_city_outlined),
                  items: municipios
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text('${m.nome} — ${m.concessionaria.toLabel()}', overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _municipioId = v),
                  validator: (v) => v == null ? 'Selecione um município' : null,
                ),
              ),
              if (ehStaff) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: SisanCores.primariaClara, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 18, color: SisanCores.primariaEscura),
                          SizedBox(width: 8),
                          Text(
                            'Acesso da concessionária',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SisanCores.primariaEscura,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const AuthRotulo('Perfil'),
                      DropdownButtonFormField<PerfilUsuario>(
                        initialValue: _perfilStaff,
                        borderRadius: BorderRadius.circular(14),
                        icon: const Icon(Icons.expand_more_rounded, color: SisanCores.textoTerciario),
                        decoration: authDecoracao(icone: Icons.badge_outlined).copyWith(fillColor: Colors.white),
                        items: const [
                          DropdownMenuItem(value: PerfilUsuario.tecnico, child: Text('Técnico')),
                          DropdownMenuItem(value: PerfilUsuario.gestor, child: Text('Gestor')),
                        ],
                        onChanged: (v) => setState(() => _perfilStaff = v ?? PerfilUsuario.tecnico),
                      ),
                      const SizedBox(height: 14),
                      AuthCampo(
                        label: 'Código de ativação',
                        ajuda: 'Fornecido pela concessionária do seu município',
                        controller: _codigoController,
                        icone: Icons.vpn_key_outlined,
                        validator: (v) =>
                            (ehStaff && (v == null || v.trim().isEmpty)) ? 'Informe o código de ativação' : null,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              AuthBotao(label: 'Criar conta', carregando: _carregando, onTap: _cadastrar),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Já tem conta?', style: SisanTexto.secundario),
            TextButton(
              // Login já existe na pilha (chegamos aqui via `push`) — `pop`
              // volta pra ele em vez de recriar a tela; `go` só como sobra.
              onPressed: _voltar,
              child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
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
    return Row(
      children: [
        Expanded(
          child: _TipoCard(
            label: 'Cidadão',
            descricao: 'Denunciar e acompanhar',
            icon: Icons.person_outline_rounded,
            selected: tipo == _TipoConta.cidadao,
            onTap: () => onChanged(_TipoConta.cidadao),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TipoCard(
            label: 'Concessionária',
            descricao: 'Técnico ou gestor',
            icon: Icons.engineering_outlined,
            selected: tipo == _TipoConta.concessionaria,
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
    required this.descricao,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String descricao;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? SisanCores.primariaClara : SisanCores.fundo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? SisanCores.primaria : SisanCores.borda, width: selected ? 1.8 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 26, color: selected ? SisanCores.primariaEscura : SisanCores.textoTerciario),
                  Icon(
                    selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 20,
                    color: selected ? SisanCores.primaria : SisanCores.bordaForte,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? SisanCores.primariaEscura : SisanCores.texto,
                ),
              ),
              const SizedBox(height: 2),
              Text(descricao, style: SisanTexto.legenda),
            ],
          ),
        ),
      ),
    );
  }
}
