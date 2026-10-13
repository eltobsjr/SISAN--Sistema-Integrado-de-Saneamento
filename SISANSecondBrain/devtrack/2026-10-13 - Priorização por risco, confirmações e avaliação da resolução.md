---
data: 2026-10-13
---

# 13/10: priorização por risco, confirmações e avaliação da resolução

Revisão crítica do app na véspera da gravação (14/10), seguida das correções.

## Problemas encontrados

1. **"Prioridades de hoje" filtrava só as 5 ocorrências mais recentes**
   (`stats.ultimasOcorrencias`). Um caso grave mais antigo sumia do painel.
2. **A classificação da IA ficava invisível.** `risco_saude` não aparecia em
   nenhuma tela, e nada mostrava que a urgência vinha da IA.
3. **"Risco à saúde" com dois sentidos:** valor de `urgencia` e coluna
   `risco_saude`. Na interface, agora é "Urgência" e "Nível de risco".
4. **O gestor não conseguia corrigir a IA.**
5. **Denúncias duplicadas** do mesmo problema viravam várias OS.
6. **Sem retorno do cidadão** depois da conclusão da OS.
7. A linha do tempo da ocorrência mostrava "Arquivada" como etapa depois de "Resolvida".

## Feito

### Banco (MCP `supabase-sisan`, projeto `gzoosgugbgbtcrjhfoot` conferido)

- `20261013120000_priorizacao_confirmacoes_avaliacao.sql`:
  - colunas `confirmacoes`, `classificacao_manual`, `avaliacao_cidadao`,
    `avaliado_em`; check em `risco_saude`; índice GiST em `localizacao`
  - tabela `ocorrencia_confirmacoes` com RLS (select só das próprias; escrita só via RPC)
  - campo computado `prioridade(ocorrencias)` (0 a 120): urgência 0/25/50 +
    nível de risco 0/10/20 + 3 por confirmação (teto 30) + 2 por dia em aberto (teto 20).
    O PostgREST lê com `select=*,prioridade`, inclusive no join da OS
  - RPCs `prioridades_abertas`, `ocorrencias_proximas` (PostGIS, 80 m, mesmo tipo),
    `confirmar_ocorrencia` (rate limit 20/h), `reclassificar_ocorrencia` (só gestor),
    `avaliar_resolucao`, `evidencias_resolucao`
- `20261013120100_reabrir_os_na_avaliacao.sql`: existe o índice único
  `ordens_servico_ocorrencia_idx` (uma OS por ocorrência). Por isso "não resolveu" **não cria OS nova**:
  devolve a mesma OS para a fila (sem técnico, checklist e fotos zerados) e avisa os técnicos.
  Reaberta e concluída de novo, o cidadão avalia outra vez.
- Testado por SQL simulando cidadão, gestor e denunciante (transação desfeita no
  fim) e via REST com o login do gestor. Advisors: nada novo exposto para `anon`.

### App

- `OcorrenciaRisco` (novo enum) e campos novos em `Ocorrencia`; mapeamento único
  `OcorrenciaSupabaseDatasource.fromMap` (a OS reaproveita; antes era duplicado).
- `ClassificacaoCard`: origem (IA / corrigida pelo gestor / aguardando), urgência,
  nível de risco, confirmações e prioridade. Botão "Corrigir" para o gestor. Aparece no
  detalhe da ocorrência e da OS.
- Painel: "Prioridades de hoje" vem de `prioridadesAbertasProvider` (município inteiro).
- Fila do técnico, lista de OS e casos críticos do gestor ordenados pela pontuação.
- Nova ocorrência: ao sair da etapa "Local", busca relatos próximos do mesmo tipo e
  oferece confirmar em vez de duplicar. Offline ou com erro, segue normal.
- Detalhe da ocorrência: o cidadão vê as fotos do reparo e responde "resolveu?".
- `OcorrenciaCard` mostra confirmações e prioridade.

## Verificação

