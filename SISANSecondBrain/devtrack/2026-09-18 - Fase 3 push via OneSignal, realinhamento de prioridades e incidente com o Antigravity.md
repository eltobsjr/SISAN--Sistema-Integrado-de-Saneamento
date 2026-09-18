# 2026-09-18 — Fase 3: push via OneSignal, realinhamento de prioridades e incidente com o Antigravity

## O que foi feito

1. **`/priority` rodado pra realinhar `prioridade/atual.md`.** Consolidou
   pendências espalhadas em 13 devtracks + `CHECKLIST.md`, cruzando com o
   estado real do banco (via MCP `supabase-sisan`) e do código — não só o
   que os arquivos diziam. Descobriu duas lacunas que nenhum devtrack
   tinha registrado: o bucket de Storage `ordens-fotos` nunca foi criado
   (só `ocorrencias-fotos` e `relatorios` existem) e `onesignal_flutter`
   estava no `pubspec.yaml` sem nenhum uso real no código.
2. **`Roadmap.md` corrigido.** Estava com todas as fases marcadas como 🔲
   mesmo com Fases 0-4 já implementadas e commitadas — atualizado pra
   refletir o estado real (migrations conferidas via `list_migrations`,
   edge functions via `list_edge_functions`).
3. **Divisão de trabalho paralelo com o Antigravity** (Gemini 3.6 Flash):
   eu ficaria com a Fase 3 (push), ele com Fase 5 (IA) e Fase 6
   (Campanhas), cada um num branch (`feature/fase-3-push`,
   `feature/fase-5-ia`, `feature/fase-6-campanhas`), com um prompt de
   briefing detalhado (caminhos de referência, fronteiras de arquivo,
   ordem de merge) passado pro usuário repassar.
4. **Fase 3 implementada por completo** — ver detalhes técnicos abaixo.
   Mergeada em `main`.
5. **Incidente de coordenação com o Antigravity.** Ele estava operando no
   *mesmo diretório* deste repositório, não numa cópia separada — trocou o
   branch ativo (`feature/fase-6-campanhas`) por baixo dos meus pés e
   deixou ~143 linhas de edição não commitada (exibição de
   classificação/insight em `dashboard_page.dart`,
   `ocorrencia_detalhe_page.dart` etc. — claramente Fase 5) misturadas com
   o trabalho da Fase 3 no working tree. Parei, expliquei a situação pro
   usuário sem mexer em nada, e por pedido explícito dele o trabalho não
   commitado do Antigravity foi descartado: os arquivos `.dart` que ele
   tocou foram restaurados via `git restore` (sem afetar os meus), e os
   arquivos novos que ele criou (`supabase/functions/_shared/*`,
   `classify-ocorrencia`, `insight-dashboard`, migration
   `create_campanhas`) foram apagados do disco. Nenhuma migration ou edge
   function dele chegou a ser aplicada no banco real (conferido via MCP
   antes de apagar) — a perda foi só de arquivos locais não commitados.
6. **Leitura de referência pra Fase 5** (padrão `_shared/` do
   `polimata-concursos`: `provider.ts`, `groq.ts`, `gemini.ts`,
   `quota.ts`, `supabase-admin.ts`, `classify-question/index.ts` como
   exemplo de call site) — mas nenhum código chegou a ser escrito nesta
   sessão. `feature/fase-5-ia` só tem o merge do `main`, sem trabalho
   próprio.

---

## Detalhes técnicos da Fase 3

**Arquitetura escolhida — trigger genérico, não uma Edge Function por
evento.** O Roadmap original previa 4 Edge Functions
(`notify-nova-ocorrencia`, `notify-nova-os`, `notify-ocorrencia-resolvida`,
`notify-alerta-sanitario`). Na prática a tabela `notificacoes` já
centraliza todo evento in-app via triggers Postgres já existentes
(`notificar_tecnicos_nova_os`, `notificar_cidadao_status_os`). Uma única
Edge Function `notify-push`, disparada por um trigger genérico `AFTER
INSERT` em `notificacoes`, cobre todos os tipos automaticamente —
inclusive futuros, sem trigger dedicado. Reduziu 4 functions pra 1 sem
perder cobertura, e sincroniza com o padrão in-app existente em vez de
duplicá-lo.

