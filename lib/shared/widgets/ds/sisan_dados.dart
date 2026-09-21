import 'package:flutter/material.dart';

import 'package:sisan/shared/design/sisan_tokens.dart';
import 'package:sisan/shared/widgets/ds/sisan_basicos.dart';

/// Indicador numérico (KPI) em card.
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.rodape,
    this.corRodape,
    this.onTap,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;

  /// Linha de contexto: comparação ("+3 vs. agosto") ou explicação.
  final String? rodape;
  final Color? corRodape;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SisanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SisanEspaco.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconTile(icone, cor: cor, tamanho: 30),
              const Spacer(),
              if (onTap != null) const Icon(Icons.chevron_right, size: 18, color: SisanCores.textoTerciario),
            ],
          ),
          const SizedBox(height: SisanEspaco.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: SisanCores.texto, height: 1),
            ),
          ),
          const SizedBox(height: SisanEspaco.xs),
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SisanCores.textoSecundario),
          ),
          if (rodape != null) ...[
            const SizedBox(height: 2),
            Text(
              rodape!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: corRodape ?? SisanCores.textoTerciario,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Grade 2×N de widgets com a mesma altura por linha (KPIs, atalhos).
class GradeDupla extends StatelessWidget {
  const GradeDupla({super.key, required this.children, this.espaco = SisanEspaco.md});

  final List<Widget> children;
  final double espaco;

  @override
  Widget build(BuildContext context) {
    final linhas = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (i > 0) linhas.add(SizedBox(height: espaco));
      linhas.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: espaco),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: linhas);
  }
}

/// Um número da [StatStrip].
class StatItem {
  const StatItem(this.valor, this.rotulo, {this.onTap});
  final String valor;
  final String rotulo;
  final VoidCallback? onTap;
}

/// Faixa de números sobre o gradiente do header (resumo do topo).
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.itens});
  final List<StatItem> itens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SisanEspaco.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(SisanRaio.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < itens.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: InkWell(
                  onTap: itens[i].onTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        itens[i].valor,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        itens[i].rotulo,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Uma fatia de [DistribuicaoCard].
class Segmento {
  const Segmento(this.rotulo, this.valor, this.cor);
  final String rotulo;
  final int valor;
  final Color cor;
}

/// Barra empilhada + legenda com contagem e percentual — mostra "como está
/// dividido" (status da fila, urgência, tipos) numa leitura só.
class DistribuicaoCard extends StatelessWidget {
  const DistribuicaoCard({
    super.key,
    required this.titulo,
    required this.segmentos,
    this.icone,
    this.subtitulo,
    this.vazio = 'Sem dados no período.',
  });

  final String titulo;
  final String? subtitulo;
  final IconData? icone;
  final List<Segmento> segmentos;
  final String vazio;

  @override
  Widget build(BuildContext context) {
    final total = segmentos.fold<int>(0, (a, s) => a + s.valor);
    final visiveis = segmentos.where((s) => s.valor > 0).toList();

    return SisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icone != null) ...[
                Icon(icone, size: 18, color: SisanCores.textoSecundario),
                const SizedBox(width: SisanEspaco.sm),
              ],
              Expanded(child: Text(titulo, style: SisanTexto.tituloCard)),
              Text('$total', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SisanCores.texto)),
            ],
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 2),
            Text(subtitulo!, style: SisanTexto.legenda),
          ],
          const SizedBox(height: SisanEspaco.md),
          if (total == 0)
            Text(vazio, style: SisanTexto.secundario)
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(SisanRaio.pill),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (var i = 0; i < visiveis.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(flex: visiveis[i].valor, child: Container(color: visiveis[i].cor)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: SisanEspaco.md),
            Wrap(
              spacing: SisanEspaco.lg,
              runSpacing: SisanEspaco.sm,
              children: [
                for (final s in segmentos)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: s.cor, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 6),
                      Text(s.rotulo, style: const TextStyle(fontSize: 12, color: SisanCores.textoSecundario)),
                      const SizedBox(width: 4),
                      Text(
                        '${s.valor} · ${(s.valor * 100 / total).round()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SisanCores.texto),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Ranking horizontal (ex.: bairros com mais ocorrências abertas).
class RankingCard extends StatelessWidget {
  const RankingCard({super.key, required this.titulo, required this.itens, this.icone, this.subtitulo, this.cor = SisanCores.primaria});

  final String titulo;
  final String? subtitulo;
  final IconData? icone;
  final List<(String, int)> itens;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final maximo = itens.fold<int>(0, (a, e) => e.$2 > a ? e.$2 : a);
    return SisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icone != null) ...[
                Icon(icone, size: 18, color: SisanCores.textoSecundario),
                const SizedBox(width: SisanEspaco.sm),
              ],
              Expanded(child: Text(titulo, style: SisanTexto.tituloCard)),
            ],
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 2),
            Text(subtitulo!, style: SisanTexto.legenda),
          ],
          const SizedBox(height: SisanEspaco.md),
          if (itens.isEmpty) const Text('Sem dados no período.', style: SisanTexto.secundario),
          for (final (i, (rotulo, valor)) in itens.indexed) ...[
            if (i > 0) const SizedBox(height: SisanEspaco.sm + 2),
            Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: SisanCores.textoTerciario)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(rotulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: SisanCores.texto)),
                          ),
                          Text('$valor', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SisanCores.texto)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SisanRaio.pill),
                        child: LinearProgressIndicator(
                          value: maximo == 0 ? 0 : valor / maximo,
                          minHeight: 6,
                          backgroundColor: cor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(cor.withValues(alpha: i == 0 ? 1 : 0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Barras verticais simples com rótulo embaixo (séries curtas: 7 dias).
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key, required this.valores, required this.rotulos, this.cor = SisanCores.primaria, this.altura = 96});

  final List<int> valores;
  final List<String> rotulos;
  final Color cor;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final maximo = valores.fold<int>(0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: altura,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < valores.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (valores[i] > 0)
                    Text('${valores[i]}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SisanCores.textoSecundario)),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: 18,
                    height: 4 + (altura - 40) * (maximo == 0 ? 0 : valores[i] / maximo),
                    decoration: BoxDecoration(
                      color: i == valores.length - 1 ? cor : cor.withValues(alpha: valores[i] > 0 ? 0.45 : 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rotulos[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: i == valores.length - 1 ? cor : SisanCores.textoTerciario,
                      fontWeight: i == valores.length - 1 ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Progresso por etapas compacto (usado nos cards de OS e ocorrência).
class EtapasProgresso extends StatelessWidget {
  const EtapasProgresso({super.key, required this.total, required this.atual, required this.cor});

  final int total;

  /// Índice da etapa atual (0-based).
  final int atual;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= atual ? cor : SisanCores.borda,
                borderRadius: BorderRadius.circular(SisanRaio.pill),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Atalho em card branco (grade "Gestão" / "O que deseja fazer?").
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    this.onTap,
    this.badge,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final VoidCallback? onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return SisanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(SisanEspaco.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(icone, cor: cor, tamanho: 40),
              const Spacer(),
              if (badge != null && badge! > 0) StatusBadge('$badge', cor: cor, solido: true),
            ],
          ),
          const SizedBox(height: SisanEspaco.md),
          Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SisanCores.texto)),
          const SizedBox(height: 2),
          Text(subtitulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: SisanCores.textoSecundario)),
        ],
      ),
    );
  }
}
