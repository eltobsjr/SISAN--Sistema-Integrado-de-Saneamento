# 2026-09-18 — Onboarding guiado de Nova Ocorrência, GPS no mapa e correção do ícone

## O que foi feito

1. **"Nova Ocorrência" virou um wizard guiado (onboarding), pensado pra
   acessibilidade.** A tela passou a apresentar uma pergunta por vez (tipo →
   local → relato → fotos → revisar), com barra de progresso, botão de
   voltar por etapa (`PopScope` intercepta o back do sistema) e botão de
   continuar que só habilita quando a etapa está válida. Adaptado do padrão
   de onboarding do `polimata-concursos` (`_frame` + `_Step` enum + widgets
   `_ChoiceCard`/`_ProgressBar`), agora generalizados em
   `lib/shared/widgets/step_progress_bar.dart` e
   `lib/shared/widgets/choice_card.dart` pra reuso.

2. **Modo padrão (formulário único) foi arquivado, não removido.** Depois de
   construir os dois modos com um seletor visível, o usuário pediu que o
   modo guiado fosse o único caminho ativo. O formulário antigo foi extraído
   pra `lib/features/ocorrencias/presentation/widgets/nova_ocorrencia_padrao_view.dart`
   como `NovaOcorrenciaPadraoView` (classe pública, comentário explicando que
   está arquivada), e `nova_ocorrencia_page.dart` ficou só com
   `NovaOcorrenciaGuiadaView`, sem toggle de modo.

3. **Seletor de localização no mapa, com GPS-first.** A etapa "onde
   aconteceu" ganhou `lib/shared/widgets/map_location_picker.dart`, adaptado
   do `CriarAlertaPage` do SIGAU (`FlutterMap` + toque pra marcar pino +
   botão de GPS). Por pedido explícito do usuário, o pino inicial agora
   tenta a localização GPS atual da pessoa primeiro; se falhar/for negado,
   cai pro centro do município; em qualquer caso o campo de endereço
   digitado continua disponível como alternativa.