- `flutter analyze` sem problemas, `flutter test` passando, `flutter build web` ok.
- As telas foram conferidas na build web (prints da seção seguinte). **No celular, ainda não.**

## Segurança: senha de demo no repositório público

O repositório no GitHub é **público** e dois docs (devtrack de 09/10 e
`cronograma-finalistas.md`) traziam a senha das contas de demo. Ela foi trocada
por "senha de demo (fora do repositório)" antes do push, mas **continua no
histórico do git**: trocar a senha depois da gravação é obrigatório.

## Commits (todos com push na `main`)

| Commit | Conteúdo |
|---|---|
| `0637104` | Trabalho pendente de 09/10: refinamento visual, gráficos, pitch, seed de fontes públicas |
| `152fec6` | Priorização por risco, confirmações, correção da IA e avaliação da resolução |
| `7ae5c28` | Deck com prints novos e redesign, roteiro de 8 slides, texto da fila do técnico |

## Deck do pitch refeito

Artifact (mesmo link): https://claude.ai/artifact/LDsDaXDDRChhshc9YHrMRw (versão 13).
Cópia no vault: `submissao/apresentacao/` (ver o README de lá).

- **Prints novos** de 13/10, 17 telas dos 3 perfis, capturados da build web com
  Playwright (scripts em `submissao/apresentacao/captura/`). Durante a captura
  nada foi salvo no banco: os painéis de confirmação e correção foram abertos e fechados.
- **Visual novo:** Bricolage Grotesque e DM Sans; azul-noite `#0B2235`, papel
  `#F4F2EC` e âmbar `#F3A43F` (risco e prioridade); telas em moldura de celular.
  Gerado por `submissao/apresentacao/gerar.py`.
- **Pitch com 8 slides:** capa, cenário, solução, app, **prioridade** (novo: os
  até 120 pontos ao lado do painel real), mapa (com a confirmação de relato
  próximo), abordagem e fim (com os nomes da equipe e a tela de avaliação).
- **Apêndice:** "E se a IA errar?" (novo), jornada em 6 passos (registro →
  confirmação → triagem pela IA → campo → painel → avaliação), mais perfis, dados,
  fontes e próximo passo.
- **App:** a fila do técnico dizia "Ordenada por urgência e antiguidade"; agora
  diz "Ordenada pela pontuação de risco sanitário" (e "por prioridade de risco"
  na lista de OS).

## Roteiro e PDFs

- `submissao/roteiro-pitch-2min.md` refeito para 8 slides em 2 minutos, com A e B
  (Elto e Évillyn), perguntas prováveis e a regra de não prometer push na demo.
- PDFs em `submissao/apresentacao/pdf/`:
  - `SISAN-pitch.pdf`: só os 8 slides do pitch, sem o apêndice, a 1920×1080.
    Montado localmente (`pdf.py` e Chrome), não pela exportação do Artifact; as
    `x-icon` e as setas viraram SVG. Diferença visível: o card "Gestor" do slide 3
    ficou um pouco mais baixo que os outros.
  - `SISAN-roteiro-pitch-2min.pdf`: roteiro em uma página A4 (`roteiro.html`).
- **Enviados à Évillyn pelo WhatsApp** (número passado pelo Elto, fora do
  repositório por ser público), com uma mensagem explicando os arquivos. O número
  não estava nos contatos; confirmar com ela se chegou.

## Pendências

- Conferir as telas novas no celular (painel do gestor, detalhe da OS, fluxo de confirmação).
- Trocar a senha das contas de demo depois da gravação (está no histórico público).
- Indicadores de outubro quase zerados no painel ("1 ocorrência no mês"), porque o seed vai até setembro.
- Slide final sem sobrenomes e sem contatos.
- Herdadas: OneSignal (push não dispara sem ele; o responsável era o Kassio),
  Gemini como fallback (descartado em 21/09; o PDF da submissão cita dois provedores).
- Pitch: a resposta para "e se a IA errar?" agora é "o gestor corrige, e a correção muda a fila".
