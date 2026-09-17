---
data: 2026-09-17
status: aprovado
---

# 003 — Multi-tenancy por município, com concessionária associada

**Contexto:** o SIGAU isola dados por `municipio_id` (RLS automática). No
nosso caso, cada município do Piauí é atendido por uma concessionária
específica (Águas do Piauí no interior, Águas de Teresina na capital, Águas
de Timon em Timon) — a mesma denúncia precisa chegar à empresa certa.

**Decisão:** manter `municipio_id uuid NOT NULL` + RLS como no SIGAU (mesmo
padrão, mesma garantia de isolamento), e adicionar uma tabela `municipios`
com coluna `concessionaria` (enum: `aguas_piaui` | `aguas_teresina` |
`aguas_timon`). Toda ocorrência/ordem de serviço herda a concessionária do
município via join, sem precisar de uma segunda dimensão de tenant.

**Motivo:** reaproveita 100% do padrão de RLS já testado no SIGAU
(`auth_municipio_id()`, `auth_perfil()`) sem reinventar a segmentação — só
adiciona um campo de roteamento/branding por cima.

**Impacto:** migration inicial de `municipios` inclui a coluna
`concessionaria`. Dashboard e notificações filtram por município (RLS) e
exibem/roteiam pela concessionária associada.

**Não fazer:** não criar banco separado por concessionária. Não usar
`concessionaria_id` como segunda chave de tenant nas policies de RLS — o
município já basta.
