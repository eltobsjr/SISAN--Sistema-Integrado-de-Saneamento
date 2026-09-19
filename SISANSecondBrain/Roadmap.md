---
atualizado: 2026-09-19
---

# Roadmap — SISAN

## Onde estamos

**Fases 0 a 4 concluídas e commitadas** (`bd75e73`…`bc0d2e7`, fila offline em
`9533be9`, retrofit visual em `8405902`, polimento de Nova Ocorrência em
`c076448`). **Fase 3 (push real) também concluída** (`e9b1a97`, mergeada
em `main` em `39d9333`): trigger genérico via `pg_net` em `notificacoes` →
Edge Function `notify-push` → OneSignal REST API, segmentado por
`external_id`. App funcional: login/cadastro por perfil, ocorrências com
wizard guiado (foto+GPS), ordens de serviço com checklist, mapa e
notificações in-app via realtime + push, dashboard com KPIs/alertas
sanitários. Falta só o setup manual do OneSignal (criar app, configurar
secrets) pra push funcionar de ponta a ponta — ver `prioridade/atual.md`.
Migrations aplicadas direto no Supabase via MCP `supabase-sisan`, agora
também versionadas em `supabase/migrations/` (primeira vez que essa pasta
existe no repo).

**Fase 5 (IA) concluída em 19/09**: `classify-ocorrencia` e
`insight-dashboard` em produção com Groq (Gemini fica como fallback
futuro), mais rate limit, seed de Teresina e a tela "Meu município" do
gestor — ver `devtrack/2026-09-19`. **Fase 6 (Campanhas) fora do escopo
por ora** (decisão de 19/09). Uma tentativa de implementação em paralelo
pelo Antigravity em 18/09 tinha sido descartada por um incidente de
coordenação (ver devtrack do dia).

**O documento de submissão do edital** (`features/007`) foi escrito e
enviado em 19/09 (`submissao/`). Ver `prioridade/atual.md` para as
pendências e o responsável de cada uma; este arquivo é o detalhamento
**técnico** de cada fase, não o calendário.

Legenda de status: 🔲 não iniciada · 🔄 em andamento · ✅ concluída

Regra herdada do Confia: **fatia vertical antes de camada inteira**. Cada
fase termina com algo que dá pra abrir, clicar ou chamar de ponta a ponta —
nunca um backend inteiro sem tela, nem uma tela inteira sem dado real.

## Como iniciar o projeto do zero

```bash
cd /home/eltobsjr/dev/pessoal/sisan
flutter create --org br.sisan --platforms=android,ios,web .
# Supabase: criar projeto novo no dashboard, depois:
supabase init
supabase link --project-ref <ref-do-projeto>
```

Dependências principais a adicionar no `pubspec.yaml` (ver inventário
completo no fim deste arquivo): `supabase_flutter`, `flutter_riverpod` +
`riverpod_annotation`, `go_router`, `flutter_map` + `latlong2`,
`onesignal_flutter`, `drift` + `drift_flutter` + `sqlite3_flutter_libs`,
`connectivity_plus`, `image_picker` + `cached_network_image`, `geolocator`,
`fl_chart`, `flutter_secure_storage`, `image` (EXIF strip), `pdf` +
`printing`, `freezed_annotation` + `json_annotation`.

## Fases