**Autenticação interna via Vault, não `service_role` key.** `pg_net`
precisa chamar a Edge Function de dentro de um trigger sem expor a
`service_role` key em SQL (regra do `CLAUDE.md`). Um segredo aleatório
(`openssl rand -hex 32`, gerado localmente — nunca lido de volta do Vault
pelo Claude, o auto mode bloqueou essa leitura como "credential
materialization") foi guardado em `vault.secrets` e é comparado via header
`x-notify-secret` dentro da Edge Function (`verify_jwt: false`, já que a
chamada não vem de um usuário logado). Sem isso, qualquer detentor da anon
key pública poderia chamar a function e forçar push arbitrário.

**Novo trigger `notificar_staff_novo_alerta`.** Alertas sanitários são
staff-only (`features/003`, CA01) — o novo trigger notifica técnicos e
gestores do município (exceto quem criou o alerta) quando um é criado,
alimentando o mesmo fluxo genérico de push acima.

## Arquivos modificados

| Arquivo | Mudança |
|---|---|
| `lib/core/notifications/push_notifications_service.dart` | Novo — wrapper fino sobre `onesignal_flutter` (init, login, logout) |
| `lib/main.dart` | Chama `PushNotificationsService.init()` no bootstrap |
| `lib/features/auth/presentation/providers/auth_provider.dart` | `login()`/`logout()` do OneSignal amarrados ao ciclo de auth |
| `lib/features/notificacoes/presentation/pages/notificacoes_page.dart` | Ícone e navegação pro novo tipo `alerta_sanitario` |
| `android/app/proguard-rules.pro` | Novo — protege classes do OneSignal caso minificação seja ligada no futuro |
| `android/app/build.gradle.kts` | Referencia o proguard-rules.pro no build release |
| `.env.example` | `ONESIGNAL_APP_ID` documentado (público — a REST key nunca vai aqui) |
| `supabase/functions/notify-push/index.ts` | Novo — Edge Function genérica de push, fala com a REST API do OneSignal |
| `supabase/migrations/20260918140000_enable_pg_net_and_notify_secret.sql` | Habilita `pg_net`, cria segredo interno no Vault |
| `supabase/migrations/20260918140010_notify_push_trigger.sql` | Trigger genérico `AFTER INSERT` em `notificacoes` → `notify-push` |
| `supabase/migrations/20260918140020_notificar_staff_novo_alerta.sql` | Trigger de notificação pra staff em `alertas_sanitarios` |
| `SISANSecondBrain/Roadmap.md` | Status real das fases (0-4 concluídas, 3 parcial, 5/6 pendentes) |
| `SISANSecondBrain/prioridade/atual.md` | Realinhado via `/priority` |

## Status

- [x] Prioridades e Roadmap realinhados com o estado real do projeto
- [x] Fase 3 completa: código, migrations e Edge Function deployados, mergeado em `main`
- [x] Trabalho não commitado do Antigravity descartado a pedido do usuário, sem perda no banco real
- [ ] **Setup manual do OneSignal** (bloqueia teste real do push — ver "Próximos passos")
- [ ] Fase 5 — IA: nada implementado, só leitura de referência do padrão `polimata-concursos`
- [ ] Fase 6 — Campanhas: nada implementado
- [ ] Documento de submissão do edital — continua zerado, prazo 23/09 (5 dias)
- [ ] Bucket de Storage `ordens-fotos` — descoberto ausente, ainda não criado
- [ ] Decidir novo arranjo de colaboração com o Antigravity (clone ou worktree separados) antes de rodar os dois em paralelo de novo — working directory compartilhado foi a causa raiz do incidente

## Próximos passos

1. **Usuário:** criar app no OneSignal (gratuito), pegar App ID + REST API
   Key. Preencher `ONESIGNAL_APP_ID` no `.env` (não no `.env.example`).
   Configurar `ONESIGNAL_REST_API_KEY` e `NOTIFY_INTERNAL_SECRET` como
   secrets da Edge Function (`supabase secrets set ...` ou pelo
   Dashboard — Project Settings → Edge Functions → Secrets). O valor do
   `NOTIFY_INTERNAL_SECRET` já gerado foi passado pro usuário no chat da
   sessão (não fica registrado em arquivo — repositório é público, ver
   `decisions/011`); se perdido, é só gerar um novo com `openssl rand
   -hex 32` e atualizar tanto o secret da function quanto
   `vault.decrypted_secrets` (nome `notify_internal_secret`) no banco.
2. Depois do setup do OneSignal, testar push de ponta a ponta num
   aparelho físico: criar uma ocorrência (dispara `notify-nova-os` pro
   técnico) e mudar status de uma OS (dispara notificação pro cidadão).
3. Retomar Fase 5 (IA) do zero — a leitura de referência já foi feita
   (padrão `_shared/` do `polimata-concursos`), só falta escrever o
   código. Decisão de escopo tomada mas não implementada:
   `classify-ocorrencia` deve classificar só por texto (tipo/descrição/
   endereço), sem analisar a foto — o provider Groq do padrão herdado só
   suporta texto, então manter Groq→Gemini simétrico em capacidade evita
   complexidade de roteamento por tipo de mídia.
4. Antes de rodar Fase 5/6 em paralelo com o Antigravity de novo,
   resolver o isolamento de working directory (clone separado ou `git
   worktree`).
