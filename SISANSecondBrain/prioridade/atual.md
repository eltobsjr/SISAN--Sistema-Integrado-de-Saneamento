---
atualizado: 2026-09-19
---

# Prioridades — SISAN

> Prazo real: submissão do PDF até **23/09/2026**. Documento **enviado em
> 19/09** (`submissao/`, `devtrack/2026-09-19`). Hoje é **19/09/2026**.
>
> **Responsável pelas pendências abaixo: Kassio** (definido pelo Elto em
> 19/09), exceto onde estiver indicado outro nome.
>
> Escopo confirmado (`decisions/010`): os 3 perfis (cidadão/técnico/gestor)
> funcionando de ponta a ponta antes da submissão — não só documento.
> Estado técnico real (confirmado via MCP `supabase-sisan` e código):
> Fases 0-5 **concluídas**. Fase 3 (push): código pronto e mergeado, falta o
> setup manual do OneSignal. Fase 5 (IA): `classify-ocorrencia` e
> `insight-dashboard` em produção com Groq. Fase 6 (campanhas): fora do
> escopo por ora. Código e migrations commitados em `main` até `5df4bfa`;
> ficam sem commit só a documentação desta rodada e `supabase/manual/`.

## Alta

- [ ] **Setup do OneSignal** — *Responsável: Kassio.* Criar o app (gratuito),
      colocar `ONESIGNAL_APP_ID` no `.env` e `ONESIGNAL_REST_API_KEY` como
      secret da Edge Function `notify-push`. O `NOTIFY_INTERNAL_SECRET` já
      está configurado. Sem isso o push (código pronto) não dispara.
- [ ] **Revogar a chave do Groq colada no chat e gerar outra** —
      *Responsável: Kassio.* Colar a nova só no Dashboard (Edge Functions →
      Secrets) como `GROQ_API_KEY`, sem passar por chat nem arquivo.
- [ ] **Teste dos 3 perfis num aparelho real** — *Responsável: Kassio.* Usar
      as contas `*.teresina@sisan.dev` (`referencia/contas-de-demo-teresina.md`;
      a senha está com o Elto). Conferir: cidadão denuncia (offline também),
      técnico atende com checklist e foto, gestor vê o card de IA, o
      dashboard e "Meu município". Testar a fila offline em modo avião.
- [ ] **Checkpoint de 21/09** (`decisions/010`) — *Responsável: Kassio.* Se
      algum perfil não estiver testável de ponta a ponta, cortar pra mockup
      documentado daquele perfil.

## Média

- [ ] **Gemini como fallback** — *Responsável: Kassio.* Criar a chave, colar
      como secret `GEMINI_API_KEY` e implementar `callGemini` em
      `supabase/functions/_shared/provider.ts` (`decisions/013`). O PDF
      enviado já cita "dois provedores em cascata".
- [ ] **Hardening (segurança)** — *Responsável: Kassio.*
      - rate limit em `validar_codigo_ativacao_staff` (chamável sem login;
        herdado — possível força bruta do código de 8 hex);
      - limites de tamanho e tipo de arquivo no bucket `ocorrencias-fotos`
        (cuidado: restringir mime pode quebrar o upload do app);
      - ligar "Leaked password protection" no Auth (botão do Dashboard, pode
        exigir plano pago).
- [ ] **Commitar e enviar a doc desta rodada** — *Responsável: Kassio* (ou
      quem estiver com a sessão; só com permissão explícita): `decisions/013`
      e `014`, `features/009`, `referencia/contas-de-demo-teresina.md`,
      Roadmap, telas, devtrack e `supabase/manual/`.
- [ ] **Decidir se busca um 4º/5º integrante** pra multidisciplinaridade
      (incentivada pelo edital, não obrigatória) — *decisão da equipe.*

## Baixa

- [ ] **Fotos no seed de Teresina** — *Responsável: Kassio.* Hoje as
      ocorrências e as evidências do "depois" aparecem sem foto; subir
      imagens de exemplo (fictícias/livres) pro storage e preencher `fotos`.
- [ ] Tagline/slogan da identidade visual (`decisions/008` deixou em aberto)
      — *decisão da equipe.*
- [ ] **Fase 6 — Campanhas educativas**: fora do escopo por ora (decisão de
      19/09); o PDF cita como etapa da fase seguinte.
- [ ] **Convidar Kassio e Evillyn** no Supabase (Team) e no GitHub
      (colaboradores) — *Responsável: Elto* (dono do projeto; não dá pra
      Kassio se convidar sozinho).
- [ ] **Resolver o isolamento de working directory** antes de rodar o
      Antigravity em paralelo de novo (clone ou `git worktree` separados — o
      compartilhado foi a causa do incidente de 18/09) — *Responsável: Kassio.*

## Concluído em 19/09

- [x] Documento de submissão escrito e enviado (ADS / IFPI Picos; líder Elto)
- [x] Fase 5 — IA em produção (Groq): `classify-ocorrencia`, `insight-dashboard`
- [x] Rate limit (ocorrências 10/h e 30/dia; insight 10/h; código de equipe 5/h)
- [x] Seed de Teresina (2 gestores, 3 técnicos, 4 cidadãos, 65 ocorrências)
- [x] Tela "Meu município" do gestor
- [x] PostGIS movido para `extensions` (resolve `spatial_ref_sys` sem RLS)
- [x] Bucket `ordens-fotos` — desnecessário (fotos do "depois" já usam
      `ocorrencias-fotos`)

## Plano dia a dia (referência)

| Dia | Data | Foco |
|---|---|---|
| 1 | 17/09 | Fases 0-4 do app, fila offline, retrofit visual — tudo commitado |
| 2 | 18/09 | Wizard de Nova Ocorrência + Fase 3 (push) |
| 3 | 19/09 | Documento de submissão enviado + Fase 5 (IA) + rate limit + seed + PostGIS |
| 4 | 20/09 | OneSignal, chave nova do Groq e teste dos 3 perfis num aparelho real (Kassio) |
| 5 | 21/09 | **Checkpoint de risco** (`decisions/010`) |
| 6 | 22/09 | Folga de segurança / Gemini / hardening |
| — | 23/09 | Prazo final da submissão |

## Depois de garantida a submissão (se sobrar tempo até 07/10 — finalistas)

Só as 5 equipes selecionadas ganham mentoria e acesso ao Programe Studio
para o pitch (07 a 13/10). Se formos selecionados, é quando vale investir
além do que já estiver funcionando — não antes.

---

*Atualizado em 19/09/2026 ao fim da sessão. Detalhes em
`devtrack/2026-09-19 - Documento de submissão, IA em produção, seed de
Teresina e rate limit.md`.*
