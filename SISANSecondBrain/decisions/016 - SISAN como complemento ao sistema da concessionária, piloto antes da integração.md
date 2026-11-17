---
tipo: decisao
data: 2026-10-14
status: aceita
---

# 016 — SISAN como complemento ao sistema da concessionária; piloto antes da integração

## Contexto

Em 13/10/2026, à noite, a mentora do grupo, Flávia Miranda, revisou os slides
do pitch (ela fala pela operação da concessionária em Teresina). Pontos
principais, com as palavras dela resumidas:

- A concessionária tem **sistema próprio de geração e execução de ordens de
  serviço**, com parâmetros de monitoramento e controle. O app só funciona como
  proposto se estiver **integrado a esse sistema (field)**: o status do relato
  deve ser atualizado pela baixa da OS no sistema de campo, e as **flags de
  prioridade** devem chegar ao sistema da concessionária para a programação
  priorizar pela classificação proposta.
- "Não faz sentido gerir dois sistemas de serviço."
- O Elto perguntou se a integração podia ficar como ajuste futuro. Ela sugeriu
  **rodar um piloto** para validar a solução e, **validada, seguir com a
  integração**, e pediu que o **cronograma de implantação** traga essa previsão.

## Decisão

1. O SISAN é apresentado como **ferramenta complementar e novo canal de
   comunicação do usuário**, não como segundo sistema de ordens de serviço.
2. A integração entra como **etapa 4 do cronograma**, depois do piloto de 90 dias,
   com prazo a acordar com a concessionária (sem inventar duração).
3. No documento de submissão (seções 4.5, 6.2 e 6.5) e no deck (slides
   `implantacao` e `integracao`) fica explícito que a integração é **previsão**:
   **não existe API de integração pronta**.
4. Novo risco na tabela: "dois sistemas de ordem de serviço em paralelo".

## Alternativas consideradas

- **Tratar a integração como "ajuste futuro" fora do cronograma:** descartada, a
  mentora pediu a previsão explícita nas etapas de implantação.
- **Integrar já, antes do piloto:** descartada; sem validação, o custo de ligar
  ao sistema existente é investido às cegas, e não há acesso à API da concessionária.

## Consequências

- O pitch ganha dois slides visíveis (implantação e integração) e o roteiro
  passa a 11 slides.
- Para a integração real será preciso definir com a concessionária o contrato
  de dados (status por baixa de OS, pontuação e flags de prioridade).
- O fluxo de OS dentro do app continua útil no piloto como canal e para validar
  a priorização, mas o sistema de campo passa a ser a referência da operação.
