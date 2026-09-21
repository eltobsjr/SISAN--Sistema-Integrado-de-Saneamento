import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';
import 'package:sisan/features/alertas_sanitarios/domain/entities/alerta_sanitario.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/providers/alertas_sanitarios_provider.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

/// Adaptado de `ZoonosesPage` do SIGAU (feature `zoonoses`) — mesma
/// estrutura de filtro por tipo + card com faixa colorida, trocando
/// zoonose animal por [AlertaSanitarioTipo].
class AlertasSanitariosPage extends ConsumerStatefulWidget {
  const AlertasSanitariosPage({super.key});

  @override
  ConsumerState<AlertasSanitariosPage> createState() => _AlertasSanitariosPageState();
}

class _AlertasSanitariosPageState extends ConsumerState<AlertasSanitariosPage> {
  AlertaSanitarioTipo? _filtroTipo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertasState = ref.watch(alertasSanitariosProvider);

    return Scaffold(
      appBar: SisanAppBar(
        title: const Text('Alertas Sanitários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(alertasSanitariosProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/alertas-sanitarios/criar'),
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Novo Alerta'),
        backgroundColor: SisanCores.perigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFiltros(theme),
          Expanded(
            child: alertasState.when(
              loading: () => const SkeletonList(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              error: (_, _) => SisanErrorState(onRetry: () => ref.invalidate(alertasSanitariosProvider)),
              data: (alertas) {
                final filtrados = _filtroTipo == null
                    ? alertas
                    : alertas.where((a) => a.tipo == _filtroTipo).toList();

                if (filtrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.health_and_safety_outlined,
                          size: 56,
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filtroTipo == null ? 'Nenhum alerta registrado' : 'Nenhum alerta deste tipo',
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black38),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(alertasSanitariosProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(SisanEspaco.tela, SisanEspaco.sm, SisanEspaco.tela, 96),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: SisanEspaco.sm + 2),
                    itemBuilder: (_, i) => _AlertaCard(
                      alerta: filtrados[i],
                      onTap: () => context.push('/alertas-sanitarios/${filtrados[i].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: _filtroTipo == null,
            onSelected: (_) => setState(() => _filtroTipo = null),
          ),
          const SizedBox(width: 8),
          ...AlertaSanitarioTipo.values.map(
            (tipo) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(tipo.icone, size: 16, color: tipo.cor),
                label: Text(tipo.label),
                selected: _filtroTipo == tipo,
                selectedColor: tipo.cor.withValues(alpha: 0.15),
                checkmarkColor: tipo.cor,
                onSelected: (_) => setState(() => _filtroTipo = _filtroTipo == tipo ? null : tipo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  const _AlertaCard({required this.alerta, required this.onTap});

  final AlertaSanitario alerta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tipo = alerta.tipo;
    final raioLabel = alerta.raioMetros >= 1000
        ? '${(alerta.raioMetros / 1000).toStringAsFixed(1)} km'
        : '${alerta.raioMetros.toInt()} m';

    final cor = alerta.ativo ? tipo.cor : SisanCores.neutro;

    return SisanCard(
      onTap: onTap,
      corDestaque: cor,
      padding: const EdgeInsets.fromLTRB(SisanEspaco.lg + 4, SisanEspaco.md + 2, SisanEspaco.md, SisanEspaco.md + 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconTile(tipo.icone, cor: cor, tamanho: 32),
                    const SizedBox(width: SisanEspaco.sm + 2),
                    Expanded(
                      child: Text(tipo.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: SisanTexto.tituloCard),
                    ),
                    const SizedBox(width: SisanEspaco.sm),
                    alerta.ativo
                        ? const StatusBadge('Ativo', cor: SisanCores.perigo, icone: Icons.circle, solido: true)
                        : const StatusBadge('Encerrado', cor: SisanCores.neutro, icone: Icons.check),
                  ],
                ),
                const SizedBox(height: SisanEspaco.sm + 2),
                Text(alerta.descricao, maxLines: 2, overflow: TextOverflow.ellipsis, style: SisanTexto.secundario),
                const SizedBox(height: SisanEspaco.sm + 2),
                Row(
                  children: [
                    MetaInfo(Icons.radar_outlined, 'Raio de $raioLabel'),
                    const SizedBox(width: SisanEspaco.lg),
                    MetaInfo(Icons.access_time, 'criado ${tempoRelativo(alerta.criadoEm)}'),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: SisanCores.textoTerciario),
        ],
      ),
    );
  }
}
