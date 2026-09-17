---
data: 2026-09-17
status: planejada
---

# 001 — Ocorrências (fork de `denuncias` do SIGAU)

## Objetivo

Cidadão denuncia um problema de água/esgoto com foto + GPS; a ocorrência
recebe protocolo automático e status rastreável.

## Escopo (herdado do edital — não confundir domínio)

Tipos válidos: vazamento, esgoto a céu aberto, falta d'água, água
contaminada/suja, baixa pressão. **Fora do escopo**: limpeza urbana, resíduos
sólidos, drenagem pluvial (responsabilidade do poder público, não da
concessionária — edital é explícito nisso).

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Wizard de nova ocorrência: tipo, descrição, foto (EXIF removido), GPS ou endereço manual | 📋 backlog |
| CA02 | Protocolo automático `OCR-AAAAMM-NNNNN` gerado no INSERT (trigger, igual ao SIGAU) | 📋 backlog |
| CA03 | Ciclo de status: pendente → em_análise → resolvida → arquivada | 📋 backlog |
| CA04 | Cidadão acompanha suas próprias ocorrências (RLS: só vê as próprias, não-anônimas) | 📋 backlog |
| CA05 | Ocorrência classificada automaticamente por IA (tipo sugerido, urgência, risco à saúde) via `classify-ocorrencia` | 📋 backlog |
| CA06 | Mapa com marcadores por urgência, visível ao gestor/técnico do município | 📋 backlog |

## Dependências

- `decisions/002` (stack), `decisions/003` (multi-tenancy), `decisions/004`
  (Edge Function de IA)
- Reaproveita migrations 028/029 do SIGAU como ponto de partida (trocar enum
  de tipo, adaptar campos de espécie/quantidade de animal que não se aplicam)
