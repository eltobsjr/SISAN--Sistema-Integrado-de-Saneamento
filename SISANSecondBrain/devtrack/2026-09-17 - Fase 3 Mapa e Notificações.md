# 2026-09-17 — Fase 3: Mapa e Notificações

## Contexto

Usuário pediu pra continuar o desenvolvimento. Antes de começar, avisei que
o documento de submissão (obrigatório, prazo 23/09) ainda não tinha sido
escrito enquanto o código já estava na Fase 2 — usuário optou
explicitamente por continuar o código (Fase 3: mapa/notificações) mesmo
assim. Pendência do documento registrada, não esquecida.

## Decisão de produto tomada nesta sessão

Perguntei se o mapa do cidadão deveria mostrar só as próprias ocorrências
ou todas as do município (transparência pública, tipo Colab/SeeClickFix).
Usuário escolheu **todas do município** — exigiu abrir a RLS de `SELECT`
em `ocorrencias` (antes só staff ou o próprio denunciante viam). Nível de
abertura resultante é o mesmo já usado em `usuarios_select` (qualquer
autenticado do município vê), então não é uma exposição nova de padrão.

## Banco (via MCP `supabase-sisan`, projeto `gzoosgugbgbtcrjhfoot`)

- `ocorrencias_select_publica_no_municipio`: substitui a policy de SELECT —
  agora `municipio_id = auth_municipio_id()` basta, sem exigir perfil
  staff/denunciante
- `add_municipio_centro_latlng_e_realtime`: colunas geradas
  `centro_latitude`/`centro_longitude` em `municipios` (PostgREST não expõe
  função PostGIS direto no `.select()`); `REPLICA IDENTITY FULL` +
  publication `supabase_realtime` em `ocorrencias` e `ordens_servico`
  (exigido pelo roadmap Fase 3 pra `.stream()`/badge realtime funcionar)
- Populei `centro` do Picos, que nunca tinha sido setado (nulo desde a
  criação do município) — sem isso o mapa sempre cairia no fallback
- `create_notificacoes`: tabela `notificacoes` (RLS: cada usuário só vê/
  marca/exclui as próprias), `REPLICA IDENTITY FULL` + publication.
  Dois triggers novos populam notificações reais **sem esperar a Edge
  Function de push da Fase 5**:
  - `notificar_tecnicos_nova_os` (AFTER INSERT em `ordens_servico`) → avisa
    todo técnico ativo do município quando uma OS pendente nasce
  - `notificar_cidadao_status_os` (AFTER UPDATE em `ordens_servico`) →
    avisa o denunciante da ocorrência quando a OS muda de status
    (aceita/a_caminho/concluída)
- `fix_trigger_function_grants_revoke_public`: **bug encontrado e
  corrigido** — o revoke de EXECUTE aplicado na Fase 2
  (`restrict_os_trigger_function_grants`) só revogava de `anon`/
  `authenticated` diretamente, mas toda função nova recebe EXECUTE de
  `PUBLIC` por padrão, e ambas as roles herdam de `PUBLIC`. As 4 funções de
  trigger (2 da Fase 2 + 2 novas) continuavam expostas via RPC até este
  fix. Lição: revogar sempre de `PUBLIC` também, não só das roles
  específicas — vale registrar em `erros-herdados-do-sigau.md` como lição
  própria do SISAN se acontecer de novo.

## Flutter

### `lib/shared/`
- `providers/realtime_version_provider.dart` — contador incrementado a
  cada mudança numa tabela do município (via `.stream()`), copiado do
  padrão do SIGAU
- `providers/municipio_center_provider.dart` — centroide do município pro
  `initialCenter` do mapa
- `widgets/sino_notificacoes_button.dart` — sino com badge de não lidas,
  adaptado do `_SinhinhoButton`, agora usado tanto na home do cidadão
  quanto na do técnico

### `lib/features/mapa/`
- `mapa_provider.dart` / `mapa_page.dart`, adaptados de perto do SIGAU:
  cluster de marcadores (`flutter_map_marker_cluster`), filtro por
  `OcorrenciaTipo` (era espécie de animal no SIGAU), cor do marcador por
  `OcorrenciaUrgencia` (era urgência 1-5), bottom sheet de detalhes com
  foto/status/protocolo, contador clicável, botões de localização/recarregar
- Adicionado `IOcorrenciaRepository.listarDoMunicipio()` — necessário pro
  mapa buscar todas as ocorrências ativas (não só "minhas")
- Aba "Mapa" da `cidadao_home_page.dart` deixou de ser placeholder

### `lib/features/notificacoes/`
- Feature completa (domain/data/presentation), adaptada de perto do SIGAU
  — só trocando os tipos de notificação (`nova_os`, `status_os`) e a
  navegação de destino (`/ordens-de-servico/:id`, `/ocorrencias/:id`)
- Rota `/notificacoes` no `GoRouter`

## Verificação

- `flutter analyze` → 0 issues
- `flutter test` → passa
- Advisories revisados depois de cada migration — só os já conhecidos
  (spatial_ref_sys sem RLS é tabela de referência do PostGIS, não dado de
  usuário; postgis em public; leaked password protection desligado)
- Não testado rodando de verdade (mesma pendência que já vem se arrastando)

## Próximos passos

1. Commitar e enviar esta Fase 3
2. **Documento de submissão ainda não escrito** — prazo 23/09, só 6 dias.
   Recomendo priorizar isso antes de mais código.
3. Fila offline (drift) pras ações do técnico — ainda pendente da Fase 2
4. Edge Functions `notify-nova-os`/`notify-ocorrencia-resolvida` (push
   OneSignal de verdade — hoje as notificações só existem dentro do app)
5. Teste end-to-end no navegador — pendência crônica desde a Fase 0

## Status

- [x] RLS de `ocorrencias` aberta pro município (decisão do usuário)
- [x] Colunas de centro do município + Realtime habilitado
- [x] Município Picos com `centro` preenchido
- [x] Tabela `notificacoes` + triggers de população automática
- [x] Bug de grant `PUBLIC` encontrado e corrigido
- [x] Feature `mapa` completa
- [x] Feature `notificacoes` completa
- [x] `flutter analyze` / `flutter test` limpos
- [ ] Commit + push da Fase 3
- [ ] Documento de submissão (ainda não iniciado — risco de prazo)