| Fase | Status | O que você consegue ver ou testar ao final | Spec |
|---|---|---|---|
| 0. Fundação | ✅ | App abre, login/cadastro funciona pros 3 perfis, cada um cai na home certa (guard de rota por perfil) | — (infra, sem spec própria) |
| 1. Ocorrências | ✅ | Cidadão cria ocorrência com foto+GPS (wizard guiado), recebe protocolo `OCR-AAAAMM-NNNNN`, acompanha status | [[features/001 - Ocorrências]] |
| 2. Ordens de Serviço | ✅ | Técnico vê fila do município, aceita, registra chegada, preenche checklist, sobe foto do depois, conclui | [[features/002 - Ordens de Serviço]] |
| 3. Mapa e Notificações | ✅ | Mapa com marcadores coloridos por urgência, ao vivo; push real via OneSignal (código pronto, falta só setup manual do app/secrets) | [[telas/00 - Índice de telas]] |
| 4. Dashboard e Alertas Sanitários | ✅ | Gestor abre dashboard com KPIs do mês e agregados mensais, cria um alerta sanitário | [[features/003 - Alertas Sanitários]], [[features/004 - Dashboard da Concessionária]] |
| 5. IA | ✅ | Ocorrência nova chega classificada (tipo/urgência/risco à saúde); dashboard mostra frase de insight do mês | [[features/006 - Classificação por IA]], [[features/008 - Resumo Executivo por IA no Dashboard]] |
| 6. Campanhas e polimento | 🔲 | Gestor cria campanha, cidadão vê; estados de loading/erro consistentes; app pronto pra gravar demo | [[features/005 - Campanhas Educativas]] |
| — Documento de submissão | ✅ enviado em 19/09 | PDF de 8 seções pronto pra inscrição — roda em paralelo, não depende do app terminado | [[features/007 - Documento de Submissão do Edital]] |

---

## Fase 0 — Fundação ✅

**Migrations** (`supabase/migrations/`):
- `001_enable_postgis.sql` — igual ao SIGAU
- `002_create_municipios.sql` — `id, nome, concessionaria enum('aguas_piaui','aguas_teresina','aguas_timon'), centro geography(Point,4326)` (decisão 003)
- `003_create_usuarios.sql` — `id, municipio_id, perfil enum('cidadao','tecnico','gestor'), nome, avatar` + trigger `handle_new_user` lendo metadata do Supabase Auth (mesmo padrão SGAU-009 do SIGAU, código de ativação pra staff)

**Flutter**: `lib/core/` (supabase client, router com `refreshListenable` no stream de auth — ver ERR-012 herdado, theme, constants/enums), `lib/features/auth/` (splash, login, cadastro com seletor Cidadão/Concessionária, esqueci senha).

**Não fazer**: não implementar auto-logout por inatividade (decisão herdada SGAU-023 — quebra o offline).

## Fase 1 — Ocorrências ✅

**Migration** `004_create_ocorrencias.sql` — fork de `028_denuncias.sql` +
`029_denuncias_v2.sql` do SIGAU: `municipio_id, denunciante_id, tipo
enum('vazamento','esgoto_ceu_aberto','falta_dagua','agua_contaminada',
'baixa_pressao','outros'), descricao, fotos text[], status, urgencia,
endereco, latitude, longitude, protocolo` (trigger `OCR-AAAAMM-NNNNN`) +
colunas já previstas pra Fase 5: `classificado_em, risco_saude`. RLS: cidadão
só vê as próprias; gestor/técnico veem todas do município (mesmo padrão de
`denuncias_select` do SIGAU).

**Storage**: bucket `ocorrencias-fotos` (público pra leitura, insert
autenticado, mesmo padrão do SIGAU).

**Flutter**: `lib/features/ocorrencias/` completo (data/domain/presentation),
wizard de nova ocorrência com EXIF strip antes do upload, lista "Minhas
Ocorrências" agrupada por período, detalhe com timeline de status.

**Edge Function**: `notify-nova-ocorrencia` (push pro staff do município,
`external_id`, chave `en` obrigatória — ver `referencia/erros-herdados-do-sigau.md`).

## Fase 2 — Ordens de Serviço ✅

**Migration** `005_create_ordens_servico.sql` — fork de `resgates`:
`ocorrencia_id, tecnico_id, status enum('pendente','aceita','a_caminho',
'concluida'), checklist jsonb, fotos_depois text[]` (decisão 005 — checklist
obrigatório + evidência, inspirado no Confia).

**Flutter**: `lib/features/ordens_de_servico/` — fila do técnico, fluxo
aceitar→chegada (GPS)→checklist→foto→concluir com atualização otimista +
fila offline (drift), mesmo padrão de `resgates_provider.dart` do SIGAU.

