import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/constants/checklist_encerramento.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/shared/widgets/foto_viewer.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Adaptado de `ResgateDetalhePage` do SIGAU (feature `resgates`): mesma
/// timeline de status, mini-mapa e botão de ação contextual — mas o
/// encerramento aqui exige checklist completo + foto do depois
/// (decisions/005), em vez do fluxo opcional do SIGAU.
class OrdemServicoDetalhePage extends ConsumerWidget {
  const OrdemServicoDetalhePage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordensServicoProvider);
    final os = state.valueOrNull?.where((o) => o.id == id).firstOrNull;

    if (os != null) {
      return _OrdemServicoDetalheView(ordemServico: os);
    }

    // Não está na fila (já concluída, ou a lista ainda não carregou) —
    // busca direto por id.
    final porId = ref.watch(ordemServicoPorIdProvider(id));
    return porId.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ordem de Serviço')),
        body: const Center(child: SisanLoading.compact()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ordem de Serviço')),
        body: SisanErrorState(
          onRetry: () => ref.invalidate(ordemServicoPorIdProvider(id)),
        ),
      ),
      data: (os) => _OrdemServicoDetalheView(ordemServico: os),
    );
  }
}

class _OrdemServicoDetalheView extends ConsumerStatefulWidget {
  const _OrdemServicoDetalheView({required this.ordemServico});
  final OrdemServico ordemServico;

  @override
  ConsumerState<_OrdemServicoDetalheView> createState() =>
      _OrdemServicoDetalheViewState();
}

