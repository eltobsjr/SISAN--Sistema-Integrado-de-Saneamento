import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/shared/providers/municipio_center_provider.dart';

/// Mapa com seletor de localização por toque — mesmo padrão do
/// `criar_alerta_page.dart` (adaptado do `CriarAlertaPage` do SIGAU):
/// toca no mapa pra marcar o ponto, ou usa o botão de GPS. Reutilizável em
/// qualquer formulário que precise de "onde aconteceu" com apoio visual.
class MapLocationPicker extends ConsumerStatefulWidget {
  const MapLocationPicker({
    super.key,
    required this.onPontoSelecionado,
    this.pontoInicial,
    this.altura = 220,
    this.cor = const Color(0xFF0288D1),
  });

  final ValueChanged<LatLng> onPontoSelecionado;
  final LatLng? pontoInicial;
  final double altura;
  final Color cor;

  @override
  ConsumerState<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends ConsumerState<MapLocationPicker> {
  final _mapCtrl = MapController();
  LatLng? _pin;
  bool _buscandoGps = false;

  @override
  void initState() {
    super.initState();
    _pin = widget.pontoInicial;
    // GPS é a primeira tentativa pro pin inicial (pedido do usuário) — o
    // centro do município só entra se o GPS falhar/for negado.
    if (_pin == null) _resolverPontoInicial();
  }

  Future<void> _resolverPontoInicial() async {
    final ponto = await _tentarGps(silencioso: true);
    if (ponto != null) return; // já selecionado dentro de _tentarGps
    final centro = await ref.read(municipioCenterProvider.future);
    if (centro != null && mounted && _pin == null) _selecionar(centro);
  }

  Future<void> _usarLocalizacao() => _tentarGps(silencioso: false);

  /// Retorna o ponto obtido (já selecionado) ou `null` se não conseguiu.
  /// [silencioso] evita `SnackBar` na tentativa automática de abertura.
  Future<LatLng?> _tentarGps({required bool silencioso}) async {
    setState(() => _buscandoGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silencioso) _snack('GPS desativado. Toque no mapa pra marcar manualmente.');
        return null;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (!silencioso) _snack('Permissão de localização negada. Toque no mapa pra marcar manualmente.');
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final ponto = LatLng(pos.latitude, pos.longitude);
      _selecionar(ponto);
      _mapCtrl.move(ponto, 16);
      return ponto;
    } catch (_) {
      if (!silencioso) _snack('Não foi possível obter a localização agora.');
      return null;
    } finally {
      if (mounted) setState(() => _buscandoGps = false);
    }
  }

  void _snack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _selecionar(LatLng ponto) {
    setState(() => _pin = ponto);
    widget.onPontoSelecionado(ponto);
  }

  @override
  Widget build(BuildContext context) {
    final centro = _pin ?? const LatLng(-7.0762, -41.4661); // Picos-PI, fallback

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.altura,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: centro,
                initialZoom: 15,
                onTap: (_, ponto) => _selecionar(ponto),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.piaui.sisan',
                ),
                if (_pin != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pin!,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: Icon(Icons.location_on, color: widget.cor, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Toque no mapa pra marcar o ponto exato',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: FloatingActionButton.small(
                heroTag: null,
                backgroundColor: Colors.white,
                foregroundColor: widget.cor,
                onPressed: _buscandoGps ? null : _usarLocalizacao,
                child: _buscandoGps
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: widget.cor),
                      )
                    : const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
