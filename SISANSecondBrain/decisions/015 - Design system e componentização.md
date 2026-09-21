---
data: 2026-09-21
status: aceita
---

# 015 — Design system e componentização como base da UI

## Contexto

Em 21/09 as telas de técnico e gestor foram avaliadas como "pobríssimas
em design". Cada tela usava `Card`/`ListTile` padrão e cores soltas
(`Colors.orange`, `Colors.blue`…), e o fundo mudava de uma tela para
outra. O Elto pediu que a padronização e a componentização fossem a base
da mudança, com dashboards mais dinâmicos e informativos nos três perfis,
e novos cards em Ordens e Notificações.

## Decisão

1. **Tokens em um lugar só** — `lib/shared/design/sisan_tokens.dart`:
   `SisanCores` (marca, superfícies, texto, semânticas), `SisanRaio`,
   `SisanEspaco`, `SisanTexto` e `tempoRelativo()`. O `AppTheme` passa a
   ler desses tokens: fundo `#F3F6F9`, cards brancos com borda sutil e sem
   sombra, NavigationBar e divisores.
2. **Componentes compartilhados** — `lib/shared/widgets/ds/` (as telas
   importam só `ds.dart`):
   - base: `SisanAppBar` (gradiente, título à esquerda), `SisanCard` (faixa
     lateral `corDestaque`), `StatusBadge`, `IconTile`, `MetaInfo`,
     `SectionHeader`, `EmptyHint`, `AvisoBanner`;
   - dados: `KpiTile`, `GradeDupla`, `StatStrip`, `DistribuicaoCard`
     (barra empilhada + legenda com %), `RankingCard`, `MiniBarChart`,
     `EtapasProgresso`, `ActionTile`.
3. **Cores de status nos enums** — `OcorrenciaStatus.cor/icone` e
   `OrdemServicoStatus.cor/icone`, que usam os tokens. Nenhuma tela define a
   cor de status por conta própria.
4. **Cards de domínio** montados sobre o DS: `OrdemServicoCard` (faixa na
   cor da urgência, bairro, "aberta há N dias", que fica vermelho a partir
   de 48h, e progresso das 4 etapas) e `OcorrenciaCard`.
5. **Casca única das homes** — `HomeShell` + `HomeHeader` + `PerfilTab`
   (`features/home/presentation/widgets/home_widgets.dart`): bottom nav
   igual para os três perfis.

## Dashboards

- **Cidadão**: registradas, em andamento e resolvidas; registros em
  andamento; situação das ocorrências do município no mês; problemas mais
  registrados.
- **Técnico**: OS com ele, fila e concluídas em 30 dias; prioridade da fila
  com aviso de risco à saúde; fila por urgência com a contagem das paradas
  há mais de 48h; bairros com mais OS abertas; desempenho (concluídas no
  mês, tempo médio do aceite à conclusão, barras de 7 dias).
- **Gestor**: resumo da IA; o que precisa de atenção (risco sem técnico, OS
  paradas há mais de 48h); funil de atendimento; abertas por urgência;
  bairros mais afetados; atalhos de gestão. O Painel completo usa os mesmos
  componentes e ganhou a situação do mês por status.

## Consequências

- Tela nova usa `SisanAppBar` + componentes de `ds.dart`. Não usar
  `Color(0x…)` solto nem `Colors.orange` para status.
- O "bairro" vem de `Ocorrencia.bairro`, que lê o endereço no formato
  "Rua, nº - Bairro, Cidade - UF". Endereço fora desse formato fica fora
  dos rankings.
- Pegadinha: `DecoratedBox`/`ColoredBox` sem filho têm tamanho zero sob
  constraints frouxas. O gradiente da AppBar e a barra de distribuição
  sumiram por isso. Usar `SizedBox.expand` ou `Container`.
- `criar_alerta_page` mantém a AppBar na cor do tipo do alerta, que é
  semântica, de propósito.
