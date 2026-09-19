---
data: 2026-09-17
status: implementada (Groq; Gemini como fallback futuro)
---

# 006 — Resumo Executivo por IA no Dashboard (`insight-dashboard`)

## Objetivo

O dashboard do gestor (`features/004`) mostra KPIs e gráficos crus. Essa
feature acrescenta uma Edge Function que lê os dados agregados do mês e
gera, em linguagem natural, 2-3 frases de insight acionável — ex.: "esgoto a
céu aberto reincidente em 3 bairros perto de escola, priorize aqui" — em vez
do gestor precisar interpretar o gráfico sozinho.

**Por que essa e não a classificação automática de ocorrência (ideia
anterior, descartada):** fica fora do caminho crítico do app — só o
dashboard do gestor depende disso, então uma falha da IA nunca compromete o
fluxo de denúncia→atendimento, que é o que precisa funcionar de verdade na
demo. E ataca direto os eixos Saúde/Sustentabilidade da avaliação do edital
com pouco código.

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Edge Function recebe os agregados do mês (contagem por tipo/bairro/urgência, já calculados no Postgres) e devolve texto estruturado (título + 2-3 frases) via JSON schema | 📋 backlog |
| CA02 | Tenta Groq primeiro, cai pra Gemini se falhar (`generateStructured(params, ["groq","gemini"])`, padrão do polimata-concursos) | 📋 backlog |
| CA03 | Resultado cacheado por período (não gera de novo a cada abertura do dashboard no mesmo mês — só quando os dados agregados mudarem) | 📋 backlog |
| CA04 | Erros de provedor normalizados em `HttpError` client-safe (`_shared/errors.ts`) — se a IA falhar, dashboard continua funcionando só com os gráficos, sem quebrar | 📋 backlog |
| CA05 | Nenhum dado pessoal do cidadão (nome, telefone) entra no prompt — só agregados anônimos por bairro/tipo | 📋 backlog |

## Ideia secundária (registrada, não priorizada)

**Detecção de duplicidade de ocorrências** — evitar que o mesmo vazamento
vire N tickets separados no dashboard. Mais operacional, menos vistoso num
pitch, fica como próxima candidata se sobrar tempo depois do MVP.

## Dependências

- Copiar `_shared/{provider,errors,cors,supabase-admin}.ts` do
  `polimata-concursos` como ponto de partida, adaptando nomes de domínio
  (`decisions/004`)
- `004 - Dashboard da Concessionária` (fonte dos dados agregados)
