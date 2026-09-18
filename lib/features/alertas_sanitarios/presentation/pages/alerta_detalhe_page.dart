import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/alertas_sanitarios/domain/entities/alerta_sanitario.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/providers/alertas_sanitarios_provider.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Adaptado de `AlertaDetalhePage` do SIGAU (feature `zoonoses`).
class AlertaDetalhePage extends ConsumerWidget {
  const AlertaDetalhePage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas = ref.watch(alertasSanitariosProvider).valueOrNull ?? [];
    final alerta = alertas.cast<AlertaSanitario?>().firstWhere((a) => a?.id == id, orElse: () => null);

    if (alerta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alerta')),
        body: const Center(child: SisanLoading.compact()),
      );
    }

    final tipo = alerta.tipo;
    final ponto = LatLng(alerta.latitude, alerta.longitude);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: alerta.ativo ? tipo.cor : Colors.grey,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(tipo.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      alerta.ativo ? tipo.cor : Colors.grey,
                      (alerta.ativo ? tipo.cor : Colors.grey).withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(child: Icon(tipo.icone, size: 64, color: Colors.white.withValues(alpha: 0.2))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: alerta.ativo ? Colors.red.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: alerta.ativo ? Colors.red : Colors.grey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              alerta.ativo ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              size: 14,
                              color: alerta.ativo ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alerta.ativo ? 'ALERTA ATIVO' : 'ENCERRADO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: alerta.ativo ? Colors.red : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(icone: tipo.icone, cor: tipo.cor, titulo: 'Tipo', valor: tipo.label),
                  _InfoRow(
                    icone: Icons.radar_outlined,
                    cor: Colors.blueGrey,
                    titulo: 'Raio de risco',
                    valor: alerta.raioMetros >= 1000
                        ? '${(alerta.raioMetros / 1000).toStringAsFixed(1)} km ao redor do foco'
                        : '${alerta.raioMetros.toInt()} m ao redor do foco',
                  ),
                  _InfoRow(
                    icone: Icons.calendar_today_outlined,
                    cor: Colors.blueGrey,
                    titulo: 'Criado em',
                    valor: DateFormat('dd/MM/yyyy às HH:mm').format(alerta.criadoEm),
                  ),
                  if (alerta.encerradoEm != null)
                    _InfoRow(
                      icone: Icons.event_available_outlined,
                      cor: Colors.blueGrey,
                      titulo: 'Encerrado em',
                      valor: DateFormat('dd/MM/yyyy às HH:mm').format(alerta.encerradoEm!),
                    ),
                  const SizedBox(height: 20),
                  Text('Descrição', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(alerta.descricao, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 20),
                  Text('Localização', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: ponto,
                          initialZoom: 13,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'br.piaui.sisan',
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: ponto,
                                radius: alerta.raioMetros,
                                color: tipo.cor.withValues(alpha: 0.18),
                                borderColor: tipo.cor,
                                borderStrokeWidth: 2.5,
                                useRadiusInMeter: true,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: ponto,
                                width: 36,
                                height: 36,
                                child: Icon(Icons.location_on, color: tipo.cor, size: 36),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (alerta.ativo) ...[
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () => _confirmarEncerrar(context, ref),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: const Text('Encerrar Alerta', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEncerrar(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar alerta?'),
        content: const Text('O alerta será marcado como encerrado e não aparecerá mais como ativo.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(alertasSanitariosProvider.notifier).encerrar(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alerta encerrado'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ErrorHandler.parse(e)), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icone, required this.cor, required this.titulo, required this.valor});

  final IconData icone;
  final Color cor;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: cor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icone, size: 18, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.black45)),
                Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