**Edge Function**: `notify-nova-os` (pro técnico) e atualização de status da
ocorrência-mãe dispara `notify-ocorrencia-resolvida` pro cidadão.

## Fase 3 — Mapa e Notificações ✅ (falta só setup manual do OneSignal)

**Flutter**: `lib/features/mapa/` (flutter_map + OpenStreetMap, marcadores
por urgência, cluster), `lib/features/notificacoes/` (badge realtime via
`realtimeVersionProvider` — contador por tabela, nunca `onPostgresChanges`
direto, ver erro herdado ERR-018).

**Migration** `010_realtime_publications.sql` — `REPLICA IDENTITY FULL` +
publication em `ocorrencias`, `ordens_servico`, `notificacoes`.

## Fase 4 — Dashboard e Alertas Sanitários ✅

**Migration** `006_create_alertas_sanitarios.sql` — fork de `zoonoses`, RLS
restrita a `gestor`/`tecnico` (ver ERR-023 herdado: checar as 4 policies,
não só SELECT/INSERT). `009_dashboard_stats_function.sql` — função
`SECURITY DEFINER` retornando agregados mensais (nunca snapshot
point-in-time — lição SGAU-021), filtrando `municipio_id` manualmente.

**Flutter**: `lib/features/dashboard/` (KPIs do mês, heatmap, `fl_chart` de
tendência, export PDF via pacote `pdf`/`printing` — cores sempre sólidas,
nunca `PdfColor` com alpha), `lib/features/alertas_sanitarios/`.

## Fase 5 — IA ✅

Ver `decisions/004` e `decisions/013`. Padrão de `_shared/` inspirado no
`polimata-concursos` (só o padrão de código — nenhuma credencial é
compartilhada entre projetos).

- **`classify-ocorrencia`** (`verify_jwt: false`, autenticada por segredo
  `x-notify-secret`): disparada pelo trigger `trg_classificar_ocorrencia`
  (`pg_net`) a cada INSERT em `ocorrencias`. Só tipo e descrição vão pro
  prompt. Devolve `{urgencia, risco_saude}`, nunca reclassifica
  (`classificado_em`), e falha de IA deixa a ocorrência com `normal`.
- **`insight-dashboard`** (`verify_jwt: true`, só gestor): RPC
  `insight_agregados()` (agregados anônimos: tipo/urgência/bairro/
  reincidência) → cache em `insights_dashboard` por município+período com
  hash dos agregados → Groq só quando os números mudam → rate limit de
  10 gerações/h. Card `InsightCard` no dashboard, com falha contida.
- **`_shared/provider.ts`**: só Groq ativo (modelos em cascata:
  `llama-3.3-70b-versatile` → `openai/gpt-oss-20b` → `llama-3.1-8b-instant`).
  Gemini entra registrando `callGemini` em `CALLERS` — ainda sem chave.
- **`_shared/errors.ts`**: `HttpError` client-safe + CORS.
- Fora do escopo desta fase: `_shared/quota.ts` (cota diária) — o rate
  limit por usuário cobre o abuso; e foto no prompt de classificação.

## Fase 6 — Campanhas e polimento (fora do escopo por ora)

**Migration** `007_create_campanhas.sql` — fork direto de `campanhas` do
SIGAU (título, descrição, link externo opcional).

**Flutter**: `lib/features/campanhas/`. Revisão geral: `SkeletonList` em
toda lista, `ErrorState` central (nunca `e.toString()` cru na UI — ver
ERR-011 herdado), `RefreshIndicator` em toda tela de lista.

**Entregável**: gravação da demo/pitch (só relevante se formos selecionados
finalistas, 07-13/10 — ver `prioridade/atual.md`).

---

## Inventário técnico completo

### Migrations (ordem de aplicação)

Aplicadas direto no Supabase via MCP `supabase-sisan` (sem `.sql` local) —
lista real em `list_migrations`, 18 migrations até `create_relatorios_bucket`
(20260918022841). Nomes reais divergem um pouco deste inventário original
(ex.: correções de RLS/grants intercaladas), mas o conteúdo essencial bate:

