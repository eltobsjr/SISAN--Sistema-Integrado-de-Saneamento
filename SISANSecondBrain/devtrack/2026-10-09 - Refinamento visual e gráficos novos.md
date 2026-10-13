---
data: 2026-10-09
---

# 09/10 — Refinamento visual e gráficos novos

## Feito

Revisão do design a partir do código (tema, tokens, componentes `ds`,
`MapaPage`). Tudo **sem commit** (regra do projeto). `flutter analyze` sem
erros.

- **Tema a partir dos tokens** (`core/theme/app_theme.dart`): cor de erro,
  borda dos inputs e raios saem de `SisanCores`/`SisanRaio`. Botões
  (`Elevated`, `Outlined`, `Filled`) com alvo mínimo de 48 dp e mesmo
  padding/fonte. `SnackBarTheme` e `ChipTheme` padronizados.
- **Fonte Inter embutida** (`assets/fonts/Inter.ttf`, variável, 856 KB,
  declarada em `pubspec.yaml`; `fontFamily: 'Inter'` no tema). Embutida e
  não via `google_fonts` para funcionar offline.
- **Contraste**: `textoTerciario` de `#94A2AE` (~2,5:1) para `#66778A`.
  Tokens novos: `atencaoClara`, `sucessoClara`, `perigoClara`, `bordaForte`.
- **Cores soltas eliminadas** (~20 arquivos): `Colors.red/green/orange/
  grey/blue` e `Color(0x…)` viraram tokens (alertas, sucesso da denúncia,
  detalhe da ocorrência, mapa, insight, município, skeleton, banner de
  sync, sino, cadastro, `sisan_app`).
- **Urgência sem depender só da cor**: `OcorrenciaUrgencia.icone`; o
  `OcorrenciaCard` mostra selo com texto/ícone quando a urgência não é
  normal; marcador do mapa ganhou selo de urgência no canto.
- **Gráficos novos**:
  - `DistribuicaoCard`: rosca (`fl_chart` `PieChart`) com total no centro
    e legenda com contagem e %.
  - `TendenciaChart`: linhas suaves com área em degradê, pontos e tooltip
    (registradas × resolvidas, 6 meses).
  - `HeatmapTipoGrid`: barras horizontais por tipo, ordenadas, com ícone e
    cor do tipo (a mesma do mapa).
  - `KpiTile`: faixa de acento na cor do KPI e número maior.
- **Painel do gestor**: seção "Prioridades de hoje" (até 3 ocorrências
  abertas com urgência, risco à saúde primeiro). Usa só
  `stats.ultimasOcorrencias`, então não enxerga ocorrências mais antigas.

## Verificação

- Build web (`flutter build web --release --no-tree-shake-icons`) servida
  em `localhost:8099`; a tela de login renderiza com Inter.
- **Dashboards, mapa e ordens NÃO foram conferidos visualmente**: o login
  precisa da senha de demo (fora do repo). Os prints dos 3 perfis ficaram
  pendentes.

## Pegadinhas

- Rodei `dart format` sem `-l 120` e ele reformatou o projeto todo (o
  projeto usa linhas largas). Revertido nos arquivos não editados; nos
  editados sobrou algum ruído de formatação. **Sempre usar
  `dart format -l 120` e só nos arquivos tocados.**
- No zsh, `$var` com vários caminhos não é separado em palavras; usar
  `$(...)` ou `${=var}`.
- Trocar `const Color(0x…)` por `SisanCores.x` deixa um `const` sobrando
  (`const SisanCores.x` não compila) e `.withValues()` não é const.

## Pendências

- Fazer login na build web (ou informar a senha) e conferir por print os 3
  perfis; ajustar o que ficar feio.
- Revisar o fluxo de denúncia do cidadão (progresso, banner de sync,
  protocolo).
- Opcional: tema escuro (baixa prioridade para técnico em campo).
- Herdadas: setup do OneSignal (Kassio), "Leaked password protection"
  (Elto), pitch e demo (apresentação gravada em 14/10).
