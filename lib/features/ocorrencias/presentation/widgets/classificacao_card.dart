import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/constants/ocorrencia_risco.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/perfil_usuario.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart';
import 'package:sisan/features/ordens_de_servico/presentation/providers/ordens_servico_provider.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Mostra de onde veio a prioridade da ocorrência: urgência e nível de risco
/// (IA ou gestor), confirmações de moradores e a pontuação. O gestor corrige
/// a classificação daqui; [onAtualizada] recebe a ocorrência já salva.
class ClassificacaoCard extends ConsumerWidget {
  const ClassificacaoCard({super.key, required this.ocorrencia, this.onAtualizada});

  final Ocorrencia ocorrencia;
  final ValueChanged<Ocorrencia>? onAtualizada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oc = ocorrencia;
    final ehGestor = ref.watch(authProvider).valueOrNull?.perfil == PerfilUsuario.gestor;
    final classificada = oc.classificadoEm != null;

    final (origemIcone, origemTexto) = oc.classificacaoManual
        ? (Icons.verified_user_outlined, 'Corrigida pelo gestor')
        : classificada
        ? (Icons.auto_awesome_outlined, 'Classificada automaticamente por IA')
        : (Icons.hourglass_empty_rounded, 'Aguardando classificação automática');

    return SisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(origemIcone, size: 18, color: SisanCores.primaria),
              const SizedBox(width: SisanEspaco.sm),
              Expanded(child: Text(origemTexto, style: SisanTexto.tituloCard)),
              if (ehGestor)
                TextButton.icon(
                  onPressed: () => _corrigir(context, ref),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Corrigir'),
                ),
            ],
          ),
          const SizedBox(height: SisanEspaco.md),
          Wrap(
            spacing: SisanEspaco.sm,
            runSpacing: SisanEspaco.sm,
            children: [
              StatusBadge('Urgência: ${oc.urgencia.label}', cor: oc.urgencia.cor, icone: oc.urgencia.icone),
              if (oc.riscoSaude != null)
                StatusBadge(
                  'Nível de risco: ${oc.riscoSaude!.label}',
                  cor: oc.riscoSaude!.cor,
                  icone: Icons.health_and_safety_outlined,
                ),
              if (oc.confirmacoes > 0)
                StatusBadge(
                  '+${oc.confirmacoes} morador${oc.confirmacoes == 1 ? '' : 'es'} confirmou',
                  cor: SisanCores.indigo,
                  icone: Icons.groups_outlined,
                ),
              if (oc.prioridade != null)
                StatusBadge('Prioridade ${oc.prioridade}', cor: SisanCores.primariaEscura, icone: Icons.trending_up),
            ],
          ),
          if (oc.prioridade != null) ...[
            const SizedBox(height: SisanEspaco.sm),
            const Text(
              'Prioridade (0 a 120) = urgência + nível de risco + confirmações + dias em aberto.',
              style: SisanTexto.legenda,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _corrigir(BuildContext context, WidgetRef ref) async {
    final escolha = await showModalBottomSheet<(OcorrenciaUrgencia, OcorrenciaRisco)>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ReclassificarSheet(urgencia: ocorrencia.urgencia, risco: ocorrencia.riscoSaude ?? OcorrenciaRisco.baixo),
    );
    if (escolha == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final atualizada = await ref
          .read(ocorrenciaRepositoryProvider)
          .reclassificar(ocorrencia.id, escolha.$1, escolha.$2);
      ref.invalidate(ordensServicoProvider);
      ref.invalidate(ordemServicoPorIdProvider);
      ref.invalidate(prioridadesAbertasProvider);
      ref.invalidate(dashboardProvider);
      onAtualizada?.call(atualizada);
      messenger.showSnackBar(const SnackBar(content: Text('Classificação corrigida.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ErrorHandler.parse(e)), backgroundColor: SisanCores.perigo));
    }
  }
}

class _ReclassificarSheet extends StatefulWidget {
  const _ReclassificarSheet({required this.urgencia, required this.risco});
  final OcorrenciaUrgencia urgencia;
  final OcorrenciaRisco risco;

  @override
  State<_ReclassificarSheet> createState() => _ReclassificarSheetState();
}

class _ReclassificarSheetState extends State<_ReclassificarSheet> {
  late OcorrenciaUrgencia _urgencia = widget.urgencia;
  late OcorrenciaRisco _risco = widget.risco;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SisanEspaco.tela),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Corrigir classificação', style: SisanTexto.tituloSecao),
            const SizedBox(height: SisanEspaco.xs),
            const Text(
              'A correção substitui a da IA e muda a posição na fila dos técnicos.',
              style: SisanTexto.secundario,
            ),
            const SizedBox(height: SisanEspaco.lg),
            const Text('Urgência', style: SisanTexto.rotulo),
            const SizedBox(height: SisanEspaco.sm),
            Wrap(
              spacing: SisanEspaco.sm,
              children: [
                for (final u in OcorrenciaUrgencia.values)
                  ChoiceChip(
                    label: Text(u.label),
                    avatar: Icon(u.icone, size: 16, color: u.cor),
                    selected: _urgencia == u,
                    onSelected: (_) => setState(() => _urgencia = u),
                  ),
              ],
            ),
            const SizedBox(height: SisanEspaco.lg),
            const Text('Nível de risco à saúde', style: SisanTexto.rotulo),
            const SizedBox(height: SisanEspaco.sm),
            Wrap(
              spacing: SisanEspaco.sm,
              children: [
                for (final r in OcorrenciaRisco.values)
                  ChoiceChip(
                    label: Text(r.label),
                    selected: _risco == r,
                    onSelected: (_) => setState(() => _risco = r),
                  ),
              ],
            ),
            const SizedBox(height: SisanEspaco.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, (_urgencia, _risco)),
                child: const Text('Salvar correção'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
