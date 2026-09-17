---
data: 2026-09-17
status: planejada
---

# 002 — Ordens de Serviço (fork de `resgates` do SIGAU + checklist do Confia)

## Objetivo

Técnico da concessionária atende uma ocorrência de ponta a ponta, com prova
de que o reparo foi feito de verdade.

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Técnico vê fila de ordens de serviço pendentes do seu município, aceita uma | 📋 backlog |
| CA02 | Registra chegada ao local (GPS) | 📋 backlog |
| CA03 | Checklist obrigatório específico por tipo de ocorrência antes de permitir concluir (ver `decisions/005`) | 📋 backlog |
| CA04 | No mínimo 1 foto do "depois" com geotag/horário, EXIF removido antes do upload | 📋 backlog |
| CA05 | Atualização otimista + fila offline (mesmo padrão de `resgates_provider.dart` do SIGAU) | 📋 backlog |
| CA06 | Conclusão dispara notificação realtime pro cidadão que abriu a ocorrência | 📋 backlog |

## Dependências

- `001 - Ocorrências` (uma OS nasce de uma ocorrência)
- `decisions/005` (checklist + evidências)
- Offline-first herdado do SIGAU (SGAU-011) — crítico, técnico em campo pode
  estar sem sinal
