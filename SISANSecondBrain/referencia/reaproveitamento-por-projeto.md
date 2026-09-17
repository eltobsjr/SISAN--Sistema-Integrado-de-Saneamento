# O que reaproveitar de cada projeto

Mapa vivo — consultar antes de implementar qualquer feature nova. Se não
estiver aqui, provavelmente vale a pena escrever do zero.

## SIGAU (base arquitetural principal)

`/home/eltobsjr/dev/pessoal/SIGAU`

Fork conceitual (não literal — reescrever no domínio novo, mas seguindo a
mesma estrutura de pastas, nomes de convenção e decisões de arquitetura):

| Feature do SIGAU | Vira no SISAN | O que aproveitar |
|---|---|---|
| `features/denuncias/` | `features/ocorrencias/` | Entity, migrations (028/029), protocolo automático `DEN-AAAAMM-NNNNN` → `OCR-AAAAMM-NNNNN`, ciclo pendente→em_análise→resolvida→arquivada, campos de urgência/localização/fotos |
| `features/resgates/` | `features/ordens_de_servico/` | Fluxo aceitar→chegar→concluir com atualização otimista e fila offline — mas encerrar exige checklist (ver decisão 005) |
| `features/zoonoses/` | `features/alertas_sanitarios/` | Alerta restrito a staff (gestor/técnico), correlacionar zona de esgoto a céu aberto recorrente com indicador de saúde |
| `features/dashboard/` | `features/dashboard/` | KPIs mensais (não snapshot — ver SGAU-021), heatmap, gráfico de 6 meses (`fl_chart`), export PDF (`pw.` API, nunca `PdfColor` com alpha) |
| `features/campanhas/` | `features/campanhas/` | Campanhas de conscientização (ex.: "Semana da Economia de Água"), link externo opcional |
| `features/notificacoes/` | igual | Realtime via contador por tabela (`realtimeVersionProvider`), nunca `onPostgresChanges` direto |
| `features/mapa/`, `shared/services/sync_service.dart`, `core/database/` | igual | Offline-first inteiro, sync_queue via drift |
| `features/animais/` (CRUD+QR), `features/adocao/` | **descartar** | Não se aplicam ao domínio de saneamento |

Ver `erros-herdados-do-sigau.md` para os 44 bugs já resolvidos nessa mesma
stack — não redescobrir nenhum deles.

## Confia

`/home/eltobsjr/dev/pessoal/confia`

- **Fluxo de verificação com checklist obrigatório + evidências** (`features/003
  - Fase 2 Fluxo de verificação.md`, CA05/CA06): aprovar exige checklist
  completo; reprovar exige motivo + 2 evidências (foto/vídeo com geotag e
  horário). Base da decisão 005 (encerramento de Ordem de Serviço).
- Geocoding sem chave/cartão via ViaCEP (CEP→endereço) + Photon (busca livre
  e reverso) — útil se precisarmos de busca de endereço por CEP em algum
  formulário, evita depender de API paga.
- **Não** aproveitar: chat, escrow/pagamento, ledger em centavos — não há
  transação financeira entre cidadão e concessionária no SISAN.

## Polymata / polimata-concursos

`/home/eltobsjr/dev/pessoal/polymata`

- **`polimata-concursos/supabase/functions/_shared/`** — padrão de Edge
  Function de IA (`provider.ts`, `quota.ts`, `errors.ts`, `cors.ts`,
  `supabase-admin.ts`): multi-provider com fallback, retry com backoff,
  schema estruturado, cota diária, cache por "já processado". Base da
  decisão 004 (`classify-ocorrencia`).
- **Catálogo de 40 mecânicas de aprendizado**
  (`PolymataSecondBrain/mecanicas/00 - Catálogo de mecânicas de
  aprendizado.md`) — cardápio pronto se decidirmos incluir um módulo
  educativo (gamificação de conscientização sobre saneamento) na proposta.
  XP/streak/badges já têm precedente de implementação real no Polymata
  original.
- Flutter rodando em mobile + web a partir do mesmo código (`polimata-concursos`
  builda pra Android/iOS/Web/Desktop) — confirma que dá pra ter dashboard
  web e app mobile no mesmo projeto Flutter, sem duas codebases.

## glicemiastartup

`/home/eltobsjr/dev/pessoal/glicemiastartup`

- **Playbook de submissão a hackathon universitário** (devtracks
  `2026-08-21` e `2026-09-10`): montar equipe respeitando exigências do
  edital, escolher trilha/enquadramento com cuidado (não pode trocar depois
  de inscrito), e sobretudo o processo de pitch deck — reduzir de 13 para 9
  lâminas, nunca inventar número sem fonte citada na própria lâmina, marcar
  o que ainda não está fechado como "RASCUNHO" em vez de chutar, e manter a
  prova visual do produto (screenshots reais) como as lâminas mais valiosas
  do deck.
- Pipeline técnico de exportação do deck: HTML → PDF via Playwright,
  cuidado com breakpoints `@media` (usar `@media screen` para não colidir
  com o layout de impressão/paginação).

## Momentum

`/home/eltobsjr/dev/pessoal/Momentum`

- Só como referência de design-system e execução rápida de handoff visual
  (18 telas em HTML → Flutter). A mecânica RPG completa (stats de
  Força/Resistência/Agilidade) é overkill para o nosso escopo — não
  reaproveitar a progressão de personagem, só o método de trabalho a partir
  de um handoff de design.

## sistema de presença

`/home/eltobsjl/dev/pessoal/sistema de presença`

- Padrão de import CSV via Edge Function (Plano 3: Admin CRUD + Import CSV) —
  útil se precisarmos carregar em lote uma lista de bairros/pontos de rede
  da concessionária, em vez de cadastro manual um por um.

## Não relevantes para este projeto

`extensoes/` (extensões de navegador), `sheep/` (leitor de mangá/novel),
`homies/`, `template-tres-temas/` (poderia servir de base pra uma landing
page pública de divulgação da campanha, mas não é prioridade antes da
submissão do PDF).
