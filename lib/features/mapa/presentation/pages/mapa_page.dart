import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/features/mapa/presentation/providers/mapa_provider.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/shared/providers/municipio_center_provider.dart';
import 'package:sisan/shared/widgets/foto_viewer.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Adaptado de `MapaPage` do SIGAU (feature `mapa`): mesma estrutura de
/// cluster de marcadores + filtro + contador + botões flutuantes, trocando
/// espécie de animal por [OcorrenciaTipo] e urgência 1-5 por
/// [OcorrenciaUrgencia].
class MapaPage extends ConsumerStatefulWidget {
  const MapaPage({super.key});

  @override
  ConsumerState<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends ConsumerState<MapaPage> {
  final _mapController = MapController();
  LatLng? _minhaLocalizacao;
  bool _centroMunicipalAplicado = false;

  @override
  void initState() {
    super.initState();
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        final loc = LatLng(pos.latitude, pos.longitude);
        setState(() => _minhaLocalizacao = loc);
        _mapController.move(loc, 15);
        _centroMunicipalAplicado = true;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapaProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final municipioCentro = ref.watch(municipioCenterProvider).valueOrNull;
    if (!_centroMunicipalAplicado && _minhaLocalizacao == null && municipioCentro != null) {
      _centroMunicipalAplicado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(municipioCentro, 13);
      });
    }

    final comCoordenadas = state.ocorrenciasFiltradas
        .where((o) => o.latitude != null && o.longitude != null)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _minhaLocalizacao ?? const LatLng(-7.0762, -41.4661),
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.piaui.sisan',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 80,
                  size: const Size(42, 42),
                  alignment: Alignment.center,
                  markers: comCoordenadas.map((o) => _buildMarcador(context, o)).toList(),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Center(
                        child: Text(
                          '${markers.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_minhaLocalizacao != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _minhaLocalizacao!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: _FiltroBar(
              selecionado: state.filtroTipo,
              onFiltrar: (v) => ref.read(mapaProvider.notifier).setFiltroTipo(v),
            ),
          ),

          if (state.isLoading) const Center(child: SisanLoading.compact()),

          Positioned(
            bottom: 24,
            left: 16,
            child: GestureDetector(
              onTap: () => _abrirListaOcorrencias(comCoordenadas),
              child: _ContadorChip(
                total: state.ocorrencias.length,
                filtrados: state.ocorrenciasFiltradas.length,
                filtroAtivo: state.filtroTipo != null,
              ),
            ),
          ),

          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'mapa_location',
              onPressed: () async {
                await _obterLocalizacao();
                if (_minhaLocalizacao != null) _mapController.move(_minhaLocalizacao!, 15);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            bottom: 72,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'mapa_refresh',
              backgroundColor: Colors.white,
              foregroundColor: primary,
              onPressed: () => ref.read(mapaProvider.notifier).recarregar(),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarcador(BuildContext context, Ocorrencia ocorrencia) {
    final cor = ocorrencia.urgencia.cor;
    return Marker(
      point: LatLng(ocorrencia.latitude!, ocorrencia.longitude!),
      width: 36,
      height: 36,
      child: GestureDetector(
        onTap: () => _mostrarDetalhes(context, ocorrencia),
        child: Container(
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(ocorrencia.tipo.icone, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  void _abrirListaOcorrencias(List<Ocorrencia> ocorrencias) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ListaOcorrenciasSheet(
        ocorrencias: ocorrencias,
        onSelecionar: (o) {
          Navigator.pop(context);
          _mapController.move(LatLng(o.latitude!, o.longitude!), 17);
        },
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context, Ocorrencia ocorrencia) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DetalhesSheet(ocorrencia: ocorrencia),
    );
  }
}

// ─── FILTRO BAR ─────────────────────────────────────────────────────────

class _FiltroBar extends StatelessWidget {
  const _FiltroBar({required this.selecionado, required this.onFiltrar});
  final OcorrenciaTipo? selecionado;
  final ValueChanged<OcorrenciaTipo?> onFiltrar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FiltroChip(label: 'Todos', selecionado: selecionado == null, onTap: () => onFiltrar(null)),
          for (final tipo in OcorrenciaTipo.values) ...[
            const SizedBox(width: 8),
            _FiltroChip(
              label: tipo.label,
              icone: tipo.icone,
              selecionado: selecionado == tipo,
              onTap: () => onFiltrar(tipo),
            ),
          ],
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({required this.label, required this.selecionado, required this.onTap, this.icone});
  final String label;
  final bool selecionado;
  final VoidCallback onTap;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 14, color: selecionado ? Colors.white : Colors.black54),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selecionado ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CONTADOR ─────────────────────────────────────────────────────────────

class _ContadorChip extends StatelessWidget {
  const _ContadorChip({required this.total, required this.filtrados, required this.filtroAtivo});
  final int total;
  final int filtrados;
  final bool filtroAtivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Text(
        filtroAtivo ? '$filtrados de $total ocorrências' : '$total ocorrência${total != 1 ? 's' : ''}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── LISTA DE OCORRÊNCIAS ─────────────────────────────────────────────────

class _ListaOcorrenciasSheet extends StatelessWidget {
  const _ListaOcorrenciasSheet({required this.ocorrencias, required this.onSelecionar});
  final List<Ocorrencia> ocorrencias;
  final ValueChanged<Ocorrencia> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Ocorrências no mapa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${ocorrencias.length}', style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ocorrencias.isEmpty
                ? const Center(
                    child: Text('Nenhuma ocorrência no mapa no momento.', style: TextStyle(color: Colors.black45)),
                  )
                : ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: ocorrencias.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 68),
                    itemBuilder: (_, i) {
                      final o = ocorrencias[i];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: o.urgencia.cor, shape: BoxShape.circle),
                          child: Icon(o.tipo.icone, color: Colors.white, size: 18),
                        ),
                        title: Text(o.tipo.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(o.protocolo ?? '', style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                        onTap: () => onSelecionar(o),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── BOTTOM SHEET DE DETALHES ─────────────────────────────────────────────

class _DetalhesSheet extends StatelessWidget {
  const _DetalhesSheet({required this.ocorrencia});
  final Ocorrencia ocorrencia;

  Color _statusCor(OcorrenciaStatus s) => switch (s) {
        OcorrenciaStatus.pendente => Colors.orange,
        OcorrenciaStatus.emAnalise => Colors.blue,
        OcorrenciaStatus.resolvida => Colors.green,
        OcorrenciaStatus.arquivada => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = ocorrencia.urgencia.cor;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          if (ocorrencia.fotos.isNotEmpty)
            GestureDetector(
              onTap: () => showFotoViewer(context, ocorrencia.fotos, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ocorrencia.fotos.first,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  ocorrencia.urgencia.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusCor(ocorrencia.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ocorrencia.status.label,
                  style: TextStyle(fontSize: 12, color: _statusCor(ocorrencia.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(ocorrencia.tipo.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(ocorrencia.descricao, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          if (ocorrencia.endereco != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.black38),
                const SizedBox(width: 4),
                Expanded(child: Text(ocorrencia.endereco!, style: const TextStyle(fontSize: 12, color: Colors.black45))),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(ocorrencia.criadoEm),
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.black38),
              ),
              if (ocorrencia.protocolo != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.tag, size: 14, color: Colors.black38),
                const SizedBox(width: 4),
                Text(
                  ocorrencia.protocolo!,
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.black38, letterSpacing: 0.8),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
