---
data: 2026-09-21
---

# 21/09 — Hardening, homes com navbar e design system

## Feito

- **Pendências**: Kassio concluiu a chave nova do Groq e o teste dos 3
  perfis no aparelho. Descartados: Gemini fallback, fotos no seed,
  isolamento de worktree, 4º integrante (ver `prioridade/atual.md`).
- **Git**: branches antigas apagadas (local e remoto). Commits agora vão
  direto na `main`.
- **Contas de demo**: e-mails simplificados (`gestor1@sisan.com`,
  `tecnico1@sisan.com`, `cidadao1@sisan.com`…) e senha redefinida (fora
  do repo), alterados em `auth.users`, `auth.identities` e `public.usuarios`. Ver
  `referencia/contas-de-demo-teresina.md`.
- **Hardening** (migration `20260921120000`):
  - rate limit em `validar_codigo_ativacao_staff`: 10 chamadas a cada
    10 min por IP e 30/h por município. Testado: a 11ª chamada é bloqueada.
  - bucket `ocorrencias-fotos` limitado a 10 MB e a tipos de imagem.
  - `ErrorHandler` mostra a mensagem de "muitas tentativas".
- **Homes de técnico e gestor** com bottom nav igual à do cidadão
  (`HomeShell`). Técnico ganhou painel próprio (`minhasConcluidasProvider`
  → `listarConcluidasPorTecnico`).
- **Design system** (`decisions/015`): tokens, componentes em
  `shared/widgets/ds/`, cards de OS/ocorrência/notificação/alerta refeitos,
  dashboards dos 3 perfis com distribuições, rankings por bairro e KPIs.
  Todas as telas internas usam `SisanAppBar`.
- **Ordens**: filtros com contagem (Todas, Aguardando técnico, Com você/Em
  campo, Risco à saúde).
- **Notificações**: agrupadas por período, filtro "Não lidas", card com tipo
  e ação.
- **Detalhe da OS**: botão de ação fixo no rodapé; o gestor não vê mais
  "Aceitar" (a RLS barrava). Card de resumo e linha do tempo com as datas.
- **Web**: `driftDatabase` ganhou `web:` (a build web quebrava ao abrir),
  o que permitiu validar a UI por screenshot (Playwright + Chrome headless).

## Pendências

- Setup do OneSignal (Kassio).
- Ligar "Leaked password protection" no Dashboard do Supabase (Elto).
- Testar de novo os 3 perfis no aparelho com o design novo.
