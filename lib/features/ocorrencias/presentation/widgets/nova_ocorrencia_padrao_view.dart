import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/shared/widgets/app_text_field.dart';
import 'package:sisan/shared/widgets/map_location_picker.dart';
import 'package:sisan/shared/widgets/primary_pill_button.dart';

/// Modo padrão de "Nova Ocorrência": formulário único, mais rápido pra quem
/// já conhece o app. **Arquivado por pedido do usuário** — o modo guiado
/// (`NovaOcorrenciaGuiadaView`) virou o único caminho ativo em
/// `NovaOcorrenciaPage`; este arquivo fica pronto pra ser reconectado se um
/// dia fizer sentido oferecer os dois modos de novo.
class NovaOcorrenciaPadraoView extends ConsumerStatefulWidget {
  const NovaOcorrenciaPadraoView({super.key, required this.onEnviado});
  final ValueChanged<Ocorrencia> onEnviado;

  @override
  ConsumerState<NovaOcorrenciaPadraoView> createState() => _NovaOcorrenciaPadraoViewState();
}

class _NovaOcorrenciaPadraoViewState extends ConsumerState<NovaOcorrenciaPadraoView> {
  final _formKey = GlobalKey<FormState>();

  OcorrenciaTipo _tipo = OcorrenciaTipo.vazamento;
  final _enderecoCtrl = TextEditingController();
  LatLng? _ponto;
  final _relatoCtrl = TextEditingController();
  final List<XFile> _fotos = [];
  bool _enviando = false;

  @override
  void dispose() {
    _enderecoCtrl.dispose();
    _relatoCtrl.dispose();
    super.dispose();
  }

  Future<void> _adicionarFotos() async {
    final remaining = 5 - _fotos.length;
    if (remaining <= 0) return;
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty || !mounted) return;
    setState(() => _fotos.addAll(picked.take(remaining)));
  }

  void _removerFoto(int index) => setState(() => _fotos.removeAt(index));

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final ocorrencia = await ref.read(ocorrenciasProvider.notifier).criar(
            tipo: _tipo,
            descricao: _relatoCtrl.text.trim(),
            endereco: _enderecoCtrl.text.trim().isNotEmpty ? _enderecoCtrl.text.trim() : null,
            fotos: _fotos.map((x) => File(x.path)).toList(),
            latitude: _ponto?.latitude,
            longitude: _ponto?.longitude,
          );
      widget.onEnviado(ocorrencia);
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
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _SecaoTitulo('Tipo de ocorrência'),
          Wrap(
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

          const SizedBox(height: 20),

          _SecaoTitulo('Onde aconteceu'),
          MapLocationPicker(
            pontoInicial: _ponto,
            onPontoSelecionado: (p) => setState(() {
              _ponto = p;
              _formKey.currentState?.validate();
            }),
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Endereço, bairro ou referência',
            controller: _enderecoCtrl,
            prefixIcon: Icons.location_on_outlined,
            textCapitalization: TextCapitalization.sentences,
            validator: (v) {
              if ((v == null || v.trim().isEmpty) && _ponto == null) {
                return 'Informe o endereço ou marque um ponto no mapa';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          _SecaoTitulo('Relato', obrigatorio: true),
          AppTextField(
            label: 'Descreva o problema',
            controller: _relatoCtrl,
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

          const SizedBox(height: 20),

          if (!kIsWeb) ...[
            _SecaoTitulo('Evidências'),
            Text(
              'Fotos ajudam a agilizar o atendimento'
              '${_fotos.isEmpty ? ' — adicione até 5' : ' (${_fotos.length}/5)'}.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
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
            const SizedBox(height: 20),
          ],

          PrimaryPillButton(
            label: _enviando ? 'Enviando...' : 'Enviar Ocorrência',
            loading: _enviando,
            onTap: _enviar,
          ),
        ],
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  const _SecaoTitulo(this.titulo, {this.obrigatorio = false});
  final String titulo;
  final bool obrigatorio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (obrigatorio) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(xfile.path), width: 84, height: 84, fit: BoxFit.cover),
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
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
          color: Colors.black.withValues(alpha: 0.03),
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
