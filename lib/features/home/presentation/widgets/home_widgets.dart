import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/shared/widgets/sino_notificacoes_button.dart';

/// Uma aba do bottom nav das homes.
class HomeAba {
  const HomeAba({
    required this.label,
    required this.icone,
    required this.iconeSelecionado,
    required this.pagina,
  });

  final String label;
  final IconData icone;
  final IconData iconeSelecionado;
  final Widget pagina;
}

/// Casca das homes dos três perfis — adaptado de `HomePage` do SIGAU:
/// bottom nav com [IndexedStack] (as abas mantêm estado) e confirmação ao
/// sair do app pelo botão voltar. [abasBuilder] recebe `irPara` pra uma aba
/// poder trocar de aba (ex.: avatar do header abre o Perfil).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.abasBuilder});

  final List<HomeAba> Function(void Function(int indice) irPara) abasBuilder;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final abas = widget.abasBuilder((i) => setState(() => _tabIndex = i));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_tabIndex != 0) {
          setState(() => _tabIndex = 0);
          return;
        }
        final sair = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Deseja sair do SISAN?'),
            content: const Text('Tem certeza que deseja fechar o aplicativo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair'),
              ),
            ],
          ),
        );
        if (sair == true && context.mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(index: _tabIndex, children: [for (final a in abas) a.pagina]),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: SisanCores.borda))),
          child: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: [
            for (final a in abas)
              NavigationDestination(
                icon: Icon(a.icone),
                selectedIcon: Icon(a.iconeSelecionado),
                label: a.label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header com gradiente, avatar, saudação e sino — o mesmo nos três perfis.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.usuario,
    required this.subtitulo,
    this.onAvatarTap,
    this.rodape,
  });

  final Usuario? usuario;
  final String subtitulo;
  final VoidCallback? onAvatarTap;

  /// Conteúdo opcional dentro do gradiente, abaixo da saudação (ex.: resumo
  /// do dia do técnico).
  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    final hora = DateTime.now().hour;
    final saudacao = hora < 12 ? 'Bom dia' : (hora < 18 ? 'Boa tarde' : 'Boa noite');
    final primeiroNome =
        usuario != null && usuario!.nome.isNotEmpty ? usuario!.nome.split(' ').first : '';
    final inicial = primeiroNome.isNotEmpty ? primeiroNome[0].toUpperCase() : '?';

    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 18, 20, 22),
      decoration: const BoxDecoration(
        gradient: SisanCores.gradiente,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(SisanRaio.xl + 4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    inicial,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$saudacao${primeiroNome.isNotEmpty ? ', $primeiroNome!' : '!'}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SinoNotificacoesButton(),
            ],
          ),
          if (rodape != null) ...[
            const SizedBox(height: 18),
            rodape!,
          ],
        ],
      ),
    );
  }
}

/// Atalho da aba Perfil.
class PerfilAtalho {
  const PerfilAtalho({required this.icone, required this.titulo, required this.rota});
  final IconData icone;
  final String titulo;
  final String rota;
}

/// Aba Perfil dos três perfis — cabeçalho em gradiente, atalhos e sair.
class PerfilTab extends ConsumerWidget {
  const PerfilTab({super.key, this.atalhos = const []});

  final List<PerfilAtalho> atalhos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;
    final inicial = (usuario != null && usuario.nome.isNotEmpty) ? usuario.nome[0].toUpperCase() : '?';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: SisanCores.gradiente),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 28, 20, 28),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(inicial, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: SisanEspaco.md),
                Text(
                  usuario?.nome ?? '—',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(usuario?.email ?? '—', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                const SizedBox(height: SisanEspaco.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(SisanRaio.pill),
                  ),
                  child: Text(
                    usuario?.perfil.toLabel() ?? 'Cidadão',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (atalhos.isNotEmpty) ...[
            const SectionHeader('Atalhos'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SisanEspaco.tela),
              child: SisanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (i, a) in atalhos.indexed) ...[
                      if (i > 0) const Divider(indent: 64),
                      ListTile(
                        leading: IconTile(a.icone, cor: SisanCores.primaria, tamanho: 36),
                        title: Text(a.titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right, color: SisanCores.textoTerciario),
                        onTap: () => context.push(a.rota),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SectionHeader('Conta'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SisanEspaco.tela),
            child: SisanCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const IconTile(Icons.logout, cor: SisanCores.perigo, tamanho: 36),
                title: const Text('Sair', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: SisanCores.perigo)),
                onTap: () => _confirmarSaida(context, ref),
              ),
            ),
          ),
          const SizedBox(height: SisanEspaco.xl),
        ],
      ),
    );
  }

  void _confirmarSaida(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair do app?'),
        content: const Text('Você precisará fazer login novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
