---
atualizado: 2026-09-17
---

# Roadmap — SISAN

## Onde estamos

**Greenfield total.** Nenhum `pubspec.yaml`, nenhuma migration aplicada.
Documentação de base pronta: 8 specs de feature (`features/001` a `008`), 6
decisões de arquitetura (`decisions/001` a `006`), mapa de reaproveitamento
por projeto e catálogo de erros herdados do SIGAU (`referencia/`).

**Antes de qualquer linha de código**, o documento de submissão do edital
(`features/007`) precisa ficar pronto — é o entregável obrigatório até
23/09, o app é só o que sustenta a seção "Plano mínimo de Implementação". Ver
`prioridade/atual.md` para o calendário dia a dia; este arquivo é o
detalhamento **técnico** de cada fase, não o calendário.

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
| 0. Fundação | 🔲 | App abre, login/cadastro funciona pros 3 perfis, cada um cai na home certa (guard de rota por perfil) | — (infra, sem spec própria) |
| 1. Ocorrências | 🔲 | Cidadão cria ocorrência com foto+GPS, recebe protocolo `OCR-AAAAMM-NNNNN`, acompanha status | [[features/001 - Ocorrências]] |
| 2. Ordens de Serviço | 🔲 | Técnico vê fila do município, aceita, registra chegada, preenche checklist, sobe foto do depois, conclui | [[features/002 - Ordens de Serviço]] |
| 3. Mapa e Notificações | 🔲 | Mapa com marcadores coloridos por urgência, ao vivo; push chega no device certo | [[telas/00 - Índice de telas]] |
| 4. Dashboard e Alertas Sanitários | 🔲 | Gestor abre dashboard com KPIs do mês, mapa de calor, gráfico de 6 meses, exporta PDF; cria um alerta sanitário | [[features/003 - Alertas Sanitários]], [[features/004 - Dashboard da Concessionária]] |
| 5. IA | 🔲 | Ocorrência nova chega classificada (tipo/urgência/risco à saúde); dashboard mostra frase de insight do mês | [[features/006 - Classificação por IA]], [[features/008 - Resumo Executivo por IA no Dashboard]] |
| 6. Campanhas e polimento | 🔲 | Gestor cria campanha, cidadão vê; estados de loading/erro consistentes; app pronto pra gravar demo | [[features/005 - Campanhas Educativas]] |
| — Documento de submissão | 🔲 | PDF de 8 seções pronto pra inscrição — roda em paralelo às fases 0-2, não depende do app terminado | [[features/007 - Documento de Submissão do Edital]] |

---

## Fase 0 — Fundação

**Migrations** (`supabase/migrations/`):
- `001_enable_postgis.sql` — igual ao SIGAU
- `002_create_municipios.sql` — `id, nome, concessionaria enum('aguas_piaui','aguas_teresina','aguas_timon'), centro geography(Point,4326)` (decisão 003)
- `003_create_usuarios.sql` — `id, municipio_id, perfil enum('cidadao','tecnico','gestor'), nome, avatar` + trigger `handle_new_user` lendo metadata do Supabase Auth (mesmo padrão SGAU-009 do SIGAU, código de ativação pra staff)

**Flutter**: `lib/core/` (supabase client, router com `refreshListenable` no stream de auth — ver ERR-012 herdado, theme, constants/enums), `lib/features/auth/` (splash, login, cadastro com seletor Cidadão/Concessionária, esqueci senha).

**Não fazer**: não implementar auto-logout por inatividade (decisão herdada SGAU-023 — quebra o offline).

## Fase 1 — Ocorrências

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

## Fase 2 — Ordens de Serviço

**Migration** `005_create_ordens_servico.sql` — fork de `resgates`:
`ocorrencia_id, tecnico_id, status enum('pendente','aceita','a_caminho',
'concluida'), checklist jsonb, fotos_depois text[]` (decisão 005 — checklist
obrigatório + evidência, inspirado no Confia).

**Flutter**: `lib/features/ordens_de_servico/` — fila do técnico, fluxo
aceitar→chegada (GPS)→checklist→foto→concluir com atualização otimista +
fila offline (drift), mesmo padrão de `resgates_provider.dart` do SIGAU.

**Edge Function**: `notify-nova-os` (pro técnico) e atualização de status da
ocorrência-mãe dispara `notify-ocorrencia-resolvida` pro cidadão.

## Fase 3 — Mapa e Notificações

**Flutter**: `lib/features/mapa/` (flutter_map + OpenStreetMap, marcadores
por urgência, cluster), `lib/features/notificacoes/` (badge realtime via
`realtimeVersionProvider` — contador por tabela, nunca `onPostgresChanges`
direto, ver erro herdado ERR-018).

**Migration** `010_realtime_publications.sql` — `REPLICA IDENTITY FULL` +
publication em `ocorrencias`, `ordens_servico`, `notificacoes`.

## Fase 4 — Dashboard e Alertas Sanitários

**Migration** `006_create_alertas_sanitarios.sql` — fork de `zoonoses`, RLS
restrita a `gestor`/`tecnico` (ver ERR-023 herdado: checar as 4 policies,
não só SELECT/INSERT). `009_dashboard_stats_function.sql` — função
`SECURITY DEFINER` retornando agregados mensais (nunca snapshot
point-in-time — lição SGAU-021), filtrando `municipio_id` manualmente.

**Flutter**: `lib/features/dashboard/` (KPIs do mês, heatmap, `fl_chart` de
tendência, export PDF via pacote `pdf`/`printing` — cores sempre sólidas,
nunca `PdfColor` com alpha), `lib/features/alertas_sanitarios/`.

## Fase 5 — IA

Ver `decisions/004`. Copiar `_shared/{provider,errors,cors,supabase-admin,
quota}.ts` do `polimata-concursos` (`/home/eltobsjr/dev/pessoal/polymata/
polimata-concursos/supabase/functions/_shared/`), adaptando nomes de
domínio.

- `classify-ocorrencia`: dispara no INSERT de `ocorrencias`, schema
  `{tipo, urgencia, riscoSaude}`, Groq→Gemini fallback, nunca reclassifica.
- `insight-dashboard`: lê os agregados de `009_dashboard_stats_function`,
  devolve 2-3 frases de insight, cacheado por período, falha degrada sem
  quebrar o dashboard.

## Fase 6 — Campanhas e polimento

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

| # | Arquivo | Conteúdo |
|---|---|---|
| 001 | `enable_postgis` | extensão PostGIS |
| 002 | `create_municipios` | município + concessionária |
| 003 | `create_usuarios` | perfis + trigger de signup |
| 004 | `create_ocorrencias` | fork de denuncias |
| 005 | `create_ordens_servico` | fork de resgates |
| 006 | `create_alertas_sanitarios` | fork de zoonoses |
| 007 | `create_campanhas` | fork de campanhas |
| 008 | `create_notificacoes` | fork de notificacoes |
| 009 | `dashboard_stats_function` | agregados mensais, SECURITY DEFINER |
| 010 | `realtime_publications` | REPLICA IDENTITY FULL + publication |
| 011 | `rate_limiting` | fork de `032_rate_limiting.sql` do SIGAU |
| 012 | `storage_buckets` | `ocorrencias-fotos`, `ordens-fotos`, `relatorios` |

### Edge Functions

`notify-nova-ocorrencia`, `notify-nova-os`, `notify-ocorrencia-resolvida`,
`notify-alerta-sanitario`, `notify-nova-campanha`, `classify-ocorrencia`,
`insight-dashboard`, `_shared/` (cors, errors, supabase-admin, provider,
quota — copiados do polimata-concursos).

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
