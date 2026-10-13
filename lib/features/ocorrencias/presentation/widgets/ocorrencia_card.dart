import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/core/constants/ocorrencia_status.dart';
import 'package:sisan/core/constants/ocorrencia_urgencia.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/shared/widgets/ds/ds.dart';

/// Card de ocorrência — home do cidadão, "Minhas Ocorrências" e últimas
/// ocorrências do Painel. [compacto] esconde a barra de progresso.
class OcorrenciaCard extends StatelessWidget {
  const OcorrenciaCard({super.key, required this.ocorrencia, this.compacto = false, this.aguardandoSync = false});

  final Ocorrencia ocorrencia;
  final bool compacto;

  /// Registrada offline e ainda não enviada: sem detalhe navegável.
  final bool aguardandoSync;

  // Arquivada fica fora da trilha principal: mostra como etapa final.
  static const _trilha = [OcorrenciaStatus.pendente, OcorrenciaStatus.emAnalise, OcorrenciaStatus.resolvida];

  @override
  Widget build(BuildContext context) {
    final oc = ocorrencia;
    final etapa = oc.status == OcorrenciaStatus.arquivada ? 2 : _trilha.indexOf(oc.status);

    return SisanCard(
      onTap: aguardandoSync ? null : () => context.push('/ocorrencias/${oc.id}', extra: oc),
      corDestaque: oc.urgencia == OcorrenciaUrgencia.normal ? null : oc.urgencia.cor,
      padding: EdgeInsets.fromLTRB(
        oc.urgencia == OcorrenciaUrgencia.normal ? SisanEspaco.md + 2 : SisanEspaco.lg + 4,
        SisanEspaco.md + 2,
        SisanEspaco.md + 2,
        SisanEspaco.md + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(oc.tipo.icone, cor: oc.tipo.cor, tamanho: compacto ? 36 : 42),
              const SizedBox(width: SisanEspaco.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oc.tipo.label, style: SisanTexto.tituloCard),
                    const SizedBox(height: 2),
                    Text(
                      aguardandoSync
                          ? 'Aguardando conexão para enviar'
                          : '${oc.bairro ?? oc.protocolo ?? ''} · ${tempoRelativo(oc.criadoEm)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SisanTexto.secundario,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SisanEspaco.sm),
              aguardandoSync
                  ? const StatusBadge('Na fila', cor: SisanCores.neutro, icone: Icons.cloud_upload_outlined)
                  : StatusBadge(oc.status.label, cor: oc.status.cor, icone: oc.status.icone),
            ],
          ),
          if (oc.urgencia != OcorrenciaUrgencia.normal && !aguardandoSync) ...[
            const SizedBox(height: SisanEspaco.sm),
            StatusBadge(oc.urgencia.label, cor: oc.urgencia.cor, icone: oc.urgencia.icone),
          ],
          if (!compacto && !aguardandoSync) ...[
            const SizedBox(height: SisanEspaco.md),
            EtapasProgresso(total: 3, atual: etapa, cor: oc.status.cor),
          ],
        ],
      ),
    );
  }
}
