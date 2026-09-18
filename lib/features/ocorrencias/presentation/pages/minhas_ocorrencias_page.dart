import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

class MinhasOcorrenciasPage extends ConsumerWidget {
  const MinhasOcorrenciasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ocorrenciasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Ocorrências')),
      body: state.when(
        loading: () => const SkeletonList(itemCount: 6),
        error: (_, _) => SisanErrorState(onRetry: () => ref.invalidate(ocorrenciasProvider)),
        data: (ocorrencias) {
          if (ocorrencias.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma ocorrência ainda',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black45),
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: grupos.length,
              itemBuilder: (_, i) {
                final grupo = grupos[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Text(
                        grupo.titulo,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...grupo.itens.map((o) => Column(
                          children: [
                            _OcorrenciaTile(ocorrencia: o),
                            const Divider(height: 1, indent: 68),
                          ],
                        )),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<_Grupo> _agruparPorPeriodo(List<Ocorrencia> ocorrencias) {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final inicioSemana = inicioHoje.subtract(Duration(days: inicioHoje.weekday - 1));
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

class _OcorrenciaTile extends StatelessWidget {
  const _OcorrenciaTile({required this.ocorrencia});
  final Ocorrencia ocorrencia;

  Color _statusCor(OcorrenciaStatus s) => switch (s) {
        OcorrenciaStatus.pendente => Colors.orange,
        OcorrenciaStatus.emAnalise => Colors.blue,
        OcorrenciaStatus.resolvida => Colors.green,
        OcorrenciaStatus.arquivada => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final tipo = ocorrencia.tipo;
    final statusCor = _statusCor(ocorrencia.status);

    return ListTile(
      onTap: () => context.push('/ocorrencias/${ocorrencia.id}', extra: ocorrencia),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: tipo.cor.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(tipo.icone, color: tipo.cor, size: 20),
      ),
      title: Text(tipo.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ocorrencia.protocolo != null)
            Text(ocorrencia.protocolo!, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusCor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ocorrencia.status.label,
                  style: TextStyle(fontSize: 10, color: statusCor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(ocorrencia.criadoEm),
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
    );
  }
}
