# 2026-09-17 — Retrofit visual das telas de Fase 0 e 1 pro padrão SIGAU

## Contexto

Usuário perguntou: "voce fez nos de agora [Fase 2], mas e nas telas
componentes e widgets antigos?" — ou seja, telas de Fase 0 (auth/home) e
Fase 1 (ocorrências), escritas antes da regra "copiar o arquivo do SIGAU e
adaptar" ter sido reforçada explicitamente nesta sessão, não tinham sido
auditadas contra essa regra.

## O que foi feito

Rodei uma auditoria (fork) comparando cada tela de Fase 0/1 do SISAN com o
arquivo equivalente real do SIGAU. Veredito por arquivo:

| Arquivo | Veredito |
|---|---|
| `minhas_ocorrencias_page.dart` | Convergente — já usava `SisanErrorState`/`SkeletonList` |
| `ocorrencia_detalhe_page.dart` | Convergente, faltava viewer de foto fullscreen + `SisanLoading.compact` |
| `login_page.dart` / `cadastro_page.dart` | Parcial — esqueleto certo, faltava polimento (toggle de senha, ícones, confirmar senha) |
| `splash_page.dart` | Divergente — spinner genérico, nem usava o `SisanLoading` já existente no projeto |
| `gestor_home_page.dart` | Divergente, mas placeholder intencional (dashboard é Fase 4) — **não mexido** |
| `cidadao_home_page.dart` | Divergente de verdade — SIGAU tem bottom nav de 4 abas + header com avatar/gradiente; SISAN era um Scaffold com 2 cards |

Perguntei ao usuário como tratar `cidadao_home_page.dart` (maior gap, exige
decisão de escopo — SIGAU usa abas de Mapa e Perfil que o SISAN ainda não
tem). Resposta: criar a casca completa mesmo sem conteúdo real, deixando
Mapa como placeholder pra preencher depois.

### Retrofits aplicados

- **`splash_page.dart`**: trocado o `Icon`+`Text`+`CircularProgressIndicator`
  manual por `SisanLoading()` (adaptado do `sigau_loading.dart` na sessão
  anterior).
- **`login_page.dart`**: adicionado toggle de mostrar/ocultar senha,
  `prefixIcon` nos campos, `FilledButton` (era `ElevatedButton`), subtítulo
  "Sistema Integrado de Saneamento" — mesma estrutura visual do SIGAU.
- **`cadastro_page.dart`**: adicionado confirmar senha, toggle de senha,
  ícone de cabeçalho, `_TipoContaSelector` como cards (`_TipoCard`, mesmo
  padrão visual do SIGAU) no lugar do `SegmentedButton` — lógica de negócio
  (cidadão/concessionária + código de ativação) mantida intacta, só a
  camada visual mudou.
- **`ocorrencia_detalhe_page.dart`**: loading state trocado pra
  `SisanLoading.compact()`; fotos da denúncia agora abrem viewer fullscreen
  ao toque.
- **Novo `shared/widgets/foto_viewer.dart`**: extraído o
  `_FotoViewerDialog` que eu tinha duplicado dentro de
  `ordem_servico_detalhe_page.dart` (Fase 2) pra um widget compartilhado
  (`showFotoViewer`) — usado agora tanto em ocorrências quanto em ordens de
  serviço, sem duplicação.
- **`cidadao_home_page.dart`** (reescrita completa): bottom nav de 4 abas
  (Início/Mapa/Registrar/Perfil, `NavigationBar`), header com gradiente +
  avatar (inicial do nome, já que o SISAN não tem o sistema de avatar
  pixel-art do SIGAU nem `avatarId` exposto na entidade `Usuario` ainda),
  grid de ações (Nova Ocorrência / Minhas Ocorrências — só o que existe de
  verdade, ao contrário do SIGAU que tem 8 cards), lista de "Atividade
  recente" (últimas 3 ocorrências do próprio cidadão), aba Registrar
  dedicada (mesmo texto/botão do SIGAU adaptado pro tema), aba Perfil com
  avatar/nome/e-mail/chip de perfil + logout com confirmação, `PopScope`
  com diálogo de confirmação de saída do app.
  - **Mapa**: placeholder puro ("Mapa em construção") — não implementado
    ainda, por decisão explícita do usuário.

### Não mexido (intencional)

- `gestor_home_page.dart` — placeholder aceitável, dashboard é Fase 4
- `GestorHomePage`/`TecnicoHomePage` não ganharam bottom nav — o pedido foi
  especificamente sobre a home do cidadão

## Verificação

- `flutter analyze` → 0 issues
- `flutter test` → passa
- Não testado rodando de verdade (mesma pendência já registrada nos
  devtracks anteriores)

## Próximos passos

1. Commitar e enviar este retrofit
2. Quando a feature `mapa` existir (roadmap), substituir
   `_MapaTabPlaceholder` pelo `flutter_map` real com as ocorrências do
   município
3. Expor `avatarId` na entidade `Usuario` se algum dia se quiser portar o
   sistema de avatar pixel-art do SIGAU (`ProfileAvatar`) — hoje o header e
   a aba Perfil usam só a inicial do nome
4. Retrofits ainda pendentes do roadmap: fila offline (drift), Edge
   Functions de notificação, teste end-to-end no navegador

## Status

- [x] Auditoria SIGAU vs SISAN (Fase 0/1)
- [x] Retrofit: splash, login, cadastro, detalhe de ocorrência
- [x] Viewer de foto compartilhado (`foto_viewer.dart`)
- [x] Home do cidadão com bottom nav de 4 abas
- [x] `flutter analyze` / `flutter test` limpos
- [ ] Commit + push deste retrofit
