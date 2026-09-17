---
data: 2026-09-17
status: aprovado
---

# 010 — Escopo do protótipo: os 3 perfis funcionando ponta a ponta até 23/09

**Contexto:** o edital não exige app funcionando (só o PDF), mas o usuário
optou pela opção mais ambiciosa das 3 apresentadas — construir cidadão,
técnico e gestor de ponta a ponta antes da submissão, não só documentar ou
fazer um recorte parcial.

**Decisão:** todas as 7 fases do `Roadmap.md` (0 a 6) são meta até 23/09/2026,
não só até a fase de finalistas (07/10).

**Risco assumido:** 6 dias é um prazo real para 3 perfis completos + 2 Edge
Functions de IA. Checkpoint de mitigação: se até o fim do dia 5 (21/09) um
perfil inteiro não estiver testável de ponta a ponta, cortar pro mockup
documentado daquele perfil específico em vez de arriscar nada funcionando
pra nenhum. A ordem das fases no Roadmap já protege o essencial primeiro —
IA (Fase 5) é a única parte cujo adiamento não compromete o fluxo principal
(ver `decisions/004`, "Não fazer": falha de IA nunca quebra o resto).

**Motivo:** decisão do usuário, com plano de fallback já embutido no
Roadmap.

**Impacto:** `prioridade/atual.md` (calendário sem folga), `Roadmap.md` (já
estruturado nessa ordem de prioridade — nenhuma mudança de fase necessária).

**Não fazer:** não sacrificar a Fase 0-2 (fundação + ocorrências + ordens de
serviço) por causa da Fase 5 (IA) — se o tempo apertar, IA é o primeiro corte,
não o dashboard nem o fluxo cidadão/técnico.
