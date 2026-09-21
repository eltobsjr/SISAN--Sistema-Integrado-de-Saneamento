import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
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
        bottomNavigationBar: NavigationBar(
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
    final primary = Theme.of(context).colorScheme.primary;
    final hora = DateTime.now().hour;
    final saudacao = hora < 12 ? 'Bom dia' : (hora < 18 ? 'Boa tarde' : 'Boa noite');
    final primeiroNome =
        usuario != null && usuario!.nome.isNotEmpty ? usuario!.nome.split(' ').first : '';
    final inicial = primeiroNome.isNotEmpty ? primeiroNome[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.75)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
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

/// Número grande sobre o gradiente do header (resumo rápido).
class HeaderResumo extends StatelessWidget {
  const HeaderResumo({super.key, required this.itens});

  /// Pares (valor, rótulo).
  final List<(String, String)> itens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < itens.length; i++) ...[
            if (i > 0) Container(width: 1, height: 32, color: Colors.white24),
            Expanded(
              child: Column(
                children: [
                  Text(
                    itens[i].$1,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itens[i].$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Título de seção das homes, com ação opcional à direita ("Ver todas").
class SecaoTitulo extends StatelessWidget {
  const SecaoTitulo(this.titulo, {super.key, this.acaoLabel, this.onAcao});

  final String titulo;
  final String? acaoLabel;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, acaoLabel != null ? 4 : 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (acaoLabel != null) TextButton(onPressed: onAcao, child: Text(acaoLabel!)),
        ],
      ),
    );
  }
}

/// Card de ação da grade "O que deseja fazer?" — do `_AcaoCard` do SIGAU.
class AcaoCard extends StatelessWidget {
  const AcaoCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    this.onTap,
    this.badge,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final VoidCallback? onTap;

  /// Contador opcional no canto (ex.: alertas ativos).
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icone, color: cor, size: 22),
                  ),
                  const Spacer(),
                  if (badge != null && badge! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        '$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                titulo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cor.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: TextStyle(fontSize: 10, color: cor.withValues(alpha: 0.65)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grade 2 colunas de [AcaoCard], como sliver.
class AcoesGrid extends StatelessWidget {
  const AcoesGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
        children: children,
      ),
    );
  }
}

/// Estado vazio compacto dentro de uma seção da home.
class SecaoVazia extends StatelessWidget {
  const SecaoVazia({super.key, required this.icone, required this.mensagem, this.cor});

  final IconData icone;
  final String mensagem;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = cor ?? Colors.green;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: c.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(child: Text(mensagem, style: const TextStyle(color: Colors.black54, fontSize: 13))),
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

/// Aba Perfil dos três perfis — dados do usuário, atalhos e sair.
class PerfilTab extends ConsumerWidget {
  const PerfilTab({super.key, this.atalhos = const []});

  final List<PerfilAtalho> atalhos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final usuario = ref.watch(authProvider).valueOrNull;
    final inicial = (usuario != null && usuario.nome.isNotEmpty) ? usuario.nome[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: primary.withValues(alpha: 0.15),
              child: Text(
                inicial,
                style: TextStyle(color: primary, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              usuario?.nome ?? '—',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              usuario?.email ?? '—',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              label: Text(usuario?.perfil.toLabel() ?? 'Cidadão'),
              backgroundColor: primary.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: primary),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          for (final a in atalhos) ...[
            ListTile(
              leading: Icon(a.icone),
              title: Text(a.titulo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(a.rota),
            ),
            const Divider(),
          ],
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('Sair', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => _confirmarSaida(context, ref),
          ),
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
