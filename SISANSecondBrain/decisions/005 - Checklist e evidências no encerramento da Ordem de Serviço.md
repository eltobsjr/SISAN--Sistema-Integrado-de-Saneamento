---
data: 2026-09-17
status: aprovado
---

# 005 — Checklist obrigatório + evidências para encerrar Ordem de Serviço

**Contexto:** o SIGAU resolve "resgate" com um fluxo simples de 3 estados
(aceitar → chegar → concluir, com até 3 fotos opcionais). O Confia, para o
fluxo de verificação presencial (verificador confere o produto antes do
escrow liberar), exige um checklist por categoria completo antes de aprovar,
e reprovar exige motivo + no mínimo 2 evidências (foto/vídeo com geotag e
horário) — muito mais rigor probatório, adequado para um contexto onde a
concessionária precisa provar que o reparo foi feito de verdade.

**Decisão:** o encerramento de uma Ordem de Serviço (equivalente ao "resgate"
do SIGAU) exige: (1) checklist específico por tipo de ocorrência (ex.: para
vazamento — "vazamento estancado", "via/calçada recomposta"; para esgoto a
céu aberto — "fluxo interrompido", "área higienizada") totalmente marcado
antes de permitir concluir; (2) no mínimo 1 foto do depois, com geotag e
horário (reaproveitando o `ExifRemover` do SIGAU para tirar metadado sensível
antes do upload, mantendo só o necessário). Sem chat nem escrow — não há
pagamento entre cidadão e técnico, então essa parte do Confia não se aplica.

**Motivo:** eleva a credibilidade do dado que vai pro dashboard do gestor —
"resolvido" só é aceito com prova, não com um toque de botão — e é uma
diferenciação fácil de explicar no pitch (rastreabilidade real do reparo).

**Impacto:** `features/002 - Ordens de Serviço.md`. Tabela `ordens_servico`
ganha `checklist jsonb` e `fotos_depois text[]`.

**Não fazer:** não copiar o fluxo de chat/escrow do Confia — não há dinheiro
envolvido nessa ponta. Não permitir concluir sem checklist completo.
