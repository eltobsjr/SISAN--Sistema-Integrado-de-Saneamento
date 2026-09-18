import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/shared/widgets/app_text_field.dart';
import 'package:sisan/shared/widgets/choice_card.dart';
import 'package:sisan/shared/widgets/map_location_picker.dart';
import 'package:sisan/shared/widgets/primary_pill_button.dart';
import 'package:sisan/shared/widgets/step_progress_bar.dart';

enum _Etapa { tipo, local, relato, fotos, revisar }

/// Modo guiado de "Nova Ocorrência": uma pergunta por tela, com barra de
/// progresso e botão de voltar por etapa — mesma mecânica do onboarding do
/// polimata-concursos (`_frame`/`_Step`/`_ChoiceCard`), pensada pra deixar o
/// registro mais acessível (telas simples, uma decisão de cada vez).
class NovaOcorrenciaGuiadaView extends ConsumerStatefulWidget {
  const NovaOcorrenciaGuiadaView({super.key, required this.onConcluido});

  final ValueChanged<Ocorrencia> onConcluido;

  @override
  ConsumerState<NovaOcorrenciaGuiadaView> createState() => _NovaOcorrenciaGuiadaViewState();
}

class _NovaOcorrenciaGuiadaViewState extends ConsumerState<NovaOcorrenciaGuiadaView> {
  static const _fluxo = [_Etapa.tipo, _Etapa.local, _Etapa.relato, _Etapa.fotos, _Etapa.revisar];

