# 2026-09-17 — Fase 2 Ordens de Serviço: fila, aceitar, chegada, checklist e conclusão

## O que foi feito

Commitou e enviou pro GitHub o que sobrevivia sem versionar desde a trava
(ver devtrack anterior): dois commits, `Fase 0` (scaffold/auth/navegação) e
`Fase 1` (ocorrências), `git push` pra `origin/main` com o usuário no loop
em cada passo.

Confirmado que o bucket de Storage `ocorrencias-fotos` já existia (criado
em algum ponto sem devtrack correspondente) — público, com policy de
`INSERT` pra `authenticated` e `SELECT` pra `public`, exatamente como o
datasource de `ocorrencias` espera. Pendência da auditoria anterior fechada.

Implementada a Fase 2 completa — Ordens de Serviço — seguindo a regra
reforçada nesta sessão: telas/widgets novos partem do arquivo real do SIGAU
(`features/resgates/`) e são adaptados, não reescritos do zero.

### Banco (via MCP `supabase-sisan`, projeto `gzoosgugbgbtcrjhfoot`)

- Migration `create_ordens_servico`: tabela `ordens_servico`
  (`ocorrencia_id`, `municipio_id`, `tecnico_id`, `status enum`, `checklist
  jsonb`, `fotos_depois text[]`, timestamps de aceite/chegada/conclusão),
  RLS (`select` pra técnico/gestor do município, `update` só pro técnico
  dono ou ainda sem dono)
- **Decisão de arquitetura nova**: trigger `criar_os_ao_registrar_ocorrencia`
  (AFTER INSERT em `ocorrencias`) cria a OS `pendente` automaticamente — a
  fila do técnico nasce sozinha, sem passo manual de "abrir OS". Trigger
  `sincronizar_status_ocorrencia_por_os` espelha o status da OS de volta pra
  `ocorrencias.status` (aceita/a_caminho → em_analise, concluida →
  resolvida), pra quem só olha a ocorrência (cidadão, futuro dashboard) ver
  o andamento sem join.
- Migration `restrict_os_trigger_function_grants`: revoga EXECUTE de
  anon/authenticated nas duas funções de trigger (não precisam ser
  chamáveis via RPC — mesmo espírito da migration herdada
  `restrict_security_definer_grants`)
- Migration `add_chegada_coords_ordens_servico`: colunas
  `chegada_latitude`/`chegada_longitude` (evidência de GPS no "registrar
  chegada", pedido explícito do roadmap)
- `get_advisors` rodado depois de cada migration — nada novo além do que já
  era conhecido (spatial_ref_sys, postgis em public, leaked password
  protection desligado — nenhum bloqueante, nenhum tocado nesta sessão)

### Flutter — `lib/features/ordens_de_servico/`

- `core/constants/ordem_servico_status.dart`,
  `core/constants/checklist_encerramento.dart` (checklist por
  `OcorrenciaTipo`, decisions/005)
- Domain: `OrdemServico` (entidade com a `Ocorrencia` embutida — a fila não
  faz sentido sem tipo/descrição/localização), `IOrdemServicoRepository`
- Data: datasource Supabase com join `ordens_servico(*, ocorrencias(*))`,
  repository impl — mesmo padrão simples (sem usecases) já usado em
  `ocorrencias`
- Provider: `OrdensServicoNotifier` (`AsyncNotifier`, fila do município do
  técnico autenticado) + `ordemServicoPorIdProvider`
- Presentation, adaptado de `resgates_page.dart`/`resgate_detalhe_page.dart`
  do SIGAU:
  - `OrdensServicoPage` — fila ordenada por urgência (`OcorrenciaUrgencia`)
    e depois por ordem de chegada (FIFO)
  - `OrdemServicoDetalhePage` — timeline de status, mini-mapa (`flutter_map`,
    só quando a ocorrência tem coordenadas), fotos da denúncia + fotos do
    reparo, botão de ação contextual (Aceitar → Registrar Chegada com GPS
    real via `Geolocator` → Concluir)
  - Bottom sheet de conclusão: **diferente do SIGAU** (que permite concluir
    sem fotos) — aqui `Concluir` só habilita com checklist 100% marcado e
    pelo menos 1 foto do depois, conforme decisions/005
- `TecnicoHomePage` deixou de ser placeholder: mostra contagem de OS
  pendentes e leva pra fila
- Rotas `/ordens-de-servico` e `/ordens-de-servico/:id` no `GoRouter`

### Widgets compartilhados portados do SIGAU

- `shared/widgets/empty_state.dart`, `shared/widgets/loading_overlay.dart` —
  cópia literal (genéricos, sem conteúdo de domínio)
- `shared/widgets/sisan_loading.dart` — adaptado de `sigau_loading.dart`:
  mesma arquitetura de animação (`AnimationController`, curvas de
  escala/opacidade, timing de 2200ms/1200ms), pata trocada por uma gota
  d'água pulsante, paleta trocada pro azul "Água Viva"

### Memória

Reforçada `feedback_ui_reuse_sigau.md` — usuário pediu explicitamente que
"copiar o arquivo do SIGAU e adaptar" vire regra fixa, não só diretriz
geral. Passo a passo documentado na memória.

## Verificação

- `flutter analyze` → 0 issues
- `flutter test` → passa
- RLS revisada manualmente (select/update por município+perfil, trigger
  fecha o ciclo ocorrência→OS)
- **Não testado rodando de verdade** (pedido explícito do usuário nesta
  sessão — "não precisa testar agora, vamos construir mais e mais
  funcionalidades")

## Arquivos modificados

Commits `bd70771` (Fase 0), `d44511a` (Fase 1) — enviados antes desta
feature. Fase 2 ainda não commitada ao final desta sessão (ver Status).

## Próximos passos

1. Commitar e enviar a Fase 2 (Ordens de Serviço)
2. Testar o fluxo ponta a ponta no navegador — cidadão registra →
   técnico vê na fila → aceita → registra chegada → conclui com checklist
   e foto (pendência que já vem se arrastando desde a Fase 0+1)
3. Itens do roadmap da Fase 2 ainda não implementados nesta sessão:
   - Fila offline (drift) + atualização otimista — hoje aceitar/chegar/
     concluir exigem conexão; sem sinal em campo, a ação falha
   - Edge Functions `notify-nova-os` (push pro técnico) e
     `notify-ocorrencia-resolvida` (push pro cidadão)
4. `GestorHomePage` continua placeholder — dashboard é Fase 4 no roadmap
5. `Usuario` tem `avatar_id` no banco mas a entidade Flutter ainda não expõe
   o campo — `ProfileAvatar` do SIGAU não foi portado por não ter uso ainda

## Status

- [x] Commit + push da Fase 0 e Fase 1
- [x] Bucket `ocorrencias-fotos` confirmado (já existia, com RLS correta)
- [x] Migration `ordens_servico` + triggers de sincronização
- [x] Feature `ordens_de_servico` completa (domain/data/presentation)
- [x] Fila do técnico, aceitar, registrar chegada, checklist, foto do
      depois, concluir
- [x] `flutter analyze` / `flutter test` limpos
- [ ] Commit + push da Fase 2
- [ ] Teste end-to-end no navegador
- [ ] Fila offline (drift) pra ações do técnico
- [ ] Edge Functions de notificação