| # | Conteúdo | Status |
|---|---|---|
| 001-003 | PostGIS + municípios + usuários (Fase 0) | ✅ aplicada |
| 004 | `create_ocorrencias` (fork de denuncias, Fase 1) | ✅ aplicada |
| 005 | `create_ordens_servico` (fork de resgates, Fase 2) | ✅ aplicada |
| 006 | `create_alertas_sanitarios` (fork de zoonoses, Fase 4) | ✅ aplicada |
| 007 | `create_campanhas` (fork de campanhas, Fase 6) | 🔲 não aplicada |
| 008 | `create_notificacoes` (Fase 3) | ✅ aplicada |
| 009 | `dashboard_stats_function`, SECURITY DEFINER (Fase 4) | ✅ aplicada |
| 010 | realtime (`municipio_centro_latlng_e_realtime`, Fase 3) | ✅ aplicada |
| 011 | `rate_limiting` (fork de `032_rate_limiting.sql` do SIGAU) | ✅ aplicada (19/09) — 10/h e 30/dia por usuário em ocorrências; endurecida por `rate_limit_key_ownership` |
| 012 | storage buckets | ✅ `ocorrencias-fotos` (público, também recebe as fotos do "depois" do técnico) e `relatorios` (privado). `ordens-fotos` não é necessário |
| — | 19/09: `classificar_ocorrencia_trigger`, `rate_limiting`, `insight_dashboard`, `meu_municipio_gestor`, `rate_limit_key_ownership` | ✅ aplicadas e versionadas em `supabase/migrations/` (Fase 5) |
| — | `enable_pg_net_and_notify_secret`, `notify_push_trigger`, `notificar_staff_novo_alerta` (18/09) | ✅ aplicadas, infra da Fase 3 (push) — fora da numeração original, primeiras a existir como `.sql` local em `supabase/migrations/` |

### Edge Functions

**`notify-push` deployada** (18/09) — substitui as 4 functions de
notificação originalmente previstas (`notify-nova-ocorrencia`,
`notify-nova-os`, `notify-ocorrencia-resolvida`, `notify-alerta-sanitario`)
por uma única function genérica, disparada por trigger `AFTER INSERT` em
`notificacoes` via `pg_net`. Cobre nova_os, status_os e alerta_sanitario
automaticamente; qualquer tipo futuro inserido nessa tabela já ganha push
sem trigger dedicado.

**`classify-ocorrencia` e `insight-dashboard` deployadas** (19/09, Fase 5),
com `_shared/{provider,errors}.ts`. **Ainda faltam**: `notify-nova-campanha`
(Fase 6, fora do escopo por ora) e o fallback Gemini no `provider.ts`.

**Scripts manuais** (rodar no SQL Editor do Dashboard) ficam em
`supabase/manual/`; o seed de demonstração de Teresina, em
`supabase/seed/`.

### Enums (`lib/core/constants/`)

`PerfilUsuario` (cidadao/tecnico/gestor), `OcorrenciaTipo`,
`OcorrenciaStatus`, `OcorrenciaUrgencia`, `OrdemServicoStatus`,
`Concessionaria`.

### Dependências Flutter (pubspec)

`supabase_flutter`, `flutter_riverpod`, `riverpod_annotation`, `go_router`,
`flutter_map`, `latlong2`, `flutter_map_marker_cluster`, `onesignal_flutter`,
`drift`, `drift_flutter`, `sqlite3_flutter_libs`, `connectivity_plus`,
`image_picker`, `cached_network_image`, `geolocator`, `fl_chart`,
`flutter_secure_storage`, `image`, `pdf`, `printing`, `freezed_annotation`,
`json_annotation`, `intl`, `flutter_dotenv`, `share_plus`.

Dev: `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`,
`drift_dev`, `mocktail`.

## Fora do escopo do MVP

Limpeza urbana, resíduos sólidos, drenagem pluvial (fora do escopo técnico
do próprio edital). Chat e escrow (não há transação financeira). Detecção de
duplicidade de ocorrências por IA (ver `features/008`, nota de ideia
secundária).
