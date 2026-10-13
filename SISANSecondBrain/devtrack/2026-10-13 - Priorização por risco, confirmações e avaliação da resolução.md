---
data: 2026-10-13
---

# 13/10: priorização por risco, confirmações e avaliação da resolução

Revisão crítica do app na véspera da gravação (14/10), seguida das correções.

## Problemas encontrados

1. **"Prioridades de hoje" filtrava só as 5 ocorrências mais recentes**
   (`stats.ultimasOcorrencias`). Um caso grave mais antigo sumia do painel.
2. **A classificação da IA ficava invisível.** `risco_saude` não aparecia em
   nenhuma tela, e nada mostrava que a urgência vinha da IA.
3. **"Risco à saúde" com dois sentidos:** valor de `urgencia` e coluna
   `risco_saude`. Na interface, agora é "Urgência" e "Nível de risco".
4. **O gestor não conseguia corrigir a IA.**
5. **Denúncias duplicadas** do mesmo problema viravam várias OS.
6. **Sem retorno do cidadão** depois da conclusão da OS.
7. A linha do tempo da ocorrência mostrava "Arquivada" como etapa depois de "Resolvida".

## Feito

### Banco (MCP `supabase-sisan`, projeto `gzoosgugbgbtcrjhfoot` conferido)

- `20261013120000_priorizacao_confirmacoes_avaliacao.sql`:
  - colunas `confirmacoes`, `classificacao_manual`, `avaliacao_cidadao`,
    `avaliado_em`; check em `risco_saude`; índice GiST em `localizacao`
  - tabela `ocorrencia_confirmacoes` com RLS (select só das próprias; escrita só via RPC)
  - campo computado `prioridade(ocorrencias)` (0 a 120): urgência 0/25/50 +
    nível de risco 0/10/20 + 3 por confirmação (teto 30) + 2 por dia em aberto (teto 20).
    O PostgREST lê com `select=*,prioridade`, inclusive no join da OS
  - RPCs `prioridades_abertas`, `ocorrencias_proximas` (PostGIS, 80 m, mesmo tipo),
    `confirmar_ocorrencia` (rate limit 20/h), `reclassificar_ocorrencia` (só gestor),
    `avaliar_resolucao`, `evidencias_resolucao`
- `20261013120100_reabrir_os_na_avaliacao.sql`: existe o índice único
  `ordens_servico_ocorrencia_idx` (uma OS por ocorrência). Por isso "não resolveu" **não cria OS nova**:
  devolve a mesma OS para a fila (sem técnico, checklist e fotos zerados) e avisa os técnicos.
  Reaberta e concluída de novo, o cidadão avalia outra vez.
- Testado por SQL simulando cidadão, gestor e denunciante (transação desfeita no
  fim) e via REST com o login do gestor. Advisors: nada novo exposto para `anon`.

### App

- `OcorrenciaRisco` (novo enum) e campos novos em `Ocorrencia`; mapeamento único
  `OcorrenciaSupabaseDatasource.fromMap` (a OS reaproveita; antes era duplicado).
- `ClassificacaoCard`: origem (IA / corrigida pelo gestor / aguardando), urgência,
  nível de risco, confirmações e prioridade. Botão "Corrigir" para o gestor. Aparece no
  detalhe da ocorrência e da OS.
- Painel: "Prioridades de hoje" vem de `prioridadesAbertasProvider` (município inteiro).
- Fila do técnico, lista de OS e casos críticos do gestor ordenados pela pontuação.
- Nova ocorrência: ao sair da etapa "Local", busca relatos próximos do mesmo tipo e
  oferece confirmar em vez de duplicar. Offline ou com erro, segue normal.
- Detalhe da ocorrência: o cidadão vê as fotos do reparo e responde "resolveu?".
- `OcorrenciaCard` mostra confirmações e prioridade.

## Verificação

- `flutter analyze` sem problemas, `flutter test` passando, `flutter build web` ok.
- **Não conferido por print no aparelho.** Antes da gravação: gerar o APK e passar pelos 3 perfis.

## Pendências

- Conferir as telas novas no celular (painel do gestor, detalhe da OS, fluxo de confirmação).
- Herdadas: OneSignal (push não dispara sem ele), Gemini como fallback (descartado em 21/09;
  o PDF cita dois provedores), trocar a senha das contas de demo depois da gravação,
  refazer o roteiro sem o Kassio.
- Pitch: a resposta para "e se a IA errar?" agora é "o gestor corrige, e a correção muda a fila".
