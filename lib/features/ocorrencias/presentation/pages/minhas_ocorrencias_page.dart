import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart'
    show kProtocoloOffline, ocorrenciasProvider;
import 'package:sisan/features/ocorrencias/presentation/widgets/ocorrencia_card.dart';
import 'package:sisan/shared/widgets/pending_sync_banner.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

class MinhasOcorrenciasPage extends ConsumerWidget {
  const MinhasOcorrenciasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ocorrenciasProvider);

    return Scaffold(
      appBar: SisanAppBar(title: const Text('Minhas Ocorrências')),
      body: Column(
        children: [
          const PendingSyncBanner(),
          Expanded(
            child: state.when(
              loading: () => const SkeletonList(itemCount: 6),
              error: (_, _) => SisanErrorState(
                onRetry: () => ref.invalidate(ocorrenciasProvider),
              ),
              data: (ocorrencias) {
                if (ocorrencias.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma ocorrência ainda',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.black45),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'As ocorrências que você registrar aparecerão aqui',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final grupos = _agruparPorPeriodo(ocorrencias);

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ocorrenciasProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(SisanEspaco.tela, SisanEspaco.tela, SisanEspaco.tela, SisanEspaco.xl),
                    children: [
                      DistribuicaoCard(
                        titulo: 'Seus registros',
                        icone: Icons.donut_large_outlined,
                        segmentos: [
                          for (final s in OcorrenciaStatus.values)
                            Segmento(s.label, ocorrencias.where((o) => o.status == s).length, s.cor),
                        ],
                      ),
                      for (final grupo in grupos) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, SisanEspaco.xl, 0, SisanEspaco.sm),
                          child: Text(grupo.titulo.toUpperCase(), style: SisanTexto.rotulo),
                        ),
                        for (final (i, o) in grupo.itens.indexed) ...[
                          if (i > 0) const SizedBox(height: SisanEspaco.sm),
                          OcorrenciaCard(ocorrencia: o, aguardandoSync: o.protocolo == kProtocoloOffline),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_Grupo> _agruparPorPeriodo(List<Ocorrencia> ocorrencias) {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final inicioSemana = inicioHoje.subtract(
      Duration(days: inicioHoje.weekday - 1),
    );
    final inicioMes = DateTime(hoje.year, hoje.month);

    final hojeItens = <Ocorrencia>[];
    final semanaItens = <Ocorrencia>[];
    final mesItens = <Ocorrencia>[];
    final anterioresItens = <Ocorrencia>[];

    for (final o in ocorrencias) {
      if (!o.criadoEm.isBefore(inicioHoje)) {
        hojeItens.add(o);
      } else if (!o.criadoEm.isBefore(inicioSemana)) {
        semanaItens.add(o);
      } else if (!o.criadoEm.isBefore(inicioMes)) {
        mesItens.add(o);
      } else {
        anterioresItens.add(o);
      }
    }

    return [
      if (hojeItens.isNotEmpty) _Grupo('Hoje', hojeItens),
      if (semanaItens.isNotEmpty) _Grupo('Esta semana', semanaItens),
      if (mesItens.isNotEmpty) _Grupo('Este mês', mesItens),
      if (anterioresItens.isNotEmpty) _Grupo('Anteriores', anterioresItens),
    ];
  }
}

class _Grupo {
  const _Grupo(this.titulo, this.itens);
  final String titulo;
  final List<Ocorrencia> itens;
}
