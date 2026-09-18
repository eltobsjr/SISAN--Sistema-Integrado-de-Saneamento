---
atualizado: 2026-09-18
---

# Prioridades — SISAN

> Prazo real: submissão do PDF até **23/09/2026**. Hoje é **18/09/2026** — 5 dias.
> Escopo confirmado (`decisions/010`): os 3 perfis (cidadão/técnico/gestor)
> funcionando de ponta a ponta antes da submissão — não só documento.
> Estado técnico real (confirmado via MCP `supabase-sisan` e código):
> Fases 0-4 do Roadmap **concluídas e commitadas** (`bd75e73`…`bc0d2e7`,
> `9533be9`, `8405902`, `c076448`). Roadmap.md ainda está desatualizado
> (marca tudo como 🔲) — vale corrigir numa próxima sessão.

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

## Média

- [ ] **Fase 5 — IA**: Edge Functions `classify-ocorrencia` e
      `insight-dashboard` (nenhuma deployada ainda — `list_edge_functions`
      vazio)
- [ ] **Push real via OneSignal**: dependência `onesignal_flutter` está no
      `pubspec.yaml` mas sem nenhum uso no código — hoje só existe
      notificação in-app via realtime
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

## Plano dia a dia (referência)

| Dia | Data | Foco |
|---|---|---|
| 1 | 17/09 | Fases 0-4 do app, fila offline, retrofit visual — tudo commitado |
| 2 | 18/09 (hoje) | Polimento do wizard de Nova Ocorrência (feito) + **documento de submissão deveria ter começado aqui** |
| 3 | 19/09 | Documento de submissão (se não fechado hoje) + Fase 5 (IA) |
| 4 | 20/09 | Push real via OneSignal + teste end-to-end dos 3 perfis |
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