class _OrdemServicoDetalheViewState
    extends ConsumerState<_OrdemServicoDetalheView> {
  bool _loading = false;

  String get _meuId => ref.read(authProvider).valueOrNull?.id ?? '';

  bool get _isMinha => widget.ordemServico.tecnicoId == _meuId;

  Future<void> _executar(Future<void> Function() acao) async {
    setState(() => _loading = true);
    try {
      await acao();
      if (mounted && widget.ordemServico.status == OrdemServicoStatus.aCaminho) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.parse(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _aceitar() => _executar(
        () => ref.read(ordensServicoProvider.notifier).aceitar(widget.ordemServico.id),
      );

  Future<void> _registrarChegada() => _executar(() async {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('GPS desativado. Ative a localização.');

        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          throw Exception('Permissão de localização negada.');
        }

        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        await ref.read(ordensServicoProvider.notifier).registrarChegada(
              widget.ordemServico.id,
              latitude: pos.latitude,
              longitude: pos.longitude,
            );
      });

  void _abrirConclusao(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => _ConclusaoBottomSheet(
        ordemServico: widget.ordemServico,
        onConcluir: (checklist, fotos) {
          Navigator.pop(sheetCtx);
          _executar(
            () => ref.read(ordensServicoProvider.notifier).concluir(
                  widget.ordemServico.id,
                  checklist: checklist,
                  fotosDepois: fotos,
                ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final os = widget.ordemServico;
    final ocorrencia = os.ocorrencia;
    final temCoordenadas = ocorrencia.latitude != null && ocorrencia.longitude != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Ordem de Serviço')),
      body: Column(
        children: [
          if (temCoordenadas)
            _MiniMapa(
              ponto: LatLng(ocorrencia.latitude!, ocorrencia.longitude!),
              cor: ocorrencia.urgencia.cor,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black.withValues(alpha: 0.04),
              child: Row(
                children: [
                  const Icon(Icons.location_off_outlined, color: Colors.black38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ocorrencia.endereco ?? 'Localização não informada',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusTimeline(status: os.status),
                  const SizedBox(height: 20),
                  Text(
                    ocorrencia.tipo.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (ocorrencia.protocolo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      ocorrencia.protocolo!,
                      style: const TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(ocorrencia.descricao),
                  const SizedBox(height: 16),
                  _InfoGrid(ordemServico: os),
                  if (ocorrencia.fotos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _FotosSection(titulo: 'Fotos da denúncia', urls: ocorrencia.fotos),
                  ],
                  if (os.fotosDepois.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _FotosSection(titulo: 'Fotos do reparo', urls: os.fotosDepois),
                  ],
                  const SizedBox(height: 24),
                  _BotaoAcao(
                    ordemServico: os,
                    isMinha: _isMinha,
                    loading: _loading,
                    onAceitar: _aceitar,
                    onChegada: _registrarChegada,
                    onConcluir: () => _abrirConclusao(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MINI MAPA ────────────────────────────────────────────────────────────

class _MiniMapa extends StatelessWidget {
  const _MiniMapa({required this.ponto, required this.cor});
  final LatLng ponto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        useSafeArea: false,
        builder: (_) => Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              leading: const CloseButton(),
              title: const Text('Localização da Ocorrência'),
            ),
            body: FlutterMap(
              options: MapOptions(initialCenter: ponto, initialZoom: 16, maxZoom: 19),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.piaui.sisan',
                ),
                MarkerLayer(markers: [_marcador(ponto, cor, size: 40)]),
              ],
            ),
          ),
        ),
      ),
      child: AbsorbPointer(
        child: SizedBox(
          height: 200,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: ponto,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.piaui.sisan',
              ),
              MarkerLayer(markers: [_marcador(ponto, cor, size: 36)]),
            ],
          ),
        ),
      ),
    );
  }

  Marker _marcador(LatLng ponto, Color cor, {required double size}) => Marker(
        point: ponto,
        width: size,
        height: size,
        child: Icon(Icons.location_pin, color: cor, size: size),
      );
}

// ─── STATUS TIMELINE ──────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});
  final OrdemServicoStatus status;

  static const _etapas = [
    (OrdemServicoStatus.pendente, 'Pendente', Icons.hourglass_empty),
    (OrdemServicoStatus.aceita, 'Aceita', Icons.assignment_turned_in_outlined),
    (OrdemServicoStatus.aCaminho, 'A caminho', Icons.location_on),
    (OrdemServicoStatus.concluida, 'Concluída', Icons.check_circle),
  ];

  int get _indiceAtual => _etapas.indexWhere((e) => e.$1 == status).clamp(0, 3);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(_etapas.length, (i) {
        final (_, label, icone) = _etapas[i];
        final feito = i <= _indiceAtual;
        final atual = i == _indiceAtual;

        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(height: 2, color: feito ? primary : Colors.black12),
                ),
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: atual ? 36 : 28,
                    height: atual ? 36 : 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: feito ? primary : Colors.black12,
                    ),
                    child: Icon(
                      icone,
                      size: atual ? 20 : 14,
                      color: feito ? Colors.white : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: atual ? FontWeight.bold : FontWeight.normal,
                      color: feito ? primary : Colors.black38,
                    ),
                  ),
                ],
              ),
              if (i < _etapas.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < _indiceAtual ? primary : Colors.black12,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── INFO GRID ────────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.ordemServico});
  final OrdemServico ordemServico;

  @override
  Widget build(BuildContext context) {
    final ocorrencia = ordemServico.ocorrencia;
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            label: 'Urgência',
            valor: ocorrencia.urgencia.label,
            icone: Icons.warning_amber_rounded,
            cor: ocorrencia.urgencia.cor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            label: 'Endereço',
            valor: ocorrencia.endereco ?? 'Não informado',
            icone: Icons.location_on_outlined,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.valor, required this.icone, this.cor});
  final String label;
  final String valor;
  final IconData icone;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = cor ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: c, size: 20),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.black45)),
          const SizedBox(height: 2),
          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─── BOTÃO DE AÇÃO ────────────────────────────────────────────────────────

