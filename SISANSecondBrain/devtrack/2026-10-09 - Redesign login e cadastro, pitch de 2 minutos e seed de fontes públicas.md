# 2026-10-09 — Redesign login e cadastro, pitch de 2 minutos e seed de fontes públicas

## O que foi feito

1. **Redesign do login e do cadastro** (pedido: pareciam sistema antigo). Novo
   componente `AuthScaffold` (cabeçalho em gradiente da marca com círculos
   translúcidos + folha branca arredondada com o formulário), `AuthCampo`,
   `AuthBotao`, `authDecoracao`. O cadastro ganhou seletor de tipo de conta em
   cards e bloco "Acesso da concessionária" (perfil + código). A lógica de
   validação, cadastro e navegação não mudou. Commit `2d49d13` na `main`.
2. **APK release instalado no Galaxy A36** (`adb install -r`), usando o
   contorno do truststore (`JAVA_TOOL_OPTIONS`).
3. **Contas de demo:** senha de `cidadao1`, `tecnico1` e `gestor1` (@sisan.com)
   redefinida para de demo (fora do repositório) via MCP `supabase-sisan` (projeto
   `gzoosgugbgbtcrjhfoot` confirmado antes). As outras contas de demo seguem
   com a senha anterior.
4. **Apresentação (Artifact de slides)** com prints reais do app: build web
   (`flutter build web`) servida localmente e capturada com Playwright, login
   nos 3 perfis. Primeiro com 10 slides, depois jornada animada de uma
   ocorrência (`magic move`), e por fim **enxugada para 7 slides de 2 minutos**
   (apêndice escondido com 12). Cópia no vault em
   `submissao/apresentacao/`; roteiro para 2 pessoas em
   `submissao/roteiro-pitch-2min.md`.
5. **Pesquisa de dados reais para as ocorrências.** Não existe base pública com
   ocorrências individuais georreferenciadas de Teresina. Testado: IBGE SIDRA
   (ok, 866.300 hab. no Censo 2022), Nominatim (ok), API do hub da ANA (ok; 3
   ETEs ativas de Teresina, levantamento de 2020), CSV do Instituto Água e
   Saneamento enviado pelo usuário (225 municípios do PI; Teresina: 94,81% de
   água, 55,46% de esgoto, 19,55% de perdas). Falhou/inconclusivo: Overpass
   (504), consumidor.gov.br (lista de arquivos carregada por JavaScript),
   SISAGUA (sem link), Portal AZ (domínio não resolve), Reclame Aqui (403),
   Wayback (429 / bloqueado no fetcher).
6. **Seed de fontes públicas** (aditivo, 8 registros, aplicado no banco via
   MCP): ver `supabase/seed/seed_teresina_fontes_publicas.sql`.
7. **Pedido de acesso à informação (LAI)** com dois textos prontos (ARSETE e
   Prefeitura/Ouvidoria 156): `referencia/pedido-lai-dados-ocorrencias.md`.

---

## Arquivos modificados

| Arquivo | Mudança |
|---|---|
| `lib/features/auth/presentation/widgets/auth_widgets.dart` | Novo: `AuthScaffold`, `AuthCampo`, `AuthBotao`, `authDecoracao`, `AuthRotulo` |
| `lib/features/auth/presentation/pages/login_page.dart` | Reescrito sobre os novos widgets |
| `lib/features/auth/presentation/pages/cadastro_page.dart` | Reescrito; seletor de tipo de conta em cards |
| `supabase/seed/seed_teresina_fontes_publicas.sql` | Novo: complemento aditivo e idempotente (8 casos de fonte pública) |
| `SISANSecondBrain/referencia/pedido-lai-dados-ocorrencias.md` | Novo: base legal, onde protocolar, textos A e B |
| `SISANSecondBrain/submissao/roteiro-pitch-2min.md` | Novo: roteiro de 2 pessoas |
| `SISANSecondBrain/submissao/apresentacao/` | Novo: `deck.json`, 19 slides em HTML, 14 prints, README |

## Banco (projeto `gzoosgugbgbtcrjhfoot`)

- `auth.users`: senha de 3 contas de demo alterada.
- `ocorrencias`: +8 linhas, todas com descrição iniciando em
  `[Fonte pública: veículo, data]`, atribuídas à conta demo
  `cidadao4@sisan.com` (a coluna `denunciante_id` exige um denunciante).
  Total: 74 (66 simuladas + 8 documentadas).
- Triggers com efeito colateral desligados e religados dentro da mesma
  transação; verificado depois: todos habilitados.
