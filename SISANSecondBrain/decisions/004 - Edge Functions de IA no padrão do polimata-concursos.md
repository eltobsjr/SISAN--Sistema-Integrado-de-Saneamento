---
data: 2026-09-17
status: aprovado
---

# 004 — Edge Functions de IA no padrão do polimata-concursos (não do SIGAU)

**Contexto:** o SIGAU tem uma única "Edge Function de IA" (`calcular-urgencia`)
— pontuação fixa por tabela (`comportamentoScore`/`porteModificador`), sem
chamar nenhum provedor de IA de verdade. O `polimata-concursos` tem um padrão
bem mais robusto em `supabase/functions/_shared/`: abstração multi-provider
(`provider.ts`, com Groq como padrão e Gemini como fallback automático via
`generateStructured(params, ["groq","gemini"])`), retry com backoff
exponencial em erros transitórios, saída sempre em JSON schema estruturado,
cota diária por usuário (`quota.ts`, `consumeAiQuota`/`refundAiQuota`) e
erros normalizados em `HttpError` client-safe (`errors.ts`).

**Decisão:** usar esse mesmo padrão em duas Edge Functions do SISAN:

1. `classify-ocorrencia` (equivalente à `classify-question` do
   polimata-concursos) — recebe descrição + foto da denúncia, devolve
   `{ tipo, urgencia, riscoSaude }` via schema JSON fechado, tentando Groq
   primeiro e caindo para Gemini se falhar. Resultado cacheado na própria
   linha da ocorrência (`classificado_em`) — nunca reclassifica o que já foi
   classificado, mesmo padrão do `classified_at` do polimata-concursos. Ver
   `features/006`.
2. `insight-dashboard` — lê os agregados mensais do dashboard do gestor e
   gera um resumo executivo em linguagem natural (2-3 frases acionáveis).
   Fora do caminho crítico do app: uma falha aqui nunca compromete o fluxo
   de denúncia→atendimento. Ver `features/008`.

Copiar (adaptando nomes) os arquivos `_shared/provider.ts`,
`_shared/errors.ts`, `_shared/cors.ts`, `_shared/supabase-admin.ts`,
`_shared/quota.ts` do polimata-concursos como ponto de partida para as duas.

**Motivo:** classificação por IA de verdade (não uma tabela de pontos fixos)
é um diferencial real pro critério "Criatividade" e "Viabilidade Técnica" da
avaliação do edital, e o padrão já existe pronto e testado em produção — não
precisa ser desenhado do zero.

**Impacto:** `supabase/functions/classify-ocorrencia/`,
`supabase/functions/insight-dashboard/`, `supabase/functions/_shared/`
(copiado do polimata-concursos). Tabela `ocorrencias` ganha `classificado_em`,
`tipo` (pode vir preenchido pelo cidadão ou sugerido pela IA), `urgencia`,
`risco_saude`.

**Não fazer:** não usar Anthropic como provedor principal aqui (custo mais
alto, sem necessidade — Groq/Gemini bastam). Não pular a cota diária por
usuário em `classify-ocorrencia` — protege contra abuso da função pública de
denúncia. Não reclassificar uma ocorrência já `classificado_em`. Não deixar
uma falha de `insight-dashboard` quebrar o dashboard — degradar
graciosamente para só os gráficos.
