---
data: 2026-09-17
status: aprovado
---

# 012 — Credenciais do projeto Supabase e tratamento da service_role key

**Contexto:** usuário criou o projeto Supabase (`gzoosgugbgbtcrjhfoot`) e
compartilhou URL, anon key e **service_role key** diretamente na conversa.

**Decisão:**
- URL e anon key guardadas em `.env` na raiz do projeto (git-ignorado),
  com `.env.example` versionado como template sem valores reais. Quando o
  Flutter for criado (Fase 0 do Roadmap), o app lê via `flutter_dotenv`,
  mesmo padrão do SIGAU — nunca hardcoded em `main.dart`.
- **A service_role key não foi persistida em nenhum arquivo do projeto.**
  Ela não é necessária para o app Flutter (nunca deve tocar código cliente)
  nem para as Edge Functions (o próprio Supabase injeta
  `SUPABASE_SERVICE_ROLE_KEY` automaticamente no runtime delas). Só seria
  necessária para um script administrativo local eventual (ex.: seed de
  dados de demonstração) — se isso surgir, cada dev guarda sua própria cópia
  local, nunca compartilhada por chat/commit.
- **Acesso da equipe ao projeto Supabase**: convidar Kassio e Evillyn
  diretamente pelo Dashboard (Project Settings → Team), em vez de repassar
  a service_role key. Nenhum dos dois precisa dela para desenvolver.

**Motivo:** o repositório é público (`decisions/011`) — qualquer secret
commitado fica exposto publicamente e indexável para sempre (histórico de
git). A service_role key bypassa toda a RLS; vazá-la equivale a dar acesso
irrestrito ao banco de produção.

**Impacto:** `.env`, `.env.example`, `.gitignore`.

**Não fazer:** não colocar a service_role key em nenhum arquivo do
repositório, commit, issue ou PR. Não reenviar a service_role key por chat
de novo — se precisar compartilhar uma credencial de verdade no futuro, usar
o convite de equipe do próprio Supabase ou um gerenciador de senhas.