class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({
    required this.ordemServico,
    required this.isMinha,
    required this.loading,
    required this.onAceitar,
    required this.onChegada,
    required this.onConcluir,
  });

  final OrdemServico ordemServico;
  final bool isMinha;
  final bool loading;
  final VoidCallback onAceitar;
  final VoidCallback onChegada;
  final VoidCallback onConcluir;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const FilledButton(
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }

    return switch (ordemServico.status) {
      OrdemServicoStatus.pendente => FilledButton.icon(
          onPressed: onAceitar,
          icon: const Icon(Icons.assignment_turned_in_outlined),
          label: const Text('Aceitar Ordem de Serviço'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.orange,
          ),
        ),
      OrdemServicoStatus.aceita when isMinha => FilledButton.icon(
          onPressed: onChegada,
          icon: const Icon(Icons.location_on),
          label: const Text('Registrar Chegada'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.blue,
          ),
        ),
      OrdemServicoStatus.aCaminho when isMinha => FilledButton.icon(
          onPressed: onConcluir,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Concluir Ordem de Serviço'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.green,
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── BOTTOM SHEET DE CONCLUSÃO ────────────────────────────────────────────

class _ConclusaoBottomSheet extends StatefulWidget {
  const _ConclusaoBottomSheet({required this.ordemServico, required this.onConcluir});
  final OrdemServico ordemServico;
  final void Function(Map<String, bool> checklist, List<File> fotos) onConcluir;

  @override
  State<_ConclusaoBottomSheet> createState() => _ConclusaoBottomSheetState();
}

class _ConclusaoBottomSheetState extends State<_ConclusaoBottomSheet> {
  late final Map<String, bool> _checklist = {
    for (final item in ChecklistEncerramento.itensPara(widget.ordemServico.ocorrencia.tipo))
      item: false,
  };
  final List<XFile> _fotos = [];
  final _picker = ImagePicker();

  bool get _checklistCompleto => _checklist.values.isNotEmpty && _checklist.values.every((v) => v);
  bool get _podeConcluir => _checklistCompleto && _fotos.isNotEmpty;

  Future<void> _adicionarFoto(ImageSource source) async {
    final foto = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (foto != null && mounted) setState(() => _fotos.add(foto));
  }

  void _mostrarPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (pickerCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(pickerCtx);
                _adicionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(pickerCtx);
                _adicionarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Concluir Ordem de Serviço', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Checklist e ao menos 1 foto do depois são obrigatórios.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
            const SizedBox(height: 16),
            ..._checklist.keys.map(
              (item) => CheckboxListTile(
                value: _checklist[item],
                onChanged: (v) => setState(() => _checklist[item] = v ?? false),
                title: Text(item, style: const TextStyle(fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text('Foto do depois *', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _fotos.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == _fotos.length) {
                    return _BotaoAdicionarThumb(onTap: _mostrarPicker);
                  }
                  return _ThumbFoto(
                    foto: _fotos[i],
                    onRemover: () => setState(() => _fotos.removeAt(i)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _podeConcluir
                  ? () => widget.onConcluir(
                        _checklist,
                        _fotos.map((x) => File(x.path)).toList(),
                      )
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Concluir Ordem de Serviço'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ThumbFoto extends StatelessWidget {
  const _ThumbFoto({required this.foto, required this.onRemover});
  final XFile foto;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: kIsWeb
              ? Image.network(foto.path, width: 80, height: 80, fit: BoxFit.cover)
              : Image.file(File(foto.path), width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemover,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoAdicionarThumb extends StatelessWidget {
  const _BotaoAdicionarThumb({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.black45),
      ),
    );
  }
}

// ─── CARROSSEL DE FOTOS ───────────────────────────────────────────────────

class _FotosSection extends StatelessWidget {
  const _FotosSection({required this.titulo, required this.urls});
  final String titulo;
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _abrirViewer(context, urls, i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: urls[i],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.black12,
                    child: const Icon(Icons.image, color: Colors.black26),
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image, color: Colors.black26),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _abrirViewer(BuildContext context, List<String> urls, int index) {
    showFotoViewer(context, urls, index);
  }
}
