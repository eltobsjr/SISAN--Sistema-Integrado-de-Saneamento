import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/features/auth/domain/entities/usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/mapa/presentation/pages/mapa_page.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/features/home/presentation/widgets/home_widgets.dart';

/// Adaptado de `HomePage` do SIGAU (view do cidadão): bottom nav de 4 abas
/// (Início/Mapa/Registrar/Perfil) e header com gradiente + saudação. A casca
/// e os widgets da home são compartilhados com técnico e gestor
/// (`home_widgets.dart`).
class CidadaoHomePage extends ConsumerWidget {
  const CidadaoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).valueOrNull;

    return HomeShell(
      abasBuilder: (irPara) => [
        HomeAba(
          label: 'Início',
          icone: Icons.home_outlined,
          iconeSelecionado: Icons.home,
          pagina: _InicioTab(usuario: usuario, onPerfilTap: () => irPara(3)),
        ),
        const HomeAba(
          label: 'Mapa',
          icone: Icons.map_outlined,
          iconeSelecionado: Icons.map,
          pagina: MapaPage(),
        ),
        const HomeAba(
          label: 'Registrar',
          icone: Icons.add_circle_outline,
          iconeSelecionado: Icons.add_circle,
          pagina: _RegistrarTab(),
        ),
        const HomeAba(
          label: 'Perfil',
          icone: Icons.person_outline,
          iconeSelecionado: Icons.person,
          pagina: PerfilTab(
            atalhos: [
              PerfilAtalho(icone: Icons.history_outlined, titulo: 'Minhas ocorrências', rota: '/ocorrencias'),
            ],
          ),
        ),
      ],
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
              child: HomeHeader(usuario: usuario, subtitulo: 'Como podemos ajudar hoje?', onAvatarTap: onPerfilTap),
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
                  AcaoCard(
                    titulo: 'Nova Ocorrência',
                    subtitulo: 'Foto, GPS e descrição do problema',
                    icone: Icons.add_circle_outline,
                    cor: primary,
                    onTap: () => context.push('/ocorrencias/nova'),
                  ),
                  AcaoCard(
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
