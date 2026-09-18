import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/shared/widgets/sino_notificacoes_button.dart';

/// Adaptado de `HomePage` do SIGAU (view do cidadão): mesmo bottom nav de 4
/// abas (Início/Mapa/Registrar/Perfil) e header com gradiente + saudação.
/// `Mapa` é placeholder até a feature `mapa` existir (ver
/// referencia/reaproveitamento-por-projeto.md).
class CidadaoHomePage extends ConsumerStatefulWidget {
  const CidadaoHomePage({super.key});

  @override
  ConsumerState<CidadaoHomePage> createState() => _CidadaoHomePageState();
}

class _CidadaoHomePageState extends ConsumerState<CidadaoHomePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authProvider).valueOrNull;

    final tabs = [
      _InicioTab(usuario: usuario, onPerfilTap: () => setState(() => _tabIndex = 3)),
      const MapaPage(),
      const _RegistrarTab(),
      const _PerfilTab(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
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
        body: IndexedStack(index: _tabIndex, children: tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Registrar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ABA INÍCIO ───────────────────────────────────────────────────────────

class _InicioTab extends ConsumerWidget {
  const _InicioTab({this.usuario, this.onPerfilTap});
  final Usuario? usuario;
  final VoidCallback? onPerfilTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final ocorrenciasState = ref.watch(ocorrenciasProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(usuario: usuario, primary: primary, onAvatarTap: onPerfilTap),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'O que deseja fazer?',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _AcaoCard(
                    titulo: 'Nova Ocorrência',
                    subtitulo: 'Foto, GPS e descrição do problema',
                    icone: Icons.add_circle_outline,
                    cor: primary,
                    onTap: () => context.push('/ocorrencias/nova'),
                  ),
                  _AcaoCard(
                    titulo: 'Minhas Ocorrências',
                    subtitulo: 'Acompanhe o status dos seus registros',
                    icone: Icons.history_rounded,
                    cor: const Color(0xFF00796B),
                    onTap: () => context.push('/ocorrencias'),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Atividade recente',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/ocorrencias'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
              ),
            ),
            ocorrenciasState.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(),
                ),
              ),
              error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
              data: (ocorrencias) {
                if (ocorrencias.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 56,
                              color: primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma atividade ainda',
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black38),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registre uma ocorrência para começar',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black26),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final recentes = ocorrencias.take(3).toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: recentes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 56),
                    itemBuilder: (_, i) => _AtividadeRecenteTile(ocorrencia: recentes[i]),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.usuario, required this.primary, this.onAvatarTap});
  final Usuario? usuario;
  final Color primary;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white24,
              child: Text(
                inicial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
                const Text(
                  'Como podemos ajudar hoje?',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SinoNotificacoesButton(),
        ],
      ),
    );
  }
}

class _AtividadeRecenteTile extends StatelessWidget {
  const _AtividadeRecenteTile({required this.ocorrencia});
  final Ocorrencia ocorrencia;

  Color _statusCor(OcorrenciaStatus s) => switch (s) {
        OcorrenciaStatus.pendente => Colors.orange,
        OcorrenciaStatus.emAnalise => Colors.blue,
        OcorrenciaStatus.resolvida => Colors.green,
        OcorrenciaStatus.arquivada => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final tipo = ocorrencia.tipo;
    final statusCor = _statusCor(ocorrencia.status);
    final diff = DateTime.now().difference(ocorrencia.criadoEm);
    final tempo = diff.inMinutes < 60
        ? 'há ${diff.inMinutes} min'
        : diff.inHours < 24
            ? 'há ${diff.inHours}h'
            : DateFormat('dd/MM').format(ocorrencia.criadoEm);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      onTap: () => context.push('/ocorrencias/${ocorrencia.id}', extra: ocorrencia),
      leading: CircleAvatar(
        backgroundColor: tipo.cor.withValues(alpha: 0.12),
        radius: 20,
        child: Icon(tipo.icone, color: tipo.cor, size: 18),
      ),
      title: Text(tipo.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(tempo, style: const TextStyle(fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: statusCor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          ocorrencia.status.label,
          style: TextStyle(fontSize: 11, color: statusCor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AcaoCard extends StatelessWidget {
  const _AcaoCard({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    this.onTap,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final VoidCallback? onTap;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 22),
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

// ─── ABA REGISTRAR ────────────────────────────────────────────────────────

class _RegistrarTab extends StatelessWidget {
  const _RegistrarTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Ocorrência')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.water_drop_outlined, size: 44, color: primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Viu um problema de água ou esgoto?',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Registre a localização, fotos e uma descrição para que a concessionária possa agir.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/ocorrencias/nova'),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Iniciar Registro'),
              style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ABA PERFIL ───────────────────────────────────────────────────────────

class _PerfilTab extends ConsumerWidget {
  const _PerfilTab();

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
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Minhas ocorrências'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/ocorrencias'),
          ),
          const Divider(),
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