4. **Saga do logo/animação de entrada — revertida por completo.** Ao longo
   do dia foram tentadas: recriação de água-viva em SVG, depois a foto real
   enviada pelo usuário com fundo removido, mais uma animação de entrada
   (`agua_viva_entrada.dart` + `agua_viva_reveal_painter.dart`) e um gate de
   splash mínimo (`splash_min_duration_provider.dart`). O usuário decidiu
   reverter tudo ("tira logo e animação do app todo, deixa a gotinha de água
   mesmo") — todos esses arquivos foram deletados e `splash_page.dart` e
   `router.dart` voltaram à versão simples original (ícone de gota +
   `CircularProgressIndicator`, sem gate de duração mínima).

5. **Estado de carregamento simplificado.** `SisanLoading` deixou de ser uma
   água-viva animada e virou 3 gotas (`Icons.water_drop_rounded`) pulando em
   sequência com 0.15 de atraso entre elas — API pública (`SisanLoading()` /
   `SisanLoading.compact()`) preservada, então nenhum dos ~10 pontos de uso
   no app precisou mudar.

6. **Ícone do app — duas correções em sequência.**
   - Primeiro ajuste: o ícone estava sendo "recriado" à mão (formas
     desenhadas por script) em vez de ser o mesmo `Icons.water_drop_rounded`
     usado no resto do app. Corrigido renderizando o glifo exato da fonte
     `MaterialIcons-Regular.otf` (codepoint `0xf03b4`) via PIL, garantindo
     que a gota do ícone seja pixel-idêntica à gota usada em splash/loading.
   - Bug real encontrado depois, com o app já instalado: o ícone aparecia
     como um quadrado azul quase sem desenho visível. Causa: o *foreground*
     do ícone adaptativo (`assets/images/app_icon_fg.png`) foi renderizado
     com a gota **azul** (`#0288D1`), a mesma cor do *background* adaptativo
     configurado em `pubspec.yaml` (`adaptive_icon_background: "#0288D1"`) —
     a gota ficava invisível sobre o fundo da mesma cor. Corrigido
     renderizando o foreground com a gota em **branco**, mesma lógica já
     usada em `app_icon_full.png` (gota branca sobre fundo azul). Depois de
     `dart run flutter_launcher_icons`, build e instalação no aparelho, o
     usuário confirmou visualmente que o ícone ficou correto.

## Arquivos modificados

| Arquivo | Mudança |
|---|---|
| `lib/features/ocorrencias/presentation/pages/nova_ocorrencia_page.dart` | Simplificado pra sempre renderizar `NovaOcorrenciaGuiadaView`, sem toggle de modo |
| `lib/features/ocorrencias/presentation/widgets/nova_ocorrencia_guiada_view.dart` | Wizard guiado (novo arquivo) — etapas tipo/local/relato/fotos/revisar |
| `lib/features/ocorrencias/presentation/widgets/nova_ocorrencia_padrao_view.dart` | Formulário padrão arquivado (novo arquivo, não referenciado na UI ativa) |
| `lib/features/ocorrencias/presentation/widgets/ocorrencia_sucesso_screen.dart` | Tela de sucesso extraída pra ser compartilhada pelos dois modos |
| `lib/shared/widgets/map_location_picker.dart` | Novo — mapa com seletor de ponto, GPS-first, adaptado do SIGAU |
| `lib/shared/widgets/step_progress_bar.dart`, `choice_card.dart` | Novos widgets reutilizáveis do wizard |
| `lib/shared/widgets/app_text_field.dart` | Ganhou `maxLines`/`minLines`/`maxLength`/`textCapitalization` pro campo de relato |
| `lib/shared/widgets/sisan_loading.dart` | Reescrito: 3 gotas pulando em sequência, API pública preservada |
| `lib/features/auth/presentation/pages/splash_page.dart` | Revertido pra versão simples original (sem animação de entrada) |
| `lib/features/auth/presentation/widgets/agua_viva_entrada.dart` | Deletado |
| `lib/core/theme/branding/agua_viva_reveal_painter.dart`, `logo_paths.dart` | Deletados |
| `lib/shared/providers/splash_min_duration_provider.dart` | Deletado |
| `assets/images/app_icon_fg.png`, `app_icon_full.png` | Regerados a partir do glifo exato de `Icons.water_drop_rounded`; foreground corrigido pra branco (bug de cor igual ao background) |
| `assets/images/app_icon_fg.svg` | Deletado (abordagem final não usa SVG) |
| `android/**`, `ios/**`, `web/icons/**` | Regenerados via `dart run flutter_launcher_icons` após cada ajuste do ícone fonte |

## Bugs corrigidos

### Bug — ícone do app invisível sobre o fundo

**Problema:** no launcher do Android, o ícone do SISAN aparecia como um
quadrado azul praticamente sem desenho (só o brilho/antialiasing da gota
visível).
**Causa:** `assets/images/app_icon_fg.png` (camada de foreground do ícone
adaptativo) foi renderizado com a gota na cor azul `#0288D1` — exatamente a
mesma cor do `adaptive_icon_background` configurado em `pubspec.yaml`. A
gota se fundia com o próprio fundo.
**Correção:** foreground re-renderizado com a gota em branco (mesmo padrão
já usado em `app_icon_full.png`), seguido de `dart run
flutter_launcher_icons`, rebuild e reinstalação. Confirmado visualmente pelo
usuário no aparelho físico.

### Bug — reatividade do campo de relato no wizard guiado

**Problema:** o botão "Continuar" da etapa de relato não habilitava ao
digitar.
**Causa:** um `ListenableBuilder` que retornava `SizedBox.shrink()` não
disparava rebuild do `build()` pai, que é quem calcula
`continuarHabilitado`.
**Correção:** `_relatoCtrl.addListener(_onRelatoChanged)` no `initState`
chamando `setState({})`, com `removeListener` correspondente no `dispose`.

## Decisões técnicas

### Modo guiado como único caminho ativo

**Contexto:** o pedido inicial foi por dois modos (padrão e guiado) com
seletor visível. Depois de implementado, o usuário decidiu que o modo
guiado sozinho já cobre a necessidade de acessibilidade e simplifica a UX.
**Decisão:** o modo padrão não foi deletado — fica arquivado em arquivo
próprio, pronto pra reconectar se um dia fizer sentido oferecer os dois de
novo, mas fora do fluxo ativo.

### GPS como primeira tentativa pro pino do mapa

**Contexto:** o `MapLocationPicker` inicialmente usava o centro do
município como ponto de partida, com GPS só como ação manual (botão).
**Decisão:** GPS agora é tentado automaticamente (silenciosamente) ao abrir
a etapa; centro do município vira fallback só se GPS falhar ou for negado.
O campo de endereço digitado continua disponível em paralelo, sem forçar
uso do mapa.

## Status

- [x] Nova Ocorrência: wizard guiado com 5 etapas, validação por etapa
- [x] Modo padrão arquivado (não deletado) em arquivo próprio
- [x] Mapa de seleção de local com GPS-first + fallback pro centro do município
- [x] Saga de logo/animação revertida por completo — app de volta ao ícone
      de gota simples, sem animação de entrada
- [x] Estado de carregamento simplificado (3 gotas em sequência)
- [x] Ícone do app corrigido (glifo exato + bug de cor foreground/background)
- [x] `flutter analyze` limpo, `flutter test` passando, build debug instalado
      e verificado visualmente no aparelho físico
- [ ] Documento de submissão do hackathon — ainda não iniciado (prazo real
      23/09/2026, poucos dias restantes)
- [ ] Fase 5 (Edge Functions de IA — `classify-ocorrencia`,
      `insight-dashboard` — e push real via OneSignal) — não iniciada
- [ ] Teste end-to-end dos 3 perfis (cidadão/técnico/gestor) num aparelho
      real — pendência recorrente, ainda não feita
