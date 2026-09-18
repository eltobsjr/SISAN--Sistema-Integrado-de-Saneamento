import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/shared/widgets/foto_viewer.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// Ponto de entrada da rota `/ocorrencias/:id`. Quando chega via lista (extra
/// já carregado) renderiza direto; senão busca por id — evita loading infinito
/// (mesma lição do SIGAU pra `resgates`/`denuncias`).
class OcorrenciaDetalhePage extends ConsumerWidget {
  const OcorrenciaDetalhePage({super.key, required this.id, this.ocorrencia});

  final String id;
  final Ocorrencia? ocorrencia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ocorrencia != null) {
      return _OcorrenciaDetalheView(ocorrencia: ocorrencia!);
    }

    final porId = ref.watch(ocorrenciaPorIdProvider(id));
    return porId.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ocorrência')),
        body: const Center(child: SisanLoading.compact()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Ocorrência')),
        body: SisanErrorState(onRetry: () => ref.invalidate(ocorrenciaPorIdProvider(id))),
      ),
      data: (o) => _OcorrenciaDetalheView(ocorrencia: o),
    );
  }
}

class _OcorrenciaDetalheView extends StatelessWidget {
  const _OcorrenciaDetalheView({required this.ocorrencia});
  final Ocorrencia ocorrencia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tipo = ocorrencia.tipo;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 88,
            backgroundColor: tipo.cor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                tipo.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                      if (ocorrencia.urgencia != OcorrenciaUrgencia.normal) _UrgenciaBadge(urgencia: ocorrencia.urgencia),
                      const Spacer(),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(ocorrencia.criadoEm),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
                      ),
                    ],
                  ),
                  if (ocorrencia.protocolo != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.tag_rounded, size: 14, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(
                          ocorrencia.protocolo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  Text('Acompanhamento', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _StatusTimeline(status: ocorrencia.status),

                  const SizedBox(height: 20),

                  if (ocorrencia.endereco != null || ocorrencia.latitude != null) ...[
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: Colors.red),
                        title: const Text('Local'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ocorrencia.endereco != null) Text(ocorrencia.endereco!),
                            if (ocorrencia.latitude != null)
                              Text(
                                '${ocorrencia.latitude!.toStringAsFixed(5)}, ${ocorrencia.longitude!.toStringAsFixed(5)}',
                                style: const TextStyle(fontSize: 11, color: Colors.black38),
                              ),
                          ],
                        ),
                        isThreeLine: ocorrencia.endereco != null && ocorrencia.latitude != null,
                        dense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (ocorrencia.fotos.isNotEmpty) ...[
                    Text('Fotos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ocorrencia.fotos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => showFotoViewer(context, ocorrencia.fotos, i),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: ocorrencia.fotos[i],
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                width: 140,
                                height: 140,
                                color: Colors.black12,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text('Relato', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      ocorrencia.descricao,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});
  final OcorrenciaStatus status;

  static const _etapas = [
    OcorrenciaStatus.pendente,
    OcorrenciaStatus.emAnalise,
    OcorrenciaStatus.resolvida,
    OcorrenciaStatus.arquivada,
  ];

  @override
  Widget build(BuildContext context) {
    final atualIndex = _etapas.indexOf(status);
    final theme = Theme.of(context);

    return Column(
      children: List.generate(_etapas.length, (i) {
        final etapa = _etapas[i];
        final alcancada = i <= atualIndex;
        final ehAtual = i == atualIndex;
        final ultimo = i == _etapas.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: alcancada ? theme.colorScheme.primary : Colors.grey.shade300,
                      border: ehAtual
                          ? Border.all(color: theme.colorScheme.primary, width: 3)
                          : null,
                    ),
                    child: alcancada
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  if (!ultimo)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: i < atualIndex ? theme.colorScheme.primary : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  etapa.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: ehAtual ? FontWeight.bold : FontWeight.normal,
                    color: alcancada ? Colors.black87 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _UrgenciaBadge extends StatelessWidget {
  const _UrgenciaBadge({required this.urgencia});
  final OcorrenciaUrgencia urgencia;

  @override
  Widget build(BuildContext context) {
    final cor = urgencia.cor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.35)),
      ),
      child: Text(
        urgencia.label,
        style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
