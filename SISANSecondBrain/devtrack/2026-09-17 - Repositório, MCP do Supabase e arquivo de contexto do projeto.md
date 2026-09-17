# 2026-09-17 — Repositório, MCP do Supabase e arquivo de contexto do projeto

> Terceira entrada de devtrack do mesmo dia — sessão longa, dividida por
> assunto. Ver também "Setup do SecondBrain..." e "Nome definitivo SISAN...".

## O que foi feito

### Identidade visual, município piloto, escopo e equipe (perguntas com alternativas)
Levantado o que faltava discutir e devolvido em 4 perguntas com alternativas.
Respostas: identidade **Água Viva** (azul/ciano + gota, `decisions/008`),
município piloto **Picos-PI** (`decisions/009`, reforça continuidade com o
piloto real do SIGAU), escopo do protótipo **os 3 perfis ponta a ponta até
23/09** — opção mais ambiciosa das 3 (`decisions/010`, com checkpoint de
risco no dia 5), e equipe **Elto, Kassio, Evillyn** (mesmo trio do
GlicemIA/GENIUS Hackathon). `prioridade/atual.md` reescrito pra refletir o
calendário mais apertado dessa escolha.

### Repositório no GitHub — trabalho em grupo
Usuário forneceu o repositório `eltobsjr/SISAN--Sistema-Integrado-de-Saneamento`
(já existia no GitHub, público, vazio) e pediu pra versionar também o
`SISANSecondBrain/` — decisão registrada em `decisions/011`, quebrando a
convenção dos outros projetos do usuário (lá o vault é sempre pessoal e
git-ignorado; aqui é compartilhado entre 3 pessoas). `.gitignore` reescrito
pra excluir só segredos (`.env`, `.mcp.json`) e artefatos de build Flutter.
Repositório inicializado, 34 arquivos commitados (sem coautoria do Claude,
`decisions/006`) e enviados pra `main`.

### Credenciais do Supabase — cuidado com a service_role key
Usuário colou na conversa a URL, a anon key **e a service_role key** do
projeto Supabase (`gzoosgugbgbtcrjhfoot`) já criado. Registrado em
`decisions/012`: URL+anon key foram pra `.env` (git-ignorado, com
`.env.example` versionado como template) — a **service_role key não foi
persistida em arquivo nenhum**, porque (a) o repo é público, (b) ela não é
necessária nem no Flutter nem nas Edge Functions (Supabase injeta sozinho
no runtime), e (c) dá acesso irrestrito ao banco se vazar. Recomendado ao
usuário convidar Kassio e Evillyn direto pelo Supabase Team em vez de
repassar chave por chat.

### MCP do Supabase escopado pro projeto
Seguindo o mesmo padrão já usado no `polimata-concursos/.mcp.json`
(`supabase-<nome>`, `--project-ref` fixo, token via `SUPABASE_ACCESS_TOKEN`),
criado `.mcp.json` (git-ignorado) com o server `supabase-sisan` apontando
pro `project-ref=gzoosgugbgbtcrjhfoot` e um placeholder no lugar do token —
**falta o usuário gerar um Personal Access Token novo** em
supabase.com/dashboard/account/tokens (recomendado: um específico pro
SISAN, não reaproveitar o do polimata-concursos, dado que este repo é
público e compartilhado). Criado também `.mcp.json.example` (versionado)
como template pro Kassio/Evillyn configurarem o deles. `CLAUDE.md` ganhou a
seção "2b. Acesso direto ao banco via MCP" documentando a capacidade,
citando a lição SGAU-022 do SIGAU (sempre confirmar o project-ref certo
antes de aplicar migration) e deixando claro que ações destrutivas exigem
confirmação mesmo com a autorização de rotina.

### Arquivo de contexto de criação do projeto
Criado `Contexto de Criação do Projeto.md` na raiz do vault — briefing
único cobrindo por que o projeto existe, a ideia central (com foco no
mapa), como nasceu (reaproveitamento de SIGAU/Confia/polimata-concursos/
glicemiastartup), tabela-resumo das 12 decisões, estado atual e por onde
continuar. `CLAUDE.md` ganhou uma seção "0. Primeira vez neste projeto?"
apontando pra ele antes do protocolo normal de sessão.

## Pendências

- [ ] **Personal Access Token do Supabase** — sem ele o MCP `supabase-sisan`
      não conecta; usuário precisa gerar em supabase.com/dashboard/account/tokens
      e colar em `.mcp.json`
- [ ] Convidar Kassio e Evillyn no Supabase (Team) e no GitHub (colaboradores —
      falta os usernames do GitHub de cada um)
- [ ] Curso/instituição da equipe e líder designado
- [ ] Documento de submissão (`features/007`) ainda não escrito
- [ ] Nenhum código Flutter escrito — Fase 0 do Roadmap é o próximo passo técnico

## Próximos passos

1. Usuário gera o Personal Access Token e cola em `.mcp.json`
2. Escrever `features/007` (documento de submissão) — não depende do token
3. Fase 0 do Roadmap: scaffold Flutter + Supabase
