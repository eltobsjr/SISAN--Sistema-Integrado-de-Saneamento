---
data: 2026-09-17
---

# Contexto de Criação do Projeto — SISAN

Leia este arquivo primeiro se é sua primeira vez aqui (Elto, Kassio,
Evillyn, ou o Claude Code numa sessão nova). Ele existe pra ninguém precisar
reconstruir esse contexto do zero.

## Por que esse projeto existe

O Hackathon **"O Piauí que Queremos"** — organizado pelo Cidade Verde, o
Movimento Saneamento Salva e as concessionárias Águas do Piauí / Águas de
Teresina / Águas de Timon, com apoio do Programe Studio — pede soluções
(tecnológicas ou não) para os desafios de **abastecimento de água potável e
esgotamento sanitário** no Piauí, avaliadas em 4 eixos: Saúde, Social,
Educação e Sustentabilidade. Fora do escopo do edital: limpeza urbana,
resíduos sólidos, drenagem pluvial (são responsabilidade do poder público,
não das concessionárias).

**Prazo real: submissão do PDF de 8 seções até 23/09/2026.** Se selecionados
entre as 5 equipes finalistas (divulgação 07/10), ganhamos mentoria e acesso
ao Programe Studio até a apresentação gravada (14/10) e resultado (19/10,
Dia do Piauí).

## A ideia

Cidadão denuncia um problema (vazamento, esgoto a céu aberto, falta d'água,
água contaminada) com foto + GPS pelo celular. A ocorrência aparece **na
hora** num mapa vivo do município, colorida por urgência. O técnico da
concessionária vê a fila geograficamente e atende com checklist +
evidências antes de poder concluir. O gestor enxerga o mapa de calor do mês
inteiro — padrões, não só chamados isolados — com uma Edge Function de IA
lendo esses agregados e devolvendo insight em português simples ("esgoto a
céu aberto reincidente em 3 bairros perto de escola, priorize aqui").

## Como nasceu: não é um projeto do zero

A decisão mais importante do projeto foi **não escrever a arquitetura do
zero**. O SISAN reaproveita, de propósito:

- **SIGAU** (projeto do Kassio, base arquitetural principal) — SaaS
  multi-tenant maduro (43 migrations, 64/64 testes, beta real em Picos-PI)
  que resolve um problema com a mesma forma (cidadão denuncia com foto+GPS →
  operador atende em campo → gestor prioriza no dashboard) pra animais
  urbanos. `denuncias`→`ocorrencias`, `resgates`→`ordens_de_servico`,
  `zoonoses`→`alertas_sanitarios`, dashboard/campanhas/notificações/mapa
  mantidos, `animais`/`adocao` descartados.
- **Confia** — o fluxo de verificação com checklist obrigatório + evidências
  antes de aprovar/reprovar, adaptado pro encerramento de Ordem de Serviço.
- **polimata-concursos** — o padrão de Edge Functions de IA (multi-provider
  Groq→Gemini com fallback, schema estruturado, cota diária), muito mais
  robusto que o scoring simples do SIGAU.
- **glicemiastartup** — o playbook de submissão a hackathon universitário
  (montagem de equipe, pitch deck enxuto, nunca inventar número sem fonte).

Ver o mapa completo em `referencia/reaproveitamento-por-projeto.md` e o
catálogo de 44 bugs já resolvidos nessa mesma stack (não repetir) em
`referencia/erros-herdados-do-sigau.md`.

## Decisões fundamentais já tomadas

Todas em `decisions/`, resumo rápido:

| # | Decisão |
|---|---|
| 002 | Stack: Flutter+Dart (mobile+web) + Supabase completo + Riverpod, herdada do SIGAU |
| 003 | Multi-tenancy por município, com concessionária associada |
| 004 | Duas Edge Functions de IA: `classify-ocorrencia` e `insight-dashboard`, padrão polimata-concursos |
| 005 | Checklist + evidências obrigatórios pra concluir Ordem de Serviço |
| 006 | Sem Claude como coautor em commits |
| 007 | Nome definitivo: **SISAN** (Sistema Integrado de Saneamento) |
| 008 | Identidade visual "Água Viva" — azul/ciano (`#0288D1`) + gota |
| 009 | Município piloto do pitch/dados de exemplo: **Picos-PI** |
| 010 | Escopo do protótipo: os 3 perfis (cidadão/técnico/gestor) funcionando ponta a ponta até 23/09 — não só documentado |
| 011 | Repositório público e compartilhado, SecondBrain versionado (não gitignorado, ao contrário dos outros projetos do usuário) |
| 012 | Tratamento de credenciais Supabase — nunca a service_role key em arquivo nenhum |

## Estado atual (17/09/2026)

- **Código: zero.** Nenhum `pubspec.yaml`, nenhuma migration aplicada.
  Projeto Supabase já criado (`gzoosgugbgbtcrjhfoot`).
- **Documentação: completa.** 8 specs de feature (`features/001-008`), 12
  decisões, roadmap técnico de 7 fases (`Roadmap.md`) com todas as
  migrations/Edge Functions/dependências já planejadas.
- **Repositório**: `github.com/eltobsjr/SISAN--Sistema-Integrado-de-Saneamento`
  (público), documentação já commitada e enviada.
- **Equipe**: Elto, Kassio e Evillyn (3/5) — falta curso/instituição de cada
  um e definir o líder designado pra inscrição.
- **MCP do Supabase**: configurado em `.mcp.json` (git-ignorado), falta só
  preencher o Personal Access Token real (cada dev cria o seu, ver
  `.mcp.json.example` e `decisions/012`).
- **Documento de submissão do edital** (`features/007`): ainda não escrito
  — é o próximo passo mais urgente, roda em paralelo ao código.

## Por onde continuar agora

1. Se é a primeira sessão de código: seguir a **Fase 0** do `Roadmap.md`
   (scaffold Flutter + Supabase + migrations base).
2. Se o documento de submissão ainda não existe: escrever `features/007`
   primeiro — é o entregável obrigatório, não depende do código pronto.
3. Qualquer dúvida de "isso já existe em outro projeto?" — checar
   `referencia/reaproveitamento-por-projeto.md` antes de implementar do
   zero.
4. Qualquer bug estranho em RLS/mapas/push/PDF/offline — checar
   `referencia/erros-herdados-do-sigau.md` antes de debugar do zero.

## Como usar este vault

- `Roadmap.md` — o plano técnico completo (fases, migrations, dependências)
- `prioridade/atual.md` — o calendário dia a dia até 23/09
- `decisions/` — uma decisão por arquivo, nunca reverter sem registrar uma nova
- `features/` — spec de cada funcionalidade com critérios de aceitação
- `telas/` — mapa de telas por perfil
- `devtrack/` — log de cada sessão de trabalho (gerar um ao final de cada sessão)
- `referencia/` — o que reaproveitar de cada projeto e o que não repetir
