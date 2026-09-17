---
data: 2026-09-17
status: planejada
---

# 006 — Classificação por IA (`classify-ocorrencia`)

## Objetivo

Edge Function nova (sem equivalente direto no SIGAU) — classifica
automaticamente cada ocorrência recém-criada, no padrão do
`polimata-concursos` (ver `decisions/004`).

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Recebe descrição + foto, devolve `{ tipo, urgencia, riscoSaude }` via JSON schema estruturado | 📋 backlog |
| CA02 | Tenta Groq primeiro, cai pra Gemini se falhar (`generateStructured(params, ["groq","gemini"])`) | 📋 backlog |
| CA03 | Nunca reclassifica ocorrência com `classificado_em` preenchido | 📋 backlog |
| CA04 | Cota diária por usuário (reaproveitar `_shared/quota.ts`) — protege contra abuso da função pública | 📋 backlog |
| CA05 | Erros de provedor normalizados em `HttpError` client-safe (`_shared/errors.ts`) | 📋 backlog |

## Dependências

- Copiar `_shared/{provider,errors,cors,supabase-admin,quota}.ts` do
  `polimata-concursos` como ponto de partida, adaptando nomes de domínio
- `001 - Ocorrências` (dispara a classificação no INSERT)

## Ver também

`008 - Resumo Executivo por IA no Dashboard.md` — segundo uso de IA no
sistema, sobre os dados agregados do dashboard em vez de por ocorrência.
