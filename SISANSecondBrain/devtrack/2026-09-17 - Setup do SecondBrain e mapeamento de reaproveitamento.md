# 2026-09-17 — Setup do SecondBrain e mapeamento de reaproveitamento

## Contexto

Usuário quer submeter uma proposta ao Hackathon "O Piauí que Queremos"
(Cidade Verde + Movimento Saneamento Salva + Águas do Piauí/Teresina/Timon +
Programe Studio), tema saneamento, submissão até 23/09/2026. Pediu para
construir toda a documentação de base antes de qualquer código, usando o
SIGAU (projeto do amigo dele, arquitetura madura) como base principal, e os
outros projetos pessoais + devtracks deles como fontes de reaproveitamento.

## O que foi feito

- Lido o PDF oficial do edital e a matéria da Cidade Verde — extraídos
  objetivos, escopo técnico (só água potável + esgotamento sanitário — nunca
  resíduos sólidos/drenagem/limpeza urbana), formato de submissão (PDF de 8
  seções), cronograma (submissão 15-23/09, finalistas 07/10, apresentação
  14/10, resultado 19/10) e critérios de avaliação.
- Analisado o SIGAU em profundidade: README, CLAUDE.md, árvore completa de
  `lib/`, migrations do Supabase, a feature `denuncias` (entity + migrations
  028/029 + edge function `calcular-urgencia`), e os 3 arquivos de governança
  (`roles/DECISIONS.md` — 24 decisões, `roles/ERRORS_LOG.md` — 44 erros
  resolvidos, `roles/AGENT_RULES.md`). Confirmado: app maduro, 64/64 testes,
  beta real em Picos-PI.
- Analisados os devtracks/SecondBrain de: Confia (fluxo de verificação com
  checklist+evidências), Polymata (catálogo de mecânicas de aprendizado +
  Edge Functions de IA do `polimata-concursos`), Momentum (design-system,
  RPG descartado por overkill), glicemiastartup (playbook de submissão a
  hackathon universitário — GENIUS/UFPI — e pipeline de pitch deck),
  sistema de presença (import CSV via edge function).
- A pedido do usuário no meio da sessão, aprofundado especificamente o
  padrão de Edge Functions do `polimata-concursos/supabase/functions/_shared/`
  (`provider.ts`, `errors.ts`, `quota.ts`) — multi-provider Groq→Gemini com
  fallback e retry, saída estruturada, cota diária — bem mais robusto que o
  scoring simples do SIGAU. Vira o padrão pra `classify-ocorrencia`.
- Criado o projeto em `/home/eltobsjr/dev/pessoal/sisan`, nome provisório
  **SISAN**. Rodado o setup de SecondBrain: `CLAUDE.md`, vault completo
  (`decisions/`, `features/`, `prioridade/`, `telas/`, `referencia/`,
  `devtrack/`), e memória em
  `~/.claude/projects/-home-eltobsjr-dev-pessoal-sisan/memory/`.
- 6 decisões de arquitetura registradas (nome provisório, stack herdada do
  SIGAU, multi-tenancy por município+concessionária, Edge Functions de IA no
  padrão polimata-concursos, checklist+evidências na Ordem de Serviço
  inspirado no Confia, sem coautoria do Claude em commits).
- 7 specs de feature registradas: Ocorrências, Ordens de Serviço, Alertas
  Sanitários, Dashboard, Campanhas Educativas, Classificação por IA, e o
  Documento de Submissão do Edital em si (o entregável realmente obrigatório
  até 23/09).

## Decisões tomadas

Ver `decisions/001` a `006`.

## Pendências

- [ ] **Nomes, curso/instituição e vínculo de todos os integrantes da
      equipe** — usuário confirmou que já sabe quem são, mas a resposta não
      chegou a ser registrada (interrompida por uma instrução sobre Edge
      Functions). Perguntar de novo na próxima sessão.
- [ ] Nome definitivo do projeto (SISAN é provisório)
- [ ] Escrever o documento de submissão completo (`features/007`)
- [ ] Nenhum código Flutter escrito ainda — greenfield total

## Próximos passos

1. Fechar a lista da equipe (bloqueia a inscrição)
2. Escrever o PDF de submissão (features/007) — antes do código, conforme
   `prioridade/atual.md`
3. Scaffold Flutter + Supabase e começar o fork de `ocorrencias`
