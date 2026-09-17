# CLAUDE.md — SISAN

Proposta para o Hackathon "O Piauí que Queremos" (Cidade Verde + Movimento
Saneamento Salva + Águas do Piauí / Águas de Teresina / Águas de Timon +
Programe Studio). Tema: abastecimento de água potável e esgotamento
sanitário. App de denúncia cidadã + gestão de ordens de serviço + dashboard
de priorização por risco sanitário, construído reaproveitando arquitetura e
padrões já validados em outros projetos do usuário.

## 1. Sempre ler a memória antes de começar

Ao iniciar qualquer conversa neste projeto:

1. Leia o índice de memória: `~/.claude/projects/-home-eltobsjr-dev-pessoal-sisan/memory/MEMORY.md`
   É um índice — siga os links para os arquivos relevantes à tarefa atual.

2. Leia o devtrack mais recente:
   `ls /home/eltobsjr/dev/pessoal/sisan/SISANSecondBrain/devtrack/ | sort | tail -1`
   e leia o arquivo retornado. Isso garante continuidade: o que foi feito,
   decisões tomadas e pendências abertas na última sessão.

3. Antes de implementar qualquer feature, leia
   `SISANSecondBrain/referencia/reaproveitamento-por-projeto.md` — mapa do
   que já existe pronto em outros projetos do usuário (SIGAU, Confia,
   Polymata) e pode ser adaptado em vez de escrito do zero.

4. Antes de mexer em RLS, Edge Functions, offline-sync, mapas, push ou PDF,
   leia `SISANSecondBrain/referencia/erros-herdados-do-sigau.md` — 44 bugs
   já resolvidos no SIGAU (mesma stack) que não devem ser repetidos aqui.

## 2. Stack e tecnologias

- **Mobile + Web**: Flutter / Dart (mesmo binário-fonte para os três perfis:
  cidadão, técnico, gestor) — sem React, sem Next.js
- **Backend**: Supabase completo — Auth, Postgres + PostGIS, Storage,
  Realtime, Edge Functions (Deno/TypeScript) — sem Node.js standalone, sem
  Firebase
- **Estado**: Riverpod 2.x (`AsyncNotifier`) — sem Provider/Bloc/GetX
- **Mapas**: `flutter_map` + OpenStreetMap (nunca Google Maps — sem billing)
- **Push**: OneSignal via `external_id` (nunca filtro por tags)
- **Offline**: drift (SQLite local) + fila de sincronização — crítico para
  técnicos de campo e denúncias em área com sinal ruim
- **IA nas Edge Functions**: Groq (principal) → Gemini (fallback), saída
  estruturada por JSON schema — padrão herdado do `polimata-concursos`, não
  do SIGAU. Duas funções: `classify-ocorrencia` (tipo/urgência/risco à saúde
  por denúncia) e `insight-dashboard` (resumo executivo dos agregados
  mensais pro gestor)

Ver decisão completa em `SISANSecondBrain/decisions/002 - Stack herdada do SIGAU.md`.

## 3. Estrutura do projeto

Projeto ainda greenfield — nenhum código Flutter escrito. Estrutura de pastas
planejada segue Clean Architecture por feature, igual ao SIGAU:
`lib/features/<feature>/{data,domain,presentation}/`.

## 4. Documentação

Toda documentação fica no vault: `SISANSecondBrain/`
Logs de sessão: `SISANSecondBrain/devtrack/`
Formato dos logs: `YYYY-MM-DD - Título.md`
Decisões: `SISANSecondBrain/decisions/`
Specs de feature: `SISANSecondBrain/features/`
Roadmap técnico completo (fases, migrations, edge functions, dependências): `SISANSecondBrain/Roadmap.md`
Prioridades e prazos (calendário dia a dia): `SISANSecondBrain/prioridade/atual.md`
Mapa de telas: `SISANSecondBrain/telas/`
Referências cruzadas de outros projetos: `SISANSecondBrain/referencia/`

## 5. Regras de desenvolvimento

- Nunca commitar com Claude como coautor (sem `Co-Authored-By: Claude` — consistente com Confia, Momentum e Polymata).
- Nunca commitar sem permissão explícita do usuário.
- RLS obrigatória em toda tabela nova, imediatamente após criá-la.
- Nunca expor `SUPABASE_SERVICE_KEY` no cliente Flutter — só em Edge Functions.
- Prazo real do edital: submissão até **23/09/2026**. Toda decisão de escopo
  deve considerar esse prazo antes de qualquer ambição de produto.

## 6. Fluxo de trabalho

1. Ler memória e devtrack mais recente
2. Checar `referencia/reaproveitamento-por-projeto.md` antes de implementar algo do zero
3. Implementar em fatia vertical (uma feature ponta a ponta antes da próxima)
4. Atualizar devtrack ao final da sessão
