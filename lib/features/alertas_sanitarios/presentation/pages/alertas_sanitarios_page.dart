import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
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
        backgroundColor: const Color(0xFFC62828),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: alerta.ativo ? tipo.cor : Colors.grey),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(tipo.icone, size: 18, color: tipo.cor),
                          const SizedBox(width: 6),
                          Text(tipo.label, style: TextStyle(fontWeight: FontWeight.bold, color: tipo.cor)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: alerta.ativo
                                  ? Colors.red.withValues(alpha: 0.12)
                                  : Colors.grey.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              alerta.ativo ? 'ATIVO' : 'ENCERRADO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: alerta.ativo ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alerta.descricao,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.radar_outlined, size: 13, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text('Raio: $raioLabel', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 13, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(alerta.criadoEm),
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: Colors.black26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
