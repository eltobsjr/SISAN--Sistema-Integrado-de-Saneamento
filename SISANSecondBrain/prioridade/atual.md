---
atualizado: 2026-09-19
---

# Prioridades — SISAN

> Prazo real: submissão do PDF até **23/09/2026**. Documento **enviado em 19/09** (ver devtrack). Hoje é **19/09/2026**.
> Escopo confirmado (`decisions/010`): os 3 perfis (cidadão/técnico/gestor)
> funcionando de ponta a ponta antes da submissão — não só documento.
> Estado técnico real (confirmado via MCP `supabase-sisan` e código):
> Fases 0-5 **concluídas** (Fase 3/push mergeada em `main`, falta só o setup
> manual do OneSignal — Kassio; Fase 5/IA em produção com Groq). Fase 6
> (campanhas) fora do escopo por ora.

## Alta

- [x] ~~Escrever o documento de submissão~~ — enviado em 19/09
- [x] ~~Curso, instituição, líder~~ — ADS/IFPI Picos, líder Elto
- [ ] **Setup do OneSignal — Kassio:** criar app, `ONESIGNAL_APP_ID` no
      `.env` e `ONESIGNAL_REST_API_KEY` como secret da `notify-push`
      (o `NOTIFY_INTERNAL_SECRET` já está configurado)
- [ ] **Revogar a chave do Groq colada no chat** e gerar outra (colar só no
      Dashboard como `GROQ_API_KEY`)
- [ ] **Teste dos 3 perfis num aparelho real** (contas `*.teresina@sisan.dev`
      do seed) e da fila offline em modo avião
- [ ] **Checkpoint de 21/09** (`decisions/010`)

## Média

- [x] ~~Fase 5 — IA (`classify-ocorrencia`, `insight-dashboard`)~~ — em produção (Groq)
- [x] ~~Rate limit~~ — ocorrências 10/h e 30/dia por usuário
- [x] ~~Seed de Teresina~~ — 2 gestores, 3 técnicos, 4 cidadãos, 65 ocorrências
- [x] ~~Tela "Meu município" do gestor~~
- [ ] Gemini como fallback (precisa de chave; o PDF cita dois provedores)
- [ ] Hardening: rate limit em `validar_codigo_ativacao_staff` (anon), limites
      de tamanho/mime em `ocorrencias-fotos`, "Leaked password protection"
- [ ] Decidir se busca um 4º/5º integrante pra multidisciplinaridade

## Baixa

- [ ] Tagline/slogan da identidade visual (`decisions/008` deixou em aberto)
- [ ] **Fase 6 — Campanhas educativas**: fora do escopo por ora (decisão de
      19/09); o PDF cita como etapa da fase seguinte
- [ ] Convidar Kassio e Evillyn no Supabase (Team) e no GitHub
      (colaboradores)
- [ ] Resolver isolamento de working directory antes de rodar o Antigravity
      em paralelo de novo (clone ou `git worktree` separados — o
      compartilhado foi a causa do incidente de 18/09, ver devtrack)

## Plano dia a dia (referência)

| Dia | Data | Foco |
|---|---|---|
| 1 | 17/09 | Fases 0-4 do app, fila offline, retrofit visual — tudo commitado |
| 2 | 18/09 (hoje) | Wizard de Nova Ocorrência + Fase 3 (push) feitos. **Documento de submissão continua não iniciado** — prioridade nº1 pra amanhã |
| 3 | 19/09 | Documento de submissão (urgente) + Fase 5 (IA) |
| 4 | 20/09 | Setup do OneSignal + teste end-to-end dos 3 perfis |
| 5 | 21/09 | **Checkpoint de risco** (`decisions/010`): se algum perfil não estiver testável de ponta a ponta, cortar pra mockup documentado |
| 6 | 22/09 | Fase 6 (se sobrar tempo) + revisão final do PDF |
| — | 23/09 | Submissão |

## Depois de garantida a submissão (se sobrar tempo até 07/10 — finalistas)

Só as 5 equipes selecionadas ganham mentoria e acesso ao Programe Studio
para o pitch (07 a 13/10). Se formos selecionados, é quando vale investir
além do que já estiver funcionando — não antes.

---

*Gerado por `/priority` em 18/09/2026. Fontes: 12 devtracks + `CHECKLIST.md`
+ estado real do banco/código (MCP `supabase-sisan`).*
