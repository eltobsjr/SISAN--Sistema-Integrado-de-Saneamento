import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/core/constants/ordem_servico_status.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ordens_de_servico/domain/entities/ordem_servico.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Card de uma OS — usado na tela de Ordens e nos painéis do técnico e do
/// gestor. Faixa lateral na cor da urgência, status em pílula, bairro e
/// idade da OS (vermelha quando passa de 48h aberta) e progresso das 4
/// etapas (pendente → aceita → a caminho → concluída).
class OrdemServicoCard extends StatelessWidget {
  const OrdemServicoCard({super.key, required this.ordemServico, required this.onTap});

  final OrdemServico ordemServico;
  final VoidCallback onTap;

  static const _limiteAtrasoHoras = 48;

  @override
  Widget build(BuildContext context) {
    final os = ordemServico;
    final oc = os.ocorrencia;
    final isMinha = os.tecnicoId != null && os.tecnicoId == Supabase.instance.client.auth.currentUser?.id;
    final aberta = os.status != OrdemServicoStatus.concluida;
    final atrasada = aberta && DateTime.now().difference(os.criadoEm).inHours >= _limiteAtrasoHoras;
    final etapa = OrdemServicoStatus.values.indexOf(os.status);

    return SisanCard(
      onTap: onTap,
      corDestaque: oc.urgencia.cor,
      padding: const EdgeInsets.fromLTRB(SisanEspaco.lg + 4, SisanEspaco.md + 2, SisanEspaco.md + 2, SisanEspaco.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(oc.tipo.icone, cor: oc.tipo.cor, tamanho: 42),
              const SizedBox(width: SisanEspaco.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oc.tipo.label, style: SisanTexto.tituloCard),
                    const SizedBox(height: 2),
                    Text(
                      oc.bairro ?? oc.endereco ?? oc.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SisanTexto.secundario,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SisanEspaco.sm),
              StatusBadge(os.status.label, cor: os.status.cor, icone: os.status.icone),
            ],
          ),
          const SizedBox(height: SisanEspaco.md),
          Row(
            children: [
              if (oc.urgencia != OcorrenciaUrgencia.normal) ...[
                StatusBadge(
                  oc.urgencia.label,
                  cor: oc.urgencia.cor,
                  icone: oc.urgencia == OcorrenciaUrgencia.riscoSaude
                      ? Icons.health_and_safety_outlined
                      : Icons.warning_amber_rounded,
                ),
                const SizedBox(width: SisanEspaco.sm),
              ],
              if (isMinha) ...[
                const StatusBadge('Com você', cor: SisanCores.primaria, icone: Icons.person_outline),
                const SizedBox(width: SisanEspaco.sm),
              ],
              Expanded(
                child: MetaInfo(
                  atrasada ? Icons.schedule : Icons.access_time,
                  'aberta ${tempoRelativo(os.criadoEm)}',
                  cor: atrasada ? SisanCores.perigo : SisanCores.textoTerciario,
                  flex: true,
                ),
              ),
              if (oc.protocolo != null)
                Text(oc.protocolo!, style: const TextStyle(fontSize: 11, color: SisanCores.textoTerciario)),
            ],
          ),
          const SizedBox(height: SisanEspaco.md),
          EtapasProgresso(total: 4, atual: etapa, cor: os.status.cor),
        ],
      ),
    );
  }
}
