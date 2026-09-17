---
data: 2026-09-17
status: planejada
---

# 004 — Dashboard da Concessionária (fork de `dashboard` do SIGAU)

## Objetivo

Gestor prioriza reparos por risco e exporta relatório — vitrine principal do
protótipo no pitch, se chegarmos à fase de finalistas.

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | KPIs do mês corrente (não snapshot — lição SGAU-021): ocorrências abertas, OS concluídas, tempo médio de resolução | 📋 backlog |
| CA02 | Mapa de calor de ocorrências por urgência | 📋 backlog |
| CA03 | Gráfico de tendência de 6 meses (`fl_chart`) | 📋 backlog |
| CA04 | Export PDF do relatório (`pw.` API do pacote `pdf`, cores sólidas — ver `referencia/erros-herdados-do-sigau.md`) | 📋 backlog |

## Dependências

- `001`, `002`, `003` alimentam os KPIs
