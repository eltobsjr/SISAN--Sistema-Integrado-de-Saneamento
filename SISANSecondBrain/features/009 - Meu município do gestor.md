---
data: 2026-09-19
status: implementada
---

# 009 — Meu município do gestor

## Objetivo

Dar ao gestor um lugar pra ver os dados do município e a equipe cadastrada, e
pra administrar o **código de ativação de equipe** (o que técnicos e gestores
digitam no cadastro pra ganhar o perfil; sem o código certo, o
`handle_new_user` cria a pessoa como cidadão).

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Só gestor acessa (`meu_municipio_staff` e `regenerar_codigo_ativacao_staff` retornam 42501 pros demais; testado com técnico) | ✅ |
| CA02 | Mostra nome, UF, concessionária e a contagem de gestores/técnicos/cidadãos ativos | ✅ |
| CA03 | Mostra o código atual, com "copiar" | ✅ |
| CA04 | "Gerar novo" pede confirmação e invalida o código anterior; limite de 5 trocas por hora | ✅ |
| CA05 | `codigos_ativacao_staff` continua sem policy (nenhum acesso direto pelo cliente) | ✅ |

## Onde está

- SQL: `supabase/migrations/20260919150000_meu_municipio_gestor.sql`
- Flutter: `lib/features/municipio/` (entidade, provider, `MeuMunicipioPage`),
  rota `/meu-municipio`, atalho na home do gestor.

## Pendente

- Testar a tela num aparelho real (só o backend foi validado por chamadas).
