# 2026-09-17 — Fila offline (drift) para técnico e cidadão

## Contexto

Pendência que vinha desde a Fase 2 (item 8 do roadmap: "Concluir OS —
atualização otimista + fila offline"). Usuário pediu explicitamente pra
fechar isso agora, junto com a Fase 4 (rodando em paralelo).

Escopo ampliado além do que o roadmap previa só pra Ordens de Serviço: o
próprio `CLAUDE.md` do projeto lista offline como "crítico para técnicos de
campo **e denúncias em área com sinal ruim**" — então a criação de nova
ocorrência pelo cidadão também ganhou suporte offline, não só as ações do
técnico.

## O que foi feito

Infra copiada e adaptada do SIGAU (`core/database/`, `shared/services/
sync_service.dart`, `shared/services/connectivity_service.dart`,
`shared/providers/{connectivity,sync_version}_provider.dart`):

- `core/database/tables/sync_queue_table.dart` + `app_database.dart` —
  banco local (drift/SQLite), tabela `sync_queue` com operação, tabela
  alvo, payload JSON, status (`pending`/`failed`), tentativas
- `connectivity_service.dart` — checagem/stream de conectividade
  (`connectivity_plus`)
- `sync_service.dart` — processa a fila ao reconectar, no máximo 3
  tentativas antes de marcar `failed`. Adaptado pras 4 operações do SISAN
  (SIGAU tinha só `INSERT:registros_animais`/`UPDATE:resgates`):
  - `INSERT:ocorrencias` — sobe fotos salvas localmente, insere a ocorrência
  - `ACEITAR:ordens_servico` / `CHEGADA:ordens_servico` — updates simples
  - `CONCLUIR:ordens_servico` — sobe fotos do "depois", atualiza
    checklist/status
  - Novo (não existia no SIGAU): `SyncService.savePhotosLocally()` — copia
    fotos pra um diretório permanente do app antes de enfileirar (path do
    picker/câmera não sobrevive garantido até a próxima reconexão)
- Adicionada dependência `path_provider` (era só transitiva — agora
  declarada, já que passou a ser usada direto)

### Ordens de Serviço (`ordens_servico_provider.dart`)

`aceitar`/`registrarChegada`/`concluir` agora checam conectividade antes de
escrever: online segue o fluxo normal; offline aplica **atualização
otimista local** (via `OrdemServico.copyWith`, novo) e enfileira a
operação, sem lançar erro pro usuário (lição herdada do SIGAU). Também
passou a escutar `realtimeVersionProvider('ordens_servico')` — não existia
antes, aproveitando o Realtime que a Fase 3 já habilitou.

### Ocorrências (`ocorrencias_provider.dart`)

`criar()` agora checa conectividade: offline salva as fotos localmente,
enfileira o INSERT e devolve uma `Ocorrencia` local com id
`offline_<timestamp>` e `protocolo = 'OFFLINE'` (sentinela, mesmo padrão do
SIGAU) — sem tentar adivinhar o protocolo real, que só existe depois do
trigger `fn_protocolo_ocorrencia` rodar no servidor.

### UI/UX

- `sisan_app.dart`: banner laranja global "sem conexão" (`_OfflineWrapper`,
  copiado do SIGAU) + inicialização do `syncServiceProvider`
- `nova_ocorrencia_page.dart`: tela de sucesso muda de mensagem/ícone
  quando o protocolo é o sentinela `OFFLINE` ("Ocorrência salva!" em vez de
  "registrada!", sem caixa de protocolo pra copiar)
- `minhas_ocorrencias_page.dart`: ocorrência com protocolo `OFFLINE` mostra
  "Aguardando conexão para enviar" no lugar do protocolo e fica sem toque
  (ainda não tem id real pra abrir o detalhe)
- Novo `shared/widgets/pending_sync_banner.dart`: aviso "N ação(ões)
  aguardando conexão", usado na fila de OS e em "Minhas Ocorrências"

## Limitação conhecida (documentada, não resolvida)

Fotos de "depois" (conclusão de OS) enfileiradas offline não aparecem na
UI até sincronizar de verdade — o `OrdemServico` local otimista não
carrega os paths locais como preview. Mesma limitação que o SIGAU aceita
pro fluxo de resgate (lá é ainda mais restrito: nem enfileira foto
offline). Se sobrar tempo, dá pra fazer o preview local depois.

## Verificação

- `dart run build_runner build --delete-conflicting-outputs` → gerou
  `app_database.g.dart` sem erros
- `flutter analyze` → 0 issues
- `flutter test` → passa
- Removido um arquivo órfão (`sync_pending_provider.dart`, duplicava o
  `pendingSyncCountProvider` que ficou dentro de `sync_service.dart`) antes
  de nunca ter sido referenciado em lugar nenhum — provavelmente sobra de
  uma tentativa anterior interrompida na mesma sessão
- Não testado rodando de verdade (modo avião / desligar rede) — pendência
  que seguimos carregando

## Status

- [x] Infra de banco local (drift) + conectividade + sync service
- [x] Ordens de Serviço com atualização otimista + fila offline
- [x] Nova ocorrência com fila offline (escopo ampliado, pedido do
      CLAUDE.md do projeto)
- [x] Banner global de offline + indicador de pendências de sync
- [x] `flutter analyze` / `flutter test` limpos
- [ ] Commit + push
- [ ] Teste real em modo avião
