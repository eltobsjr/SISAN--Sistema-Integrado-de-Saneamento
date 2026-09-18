---
atualizado: 2026-09-18
---

# Prioridades — SISAN

> Prazo real: submissão do PDF até **23/09/2026**. Hoje é **18/09/2026** — 5 dias.
> Escopo confirmado (`decisions/010`): os 3 perfis (cidadão/técnico/gestor)
> funcionando de ponta a ponta antes da submissão — não só documento.
> Estado técnico real (confirmado via MCP `supabase-sisan` e código):
> Fases 0-4 **concluídas**, Fase 3 (push) também **concluída** e mergeada
> em `main` (`e9b1a97`/`39d9333`) — falta só o setup manual do OneSignal
> (ver Alta). Fases 5 e 6 seguem pendentes, sem código escrito ainda.
> Roadmap.md já corrigido.

## Alta

- [ ] **Escrever o documento de submissão** (`features/007`): título, resumo
      executivo (máx. 300 palavras), problema, solução, público beneficiado,
      plano mínimo de implementação, transformação pretendida, referências.
      Entregável obrigatório do edital — nada escrito ainda, prazo em 5 dias.
- [ ] **Curso e instituição de cada integrante** (Elto/Kassio/Evillyn) — sem
      isso não dá pra preencher o formulário de inscrição
- [ ] **Confirmar formulário oficial de submissão** (link do edital) e
      formato exigido de anexo
- [ ] **Definir o líder designado** pra comunicação oficial com a organização
- [ ] **Setup manual do OneSignal**: criar app (gratuito), preencher
      `ONESIGNAL_APP_ID` no `.env` e configurar `ONESIGNAL_REST_API_KEY` +
      `NOTIFY_INTERNAL_SECRET` como secrets da Edge Function `notify-push`
      — sem isso o push (código já pronto) não dispara de verdade

## Média

- [ ] **Fase 5 — IA**: Edge Functions `classify-ocorrencia` e
      `insight-dashboard` (nenhuma deployada ainda — `list_edge_functions`
      vazio; leitura de referência do padrão `polimata-concursos` já feita,
      falta escrever o código)
- [ ] **Teste end-to-end dos 3 perfis** (cidadão/técnico/gestor) num
      aparelho real — pendência recorrente em várias sessões
- [ ] Decidir se busca um 4º/5º integrante pra multidisciplinaridade
      (incentivada pelo edital, não obrigatória)
- [ ] Confirmar/criar bucket de Storage `ordens-fotos` pras evidências do
      técnico — hoje só `ocorrencias-fotos` e `relatorios` existem no banco

## Baixa

- [ ] Tagline/slogan da identidade visual (`decisions/008` deixou em aberto)
- [ ] **Fase 6 — Campanhas e polimento**: migration `create_campanhas` +
      `lib/features/campanhas/` — nada iniciado, só relevante se sobrar
      tempo (não bloqueia a submissão)
- [ ] Migration `011_rate_limiting` (fork de `032_rate_limiting.sql` do
      SIGAU) — hardening, não bloqueia demo
- [ ] Convidar Kassio e Evillyn no Supabase (Team) e no GitHub
      (colaboradores)
- [ ] Testar a fila offline (drift) em modo avião de verdade
- [ ] Tela de "meu município" pro gestor visualizar/regenerar dados
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