- Os 7 casos históricos (2022 e 2024) entram como `arquivada` e sem ordem de
  serviço; só o de 2026 (Av. Joaquim Nelson) fica `pendente` com OS.

## Bugs corrigidos

### Bug — commit com reformatação indevida

**Problema:** o commit `2d49d13` levou 7 arquivos que não faziam parte do
redesign (`auth_repository_impl`, `municipio`, `usuario`,
`i_auth_repository`, `splash_page`, `auth_provider`, `municipios_provider`),
só com quebras de linha de 3 a 14 linhas cada. Já foi para o remoto.
**Causa:** `dart format -l 120 lib/features/auth` reformatou a pasta toda e o
`git add lib/features/auth` incluiu tudo.
**Correção:** não corrigido; decisão do usuário pendente (commit de revert ou
deixar como está).

## Decisões técnicas

### Dados fictícios se chamam "base de testes interna"
**Contexto:** o usuário pediu para tratar os dados fictícios como "pesquisa
interna" nos slides.
**Alternativas consideradas:** "pesquisa interna" (sugere dado coletado de
verdade, enganoso numa avaliação); "dados de demonstração" (neutro, mas não
transmite que é nosso).
**Decisão:** "base de testes interna, simulada pela equipe". Vale nos slides,
nas notas e no roteiro. O slide do mapa e a fala do apresentador B dizem isso
em voz alta.

### Seed ancorado em fontes, sem inventar desfecho
**Contexto:** pedido de "ocorrências reais" sem existir base pública.
**Decisão:** 8 casos documentados em reportagens conferidas nas páginas
originais (GP1 05/08/2026, Portal O Dia 06/07/2022, Correio da Manhã
03/10/2024), com fonte e data na descrição, parafraseados e sem nomes de
moradores. Fica de fora tudo que só apareceu em resumo de busca ou não abriu
(multa da ARSETE, Portal AZ/Saci, Reclame Aqui/Cabral). O dado oficial entra
como contexto no slide, não como ocorrência.

### Slide de tecnologia sem nomes de tecnologia
**Decisão:** só vantagens da abordagem: monolito seguro, multiplataforma,
rápido de entregar (pedido do usuário).

## Próximos passos

1. **Commit:** nada desta sessão (seed, LAI, roteiro, apresentação, devtrack)
   foi commitado. Definir se "tudo" inclui as ~25 alterações anteriores do
   usuário (design system, tema, dashboards, `pubspec.yaml`, `assets/fonts/`).
2. **Protocolar o pedido LAI** (ARSETE e Prefeitura): confirmar nos portais
   oficiais o canal e o prazo de Teresina; anotar protocolo e data aqui. A
   resposta não chega antes da gravação de 14/10.
3. Preencher `[Nomes da equipe e contatos]` no slide final.
4. Confirmar a multa da ARSETE (R$ 3,16 milhões, IN024 41,37% e 45,67%) em
   fonte primária antes de citar; hoje está só em resumo de busca.
5. Reportagens do Saci (Portal AZ) e do Cabral (Reclame Aqui): abrir no
   navegador do usuário e colar o texto, ou ficam fora do seed.
6. Baixar CSV do consumidor.gov.br e do SNIS (série histórica) no navegador;
   processar só como contagens por tipo, sem endereço.
7. Indicadores de outubro zerados: o seed simulado vai de julho a setembro.
   Decidir se espalha parte das datas até o mês corrente (altera registros
   existentes, pedir OK).
8. Login/cadastro em tela larga: o formulário estica a largura toda. Limitar a
   largura se o app for mostrado na web. A `splash_page` ainda está no visual
   antigo.
9. Trocar a senha de demo (fora do repositório) das contas de demo antes de expor o projeto.
10. Decidir sobre o commit `2d49d13` (7 arquivos com reformatação).

## Status

- [x] Redesign de login e cadastro, commitado e enviado (`2d49d13`)
- [x] APK release instalado no celular
- [x] Senhas das 3 contas de demo redefinidas
- [x] Apresentação de 7 slides + apêndice, roteiro para 2 pessoas
- [x] Seed de fontes públicas aplicado no banco (8 registros)
- [x] Texto do pedido LAI escrito
- [x] Documentação desta sessão no vault
- [ ] Commit dos arquivos desta sessão
- [ ] Protocolar o pedido LAI
- [ ] Preencher nomes da equipe no slide final
- [ ] Verificar multa da ARSETE e casos Saci/Cabral
- [ ] Decidir sobre o commit com reformatação e sobre o mês de outubro