  _Etapa _etapa = _Etapa.tipo;
  OcorrenciaTipo? _tipo;
  LatLng? _ponto;
  final _enderecoCtrl = TextEditingController();
  final _relatoCtrl = TextEditingController();
  final List<XFile> _fotos = [];
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    // Reconstrói pra habilitar/desabilitar "Continuar" conforme o relato
    // atinge o mínimo de caracteres.
    _relatoCtrl.addListener(_onRelatoChanged);
  }

  void _onRelatoChanged() => setState(() {});

  @override
  void dispose() {
    _relatoCtrl.removeListener(_onRelatoChanged);
    _enderecoCtrl.dispose();
    _relatoCtrl.dispose();
    super.dispose();
  }

  int get _indice => _fluxo.indexOf(_etapa);
  _Etapa? get _anterior => _indice == 0 ? null : _fluxo[_indice - 1];

  void _avancar() {
    final proximo = _indice + 1 < _fluxo.length ? _fluxo[_indice + 1] : null;
    if (proximo != null) setState(() => _etapa = proximo);
  }

  void _voltar() {
    final anterior = _anterior;
    if (anterior != null) setState(() => _etapa = anterior);
  }

  Future<void> _adicionarFoto(ImageSource source) async {
    final foto = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (foto != null && mounted) setState(() => _fotos.add(foto));
  }

  void _mostrarPickerFoto() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _adicionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _adicionarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviar() async {
    if (_tipo == null) return;
    setState(() => _enviando = true);
    try {
      final ocorrencia = await ref.read(ocorrenciasProvider.notifier).criar(
            tipo: _tipo!,
            descricao: _relatoCtrl.text.trim(),
            endereco: _enderecoCtrl.text.trim().isNotEmpty ? _enderecoCtrl.text.trim() : null,
            fotos: _fotos.map((x) => File(x.path)).toList(),
            latitude: _ponto?.latitude,
            longitude: _ponto?.longitude,
          );
      widget.onConcluido(ocorrencia);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.parse(e))));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _anterior == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _anterior != null) _voltar();
      },
      child: switch (_etapa) {
        _Etapa.tipo => _passo(child: _passoTipo(), continuarHabilitado: _tipo != null, onContinuar: _avancar),
        _Etapa.local => _passo(child: _passoLocal(), continuarHabilitado: true, onContinuar: _avancar),
        _Etapa.relato => _passo(
            child: _passoRelato(),
            continuarHabilitado: _relatoCtrl.text.trim().length >= 15,
            onContinuar: _avancar,
          ),
        _Etapa.fotos => _passo(child: _passoFotos(), continuarHabilitado: true, onContinuar: _avancar),
        _Etapa.revisar => _passo(
            child: _passoRevisar(),
            continuarHabilitado: !_enviando,
            labelContinuar: _enviando ? 'Enviando...' : 'Enviar Ocorrência',
            onContinuar: _enviar,
          ),
      },
    );
  }

  Widget _passo({
    required Widget child,
    required bool continuarHabilitado,
    required VoidCallback onContinuar,
    String labelContinuar = 'Continuar',
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              if (_anterior != null)
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: _voltar)
              else
                const SizedBox(width: 8),
              const SizedBox(width: 4),
              Expanded(child: StepProgressBar(position: _indice + 1, total: _fluxo.length)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 16), child: child),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: PrimaryPillButton(
            label: labelContinuar,
            enabled: continuarHabilitado,
            loading: _enviando && _etapa == _Etapa.revisar,
            onTap: onContinuar,
          ),
        ),
      ],
    );
  }

  Widget _passoTipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloPasso('Qual é o problema?', 'Escolha o que mais se parece com o que você viu.'),
        for (final t in OcorrenciaTipo.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ChoiceCard(
              title: t.label,
              icone: t.icone,
              cor: t.cor,
              selected: _tipo == t,
              onTap: () => setState(() => _tipo = t),
            ),
          ),
      ],
    );
  }

  Widget _passoLocal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloPasso('Onde está acontecendo?', 'Toque no mapa ou use sua localização atual.'),
        MapLocationPicker(
          pontoInicial: _ponto,
          altura: 260,
          onPontoSelecionado: (p) => setState(() => _ponto = p),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Endereço, bairro ou referência (opcional)',
          controller: _enderecoCtrl,
          prefixIcon: Icons.location_on_outlined,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _passoRelato() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloPasso('Descreva o que você viu', 'Quanto mais detalhes, mais rápido o atendimento.'),
        AppTextField(
          label: 'Relato',
          controller: _relatoCtrl,
          maxLines: 6,
          minLines: 4,
          maxLength: 2000,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 4),
        Text(
          _relatoCtrl.text.trim().length < 15 ? 'Mínimo de 15 caracteres.' : '',
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _passoFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloPasso('Tem uma foto?', 'Opcional, mas ajuda bastante. Adicione até 5.'),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _fotos.length + (_fotos.length < 5 ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              if (i == _fotos.length) {
                return GestureDetector(
                  onTap: _mostrarPickerFoto,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: Colors.black45),
                  ),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(File(_fotos[i].path), width: 90, height: 90, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _fotos.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _passoRevisar() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloPasso('Revise antes de enviar', 'Confira se está tudo certo.'),
        _linhaResumo(Icons.category_outlined, 'Tipo', _tipo?.label ?? '—'),
        _linhaResumo(
          Icons.location_on_outlined,
          'Local',
          _enderecoCtrl.text.trim().isNotEmpty
              ? _enderecoCtrl.text.trim()
              : (_ponto != null ? 'Ponto marcado no mapa' : 'Não informado'),
        ),
        _linhaResumo(Icons.description_outlined, 'Relato', _relatoCtrl.text.trim()),
        _linhaResumo(Icons.photo_camera_outlined, 'Fotos', '${_fotos.length} adicionada${_fotos.length == 1 ? '' : 's'}'),
        const SizedBox(height: 8),
        Text(
          'Ao enviar, a concessionária do seu município vai analisar o caso.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
        ),
      ],
    );
  }

  Widget _linhaResumo(IconData icone, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Colors.black45),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.black45)),
                Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloPasso extends StatelessWidget {
  const _TituloPasso(this.titulo, this.subtitulo);
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
          ),
          const SizedBox(height: 6),
          Text(subtitulo, style: const TextStyle(fontSize: 14, color: Colors.black45)),
        ],
      ),
    );
  }
}
