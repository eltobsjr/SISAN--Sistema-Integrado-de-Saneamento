import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart'
    show kProtocoloOffline, ocorrenciasProvider;

class NovaOcorrenciaPage extends ConsumerStatefulWidget {
  const NovaOcorrenciaPage({super.key});

  @override
  ConsumerState<NovaOcorrenciaPage> createState() => _NovaOcorrenciaPageState();
}

class _NovaOcorrenciaPageState extends ConsumerState<NovaOcorrenciaPage> {
  final _formKey = GlobalKey<FormState>();

  OcorrenciaTipo _tipo = OcorrenciaTipo.vazamento;

  final _enderecoCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  bool _buscandoGps = false;

  final _relatoCtrl = TextEditingController();
  final List<XFile> _fotos = [];

  bool _enviando = false;
  Ocorrencia? _ocorrenciaEnviada;

  @override
  void dispose() {
    _enderecoCtrl.dispose();
    _relatoCtrl.dispose();
    super.dispose();
  }

  // ─── GPS ──────────────────────────────────────────────────────────────────

  Future<void> _usarLocalizacao() async {
    setState(() => _buscandoGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsSnack('GPS desativado. Informe o endereço manualmente.');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Permissão negada. Habilite a localização nas Configurações.',
              ),
              action: SnackBarAction(
                label: 'Configurações',
                onPressed: Geolocator.openAppSettings,
              ),
            ),
          );
        }
        return;
      }
      if (perm == LocationPermission.denied) return;

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        _gpsSnack('Não foi possível obter a localização.');
        return;
      }

      if (mounted) {
        setState(() {
          _lat = pos!.latitude;
          _lng = pos.longitude;
        });
        _formKey.currentState?.validate();
      }
    } catch (e) {
      _gpsSnack('Erro ao obter localização: ${ErrorHandler.parse(e)}');
    } finally {
      if (mounted) setState(() => _buscandoGps = false);
    }
  }

  void _gpsSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ─── Fotos ────────────────────────────────────────────────────────────────

  Future<void> _adicionarFotos() async {
    final remaining = 5 - _fotos.length;
    if (remaining <= 0) return;
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty || !mounted) return;
    setState(() => _fotos.addAll(picked.take(remaining)));
  }

  void _removerFoto(int index) => setState(() => _fotos.removeAt(index));

  // ─── Envio ────────────────────────────────────────────────────────────────

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final ocorrencia = await ref.read(ocorrenciasProvider.notifier).criar(
            tipo: _tipo,
            descricao: _relatoCtrl.text.trim(),
            endereco: _enderecoCtrl.text.trim().isNotEmpty
                ? _enderecoCtrl.text.trim()
                : null,
            fotos: _fotos.map((x) => File(x.path)).toList(),
            latitude: _lat,
            longitude: _lng,
          );
      if (mounted) setState(() => _ocorrenciaEnviada = ocorrencia);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.parse(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_ocorrenciaEnviada != null) {
      return _SucessoScreen(ocorrencia: _ocorrenciaEnviada!);
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ocorrência'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Minhas ocorrências',
            onPressed: () => context.push('/ocorrencias'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SecaoTitulo('Tipo de ocorrência'),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OcorrenciaTipo.values.map((t) {
                    final sel = _tipo == t;
                    return ChoiceChip(
                      avatar: Icon(t.icone, size: 16, color: sel ? Colors.white : t.cor),
                      label: Text(t.label),
                      selected: sel,
                      selectedColor: t.cor,
                      showCheckmark: sel,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.black87,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _tipo = t),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _SecaoTitulo('Onde aconteceu'),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _enderecoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Endereço, bairro ou referência',
                        hintText: 'Ex: Rua das Flores, 123, centro',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) {
                        if ((v == null || v.trim().isEmpty) && _lat == null) {
                          return 'Informe o endereço ou use sua localização atual';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _buscandoGps ? null : _usarLocalizacao,
                            icon: _buscandoGps
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.gps_fixed_rounded, size: 18),
                            label: Text(
                              _buscandoGps ? 'Obtendo localização...' : 'Usar minha localização',
                            ),
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                          ),
                        ),
                        if (_lat != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Icon(Icons.check_rounded, color: Colors.green.shade700, size: 18),
                          ),
                        ],
                      ],
                    ),
                    if (_lat != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Coordenadas registradas (${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)})',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _SecaoTitulo('Relato', obrigatorio: true),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _relatoCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Descreva o problema com o máximo de detalhes possível.',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  minLines: 4,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.trim().length < 15) {
                      return 'Descreva o ocorrido com pelo menos 15 caracteres';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (!kIsWeb) ...[
              _SecaoTitulo('Evidências'),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fotos ajudam a agilizar o atendimento'
                        '${_fotos.isEmpty ? ' — adicione até 5' : ' (${_fotos.length}/5)'}.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 84,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._fotos.asMap().entries.map(
                                  (e) => _FotoThumb(xfile: e.value, onRemove: () => _removerFoto(e.key)),
                                ),
                            if (_fotos.length < 5) _BotaoAdicionarFoto(onTap: _adicionarFotos),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed: _enviando ? null : _enviar,
              icon: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_enviando ? 'Enviando...' : 'Enviar Ocorrência'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _SecaoTitulo extends StatelessWidget {
  const _SecaoTitulo(this.titulo, {this.obrigatorio = false});
  final String titulo;
  final bool obrigatorio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (obrigatorio)
            const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _FotoThumb extends StatelessWidget {
  const _FotoThumb({required this.xfile, required this.onRemove});
  final XFile xfile;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(xfile.path), width: 80, height: 80, fit: BoxFit.cover),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoAdicionarFoto extends StatelessWidget {
  const _BotaoAdicionarFoto({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26),
          color: Colors.grey.shade100,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.black45, size: 24),
            SizedBox(height: 4),
            Text('Foto', style: TextStyle(fontSize: 11, color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}

// ─── Tela de sucesso ─────────────────────────────────────────────────────────

class _SucessoScreen extends StatelessWidget {
  const _SucessoScreen({required this.ocorrencia});
  final Ocorrencia ocorrencia;

  @override
  Widget build(BuildContext context) {
    final protocolo = ocorrencia.protocolo;
    final offline = protocolo == kProtocoloOffline;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (offline ? Colors.orange : Colors.green).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    offline ? Icons.cloud_off_rounded : Icons.water_drop_rounded,
                    size: 44,
                    color: offline ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  offline ? 'Ocorrência salva!' : 'Ocorrência registrada!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  offline
                      ? 'Sem conexão no momento — sua ocorrência foi salva neste aparelho e será enviada automaticamente assim que você tiver internet.'
                      : 'Sua ocorrência foi enviada. A concessionária do seu município vai analisar o caso.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                ),
                if (protocolo != null && !offline) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Número de protocolo',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          protocolo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: protocolo));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Protocolo copiado!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copiar protocolo'),
                          style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/cidadao'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Voltar para o início'),
                  style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
