---
data: 2026-09-17
status: planejada
---

# 003 — Alertas Sanitários (fork de `zoonoses` do SIGAU)

## Objetivo

Atacar o eixo **Saúde** do edital de forma explícita: quando uma zona tem
esgoto a céu aberto recorrente ou falta d'água prolongada, virar um alerta
visível pro gestor, correlacionando com risco de doença (diarreia, dengue).

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Alerta restrito a staff (gestor/técnico), nunca visível ao cidadão comum (RLS igual ao SIGAU: `auth_perfil() IN ('gestor','operador')`) | 📋 backlog |
| CA02 | Alerta criado manualmente pelo gestor OU automaticamente quando N ocorrências do mesmo tipo se acumulam num raio geográfico em X dias | 📋 backlog |
| CA03 | Mapa do alerta com raio de abrangência | 📋 backlog |
| CA04 | Push segmentado por município via `external_id` (nunca tag) | 📋 backlog |

## Nota de escopo

Correlação com dado real de saúde pública (DATASUS, plano municipal de
saúde) é aspiracional para o MVP dos 6 dias — se não der tempo de integrar
dado real, documentar como "transformação pretendida" no PDF de submissão em
vez de simular número (mesma lição do glicemiastartup: nunca inventar
estatística sem fonte).

## Dependências

- `001 - Ocorrências` (a origem dos dados que alimentam o alerta)
