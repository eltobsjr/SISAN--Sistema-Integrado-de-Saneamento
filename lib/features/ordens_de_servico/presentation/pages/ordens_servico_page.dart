import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/widgets/ordem_servico_card.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';
import 'package:sisan/shared/widgets/empty_state.dart';
import 'package:sisan/shared/widgets/pending_sync_banner.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/skeleton_list.dart';

enum _Filtro { todas, semTecnico, minhas, emCampo, risco }

/// Fila de Ordens de Serviço — adaptado de `ResgatesPage` do SIGAU (feature
/// `resgates`), trocando a urgência 1-5 por [OcorrenciaUrgencia]. Filtros
/// com contagem no topo; "Com você" só pro técnico, "Em campo" só pro gestor.
class OrdensServicoPage extends ConsumerStatefulWidget {
  const OrdensServicoPage({super.key});

  @override
  ConsumerState<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends ConsumerState<OrdensServicoPage> {
  _Filtro _filtro = _Filtro.todas;

  List<OrdemServico> _ordenar(Iterable<OrdemServico> lista) {
    final copia = lista.toList();
    copia.sort((a, b) {
      final p = (b.ocorrencia.prioridade ?? 0).compareTo(a.ocorrencia.prioridade ?? 0);
      if (p != 0) return p;
      final urgDiff = b.ocorrencia.urgencia.index.compareTo(a.ocorrencia.urgencia.index);
      if (urgDiff != 0) return urgDiff;
      return a.criadoEm.compareTo(b.criadoEm);
    });
    return copia;
  }

  bool _passa(_Filtro f, OrdemServico os, String? uid) => switch (f) {
    _Filtro.todas => true,
    _Filtro.semTecnico => os.tecnicoId == null,
    _Filtro.minhas => os.tecnicoId != null && os.tecnicoId == uid,
    _Filtro.emCampo => os.tecnicoId != null,
    _Filtro.risco => os.ocorrencia.urgencia == OcorrenciaUrgencia.riscoSaude,
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordensServicoProvider);
    final usuario = ref.watch(authProvider).valueOrNull;
    final ehTecnico = usuario?.perfil == PerfilUsuario.tecnico;
    final lista = state.valueOrNull ?? const <OrdemServico>[];

    final filtros = [
      (_Filtro.todas, 'Todas', Icons.list_alt),
      (_Filtro.semTecnico, 'Aguardando técnico', Icons.hourglass_empty_rounded),
      if (ehTecnico)
        (_Filtro.minhas, 'Com você', Icons.person_outline)
      else
        (_Filtro.emCampo, 'Em campo', Icons.engineering_outlined),
      (_Filtro.risco, 'Risco à saúde', Icons.health_and_safety_outlined),
    ];

    return Scaffold(
      appBar: SisanAppBar(
        title: const Text('Ordens de serviço'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => ref.read(ordensServicoProvider.notifier).recarregar(),
          ),
        ],
      ),
      body: Column(
        children: [
          const PendingSyncBanner(),
          Container(
            color: SisanCores.superficie,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(SisanEspaco.tela, SisanEspaco.md, SisanEspaco.tela, SisanEspaco.md),
              child: Row(
                children: [
                  for (final (f, label, icone) in filtros) ...[
                    _FiltroChip(
                      label: label,
                      icone: icone,
                      contagem: lista.where((os) => _passa(f, os, usuario?.id)).length,
                      selecionado: _filtro == f,
                      cor: f == _Filtro.risco ? SisanCores.perigo : SisanCores.primaria,
                      onTap: () => setState(() => _filtro = f),
                    ),
                    const SizedBox(width: SisanEspaco.sm),
                  ],
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: state.when(
              loading: () => const SkeletonList(),
              error: (_, _) => SisanErrorState(onRetry: () => ref.read(ordensServicoProvider.notifier).recarregar()),
              data: (todas) {
                final ordenada = _ordenar(todas.where((os) => _passa(_filtro, os, usuario?.id)));
                if (ordenada.isEmpty) {
                  return EmptyState(
                    icon: Icons.check_circle_outline,
                    message: _filtro == _Filtro.todas
                        ? 'Nenhuma ordem de serviço aberta.\nTodas as ocorrências do município estão em dia.'
                        : 'Nenhuma OS neste filtro.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(ordensServicoProvider.notifier).recarregar(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(SisanEspaco.tela),
                    itemCount: ordenada.length + 1,
                    separatorBuilder: (_, i) => SizedBox(height: i == 0 ? SisanEspaco.xs : SisanEspaco.sm + 2),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Text(
                          '${ordenada.length} ordem${ordenada.length == 1 ? '' : 's'} · por urgência e antiguidade',
                          style: SisanTexto.legenda,
                        );
                      }
                      final os = ordenada[i - 1];
                      return OrdemServicoCard(
                        ordemServico: os,
                        onTap: () => context.push('/ordens-de-servico/${os.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.label,
    required this.icone,
    required this.contagem,
    required this.selecionado,
    required this.cor,
    required this.onTap,
  });

  final String label;
  final IconData icone;
  final int contagem;
  final bool selecionado;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selecionado ? Colors.white : SisanCores.textoSecundario;
    return Material(
      color: selecionado ? cor : SisanCores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SisanRaio.pill),
        side: BorderSide(color: selecionado ? cor : SisanCores.borda),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selecionado ? Colors.white.withValues(alpha: 0.25) : SisanCores.borda,
                  borderRadius: BorderRadius.circular(SisanRaio.pill),
                ),
                child: Text(
                  '$contagem',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
