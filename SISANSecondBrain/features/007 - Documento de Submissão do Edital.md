---
data: 2026-09-17
status: planejada
---

# 007 — Documento de Submissão do Edital

## Objetivo

O entregável realmente obrigatório até 23/09 — não é código, é o PDF de 8
seções exigido pelo formulário de inscrição.

## Estrutura obrigatória (do edital)

1. Título do Projeto
2. Resumo Executivo (máx. 300 palavras)
3. Problema Identificado
4. Solução Proposta
5. Público Beneficiado
6. Plano mínimo de Implementação (como colocar em prática)
7. Transformação Pretendida (impacto nos pilares Saúde/Social/Educação/Sustentabilidade)
8. Referências

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Rascunho completo escrito, com cada seção respondendo diretamente o que o edital pede (não é texto de venda genérico) | 📋 backlog |
| CA02 | Nenhum número ou estatística sem fonte citada (lição do glicemiastartup — nunca inventar dado de saúde/mercado) | 📋 backlog |
| CA03 | Nome/curso/instituição de todos os integrantes preenchidos (bloqueia sem isso) | 📋 backlog |
| CA04 | Revisão final: enquadramento com o desafio central do edital ("O Piauí que queremos no saneamento") explícito na seção de transformação pretendida | 📋 backlog |

## Dependências

- `features/001` a `006` alimentam a seção "Solução Proposta" e "Plano
  mínimo de Implementação" — escrever a proposta primeiro ajuda a definir o
  escopo técnico real, não o contrário
