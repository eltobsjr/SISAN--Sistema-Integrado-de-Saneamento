---
data: 2026-09-17
status: aprovado
---

# 009 — Município piloto para o pitch: Picos (Águas do Piauí)

**Contexto:** precisávamos de um recorte concreto pra contar a história do
"Problema Identificado" no documento de submissão, em vez de falar do Piauí
inteiro de forma abstrata. O SIGAU já tem piloto real e beta testers em
Picos-PI.

**Decisão:** usar Picos como município de referência na narrativa do pitch e
nos dados de exemplo do protótipo (dashboard populado com dados fictícios
mas plausíveis de Picos), atendido pela Águas do Piauí.

**Motivo:** reforça uma narrativa de continuidade entre os dois projetos (o
SIGAU já rodando de verdade lá, o SISAN atacando outro problema real da
mesma cidade) — dá concretude ao pitch sem inventar dado de saúde/mercado
sem fonte (lição do glicemiastartup).

**Impacto:** `features/007` (seção "Problema Identificado" ancorada em
Picos), dados de exemplo/seed do dashboard no protótipo.

**Não fazer:** não hard-codar Picos no sistema — a multi-tenancy
(`decisions/003`) continua valendo pra qualquer município; Picos é só a
âncora narrativa e os dados de demonstração, não uma restrição técnica.
