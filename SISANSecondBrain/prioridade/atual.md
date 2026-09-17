# Prioridade atual — SISAN

> Prazo real: submissão do PDF até **23/09/2026**. Hoje é **17/09/2026** — 6 dias.
> Escopo confirmado (`decisions/010`): os 3 perfis (cidadão/técnico/gestor)
> funcionando de ponta a ponta antes da submissão — não só documento.

## Pendências restantes

- [ ] **Curso e instituição de Elto, Kassio e Evillyn** (nomes já fechados —
      ver `decisions` e memória do projeto) e quem é o líder designado pra
      comunicação oficial com a organização
- [ ] Decidir se busca 4º/5º integrante pra multidisciplinaridade
      (incentivada pelo edital, não obrigatória — hoje o trio é todo
      ADS/TI)
- [ ] Tagline/slogan da identidade visual (`decisions/008` deixou em aberto)
- [ ] Confirmar o link/formato oficial do formulário de submissão

## Plano dia a dia

| Dia | Data | Foco |
|---|---|---|
| 1 | 17/09 (hoje) | SecondBrain criado ✅. Nome definitivo SISAN ✅. Identidade visual, município piloto (Picos) e escopo do protótipo decididos ✅. Equipe: 3 nomes fechados, curso/instituição pendente. |
| 2 | 18/09 | Escrever o documento de submissão completo (8 seções do edital, `features/007`) — ancorado em Picos (`decisions/009`) |
| 3 | 19/09 | Scaffold Flutter+Supabase (Fase 0 do Roadmap); Fase 1 — `ocorrencias` (fork de `denuncias` do SIGAU) |
| 4 | 20/09 | Fase 2 — `ordens_de_servico` (fork de `resgates` + checklist/evidências do Confia); Fase 3 — mapa e notificações |
| 5 | 21/09 | Fase 4 — dashboard do gestor + alertas sanitários. **Checkpoint de risco** (`decisions/010`): se algum dos 3 perfis não estiver testável de ponta a ponta até o fim de hoje, cortar esse perfil pra mockup documentado em vez de arriscar nada funcionando |
| 6 | 22/09 | Fase 5 — Edge Functions `classify-ocorrencia`/`insight-dashboard` (primeiro corte se faltar tempo); Fase 6 — campanhas e polimento; revisão final do PDF |
| — | 23/09 | Submissão |

## Por que o documento vem antes do código

O edital pede um PDF com plano mínimo de implementação — o app funcionando
é diferencial nosso (`decisions/010`), não exigência do edital. Escrever a
proposta no dia 2 garante que o entregável obrigatório existe mesmo se o
protótipo atrasar, e a spec de cada feature (`features/`) já está pronta
desde o Roadmap — não trava a escrita.

## Depois de garantida a submissão (se sobrar tempo até 07/10 — finalistas)

Só as 5 equipes selecionadas ganham mentoria e acesso ao Programe Studio
para o pitch (07 a 13/10). Se formos selecionados, é quando vale investir
além do que já estiver funcionando — não antes.
