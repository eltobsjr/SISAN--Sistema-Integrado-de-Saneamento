import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/constants/alerta_sanitario_tipo.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/alertas_sanitarios/presentation/providers/alertas_sanitarios_provider.dart';
import 'package:sisan/shared/providers/municipio_center_provider.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Adaptado de `CriarAlertaPage` do SIGAU (feature `zoonoses`).
class CriarAlertaPage extends ConsumerStatefulWidget {
  const CriarAlertaPage({super.key});

  @override
  ConsumerState<CriarAlertaPage> createState() => _CriarAlertaPageState();
}

class _CriarAlertaPageState extends ConsumerState<CriarAlertaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  final _mapCtrl = MapController();

  AlertaSanitarioTipo _tipo = AlertaSanitarioTipo.esgotoCeuAbertoRecorrente;
  LatLng? _pin;
  double _raioMetros = 500;
  bool _salvando = false;
  bool _resolvendoFallbackGps = false;

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _obterFallbackGps() async {
    LatLng resolvido;
    try {
      final pos = await Geolocator.getCurrentPosition();
      resolvido = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      resolvido = const LatLng(-7.0762, -41.4661); // Picos-PI
    }
    if (mounted) setState(() => _pin = resolvido);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_pin == null) {
      ref.watch(municipioCenterProvider).whenData((centro) {
        if (centro != null) {
          _pin = centro;
        } else if (!_resolvendoFallbackGps) {
          _resolvendoFallbackGps = true;
          _obterFallbackGps();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Alerta Sanitário'),
        backgroundColor: _tipo.cor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tipo de alerta', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AlertaSanitarioTipo.values.map((t) {
                final selecionado = _tipo == t;
                return ChoiceChip(
                  avatar: Icon(t.icone, size: 16, color: selecionado ? Colors.white : t.cor),
                  label: Text(t.label),
                  selected: selecionado,
                  selectedColor: t.cor,
                  labelStyle: TextStyle(
                    color: selecionado ? Colors.white : t.cor,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _tipo = t),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _descricaoCtrl,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Descrição do alerta',
                hintText: 'Descreva o padrão observado, quantas ocorrências, há quanto tempo...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Mínimo de 10 caracteres' : null,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Raio de risco', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  _raioMetros >= 1000
                      ? '${(_raioMetros / 1000).toStringAsFixed(1)} km'
                      : '${_raioMetros.toInt()} m',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _tipo.cor),
                ),
              ],
            ),
            Slider(
              value: _raioMetros,
              min: 100,
              max: 5000,
              divisions: 49,
              activeColor: _tipo.cor,
              onChanged: (v) => setState(() => _raioMetros = v),
            ),

            const SizedBox(height: 20),

            Text('Localização do foco', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Toque no mapa para marcar o ponto', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 240,
                child: _pin == null
                    ? const Center(child: SisanLoading.compact())
                    : FlutterMap(
                        mapController: _mapCtrl,
                        options: MapOptions(
                          initialCenter: _pin!,
                          initialZoom: 13,
                          onTap: (_, latlng) => setState(() => _pin = latlng),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'br.piaui.sisan',
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: _pin!,
                                radius: _raioMetros,
                                color: _tipo.cor.withValues(alpha: 0.15),
                                borderColor: _tipo.cor,
                                borderStrokeWidth: 2,
                                useRadiusInMeter: true,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _pin!,
                                width: 36,
                                height: 36,
                                child: Icon(Icons.location_on, color: _tipo.cor, size: 36),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_alert_outlined),
              label: Text(_salvando ? 'Salvando...' : 'Criar Alerta'),
              style: FilledButton.styleFrom(backgroundColor: _tipo.cor, minimumSize: const Size(double.infinity, 48)),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pin == null) return;

    setState(() => _salvando = true);
    try {
      await ref.read(alertasSanitariosProvider.notifier).criar(
            tipo: _tipo,
            descricao: _descricaoCtrl.text.trim(),
            latitude: _pin!.latitude,
            longitude: _pin!.longitude,
            raioMetros: _raioMetros,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta criado com sucesso'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.parse(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}
