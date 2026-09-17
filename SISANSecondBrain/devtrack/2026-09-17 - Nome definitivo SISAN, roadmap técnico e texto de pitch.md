# 2026-09-17 — Nome definitivo SISAN, roadmap técnico e texto de pitch

> Continuação da mesma data do devtrack "Setup do SecondBrain e mapeamento
> de reaproveitamento" — sessão longa, registrada em duas entradas por
> distinção de assunto.

## O que foi feito

### Idas e vindas sobre o uso de IA no sistema
Usuário pediu pra desconsiderar a ideia de Edge Functions de IA
(`classify-ocorrencia`) — decisão 004 marcada como adiada, feature 006
movida pra backlog e reescrita em torno de duas ideias novas (resumo
executivo do dashboard e detecção de duplicidade), CLAUDE.md/prioridade/
CHECKLIST ajustados pra remover IA do escopo. Perguntado onde IA faria
sentido de fato: recomendação dada foi um **resumo executivo do dashboard do
gestor** gerado por IA (fora do caminho crítico, ataca os eixos
Saúde/Sustentabilidade) como prioridade, com detecção de duplicidade como
ideia secundária.

Usuário então esclareceu que gostou da ideia original de classificação
**também** — pediu pra reverter tudo ao estado anterior ao pedido de
desconsiderar. Revertido: `decisions/004` voltou a "aprovado", cobrindo
agora **duas** Edge Functions de IA (`classify-ocorrencia` e
`insight-dashboard`), `features/006` restaurada com o conteúdo original de
classificação, `features/008` criada com o resumo executivo do dashboard
como feature própria (não descartada, só remunerada). CLAUDE.md,
`prioridade/atual.md` e `CHECKLIST.md` atualizados para refletir as duas
funções ativas no escopo.

**Lição registrada:** perguntas exploratórias tipo "onde você usaria X"
podem gerar uma sugestão nova que o usuário quer **somar**, não substituir a
ideia original — não presumir que uma sugestão alternativa cancela a
anterior sem confirmação explícita.

### Texto de pitch em 3 parágrafos
A pedido do usuário, escrito um texto corrido (não bullet) apresentando a
ideia com foco no mapa em tempo real (mesma peça central do SIGAU) — cidadão
denuncia, mapa atualiza na hora colorido por urgência, técnico vê o que está
perto dele, gestor lê o mapa de calor do mês, e a Edge Function de insight
transforma o padrão geográfico em frase de prioridade. Entregue só na
conversa, ainda não persistido em nenhum arquivo do vault — considerar
incorporar ao resumo executivo do `features/007` quando escrito.

### Roadmap técnico completo
Criado `Roadmap.md` na raiz do vault, no mesmo formato usado no Confia
(tabela de fases com "o que você consegue testar no final" + spec linkada).
7 fases (0-6) cobrindo fundação, ocorrências, ordens de serviço, mapa e
notificações, dashboard e alertas sanitários, IA, campanhas e polimento —
cada uma com as migrations exatas, o que reaproveitar de qual projeto e o
que não fazer (puxado do catálogo de erros herdados do SIGAU). Inventário
técnico consolidado no fim: 12 migrations em ordem, 7 Edge Functions, 6
enums, lista completa de dependências do `pubspec.yaml`.

### Nome definitivo: SISAN
Apresentadas opções de nome em 3 estilos (sigla técnica, memorável/curto,
ligado à marca do edital) — usuário escolheu **SISAN** (Sistema Integrado de
Saneamento). Executada renomeação completa:
- Pasta do projeto: `sigesan/` → `sisan/`
- Vault: `SIGESANSecondBrain/` → `SISANSecondBrain/`
- Memória do Claude Code: `~/.claude/projects/-home-eltobsjr-dev-pessoal-sigesan/` → `.../-home-eltobsjr-dev-pessoal-sisan/`
- Todas as ocorrências de "SIGESAN"/"sigesan" substituídas por "SISAN"/"sisan"
  em todo arquivo do projeto e da memória (`find -print0` + `sed`, cuidado
  extra por causa de nomes de arquivo com espaço/travessão)
- `decisions/001` (nome provisório) renomeada com sufixo `(superseded)` e
  preservada como histórico; `decisions/007` criada registrando a decisão
  final
- Expansão do nome ajustada na Visão Geral: "Sistema Integrado de
  Saneamento" (sem "Gestão", pra bater com as 5 letras de SISAN)
- `CHECKLIST.md` atualizado — nome deixou de ser pendência

**Nota técnica:** primeira tentativa de substituição em lote com `for f in
$FILES` (sem quote) falhou silenciosamente por causa de nomes de arquivo com
espaço (ex.: "SISAN — Visão Geral.md") — corrigido com
`find ... -print0` + `while IFS= read -r -d ''`. Verificado com grep no fim
que zero ocorrências do nome antigo restaram.

## Pendências (sem mudança desde o devtrack anterior)

- [ ] Nomes, curso/instituição e vínculo de todos os integrantes da equipe
- [ ] Escrever o documento de submissão completo (`features/007`)
- [ ] Identidade visual (cor, ícone, tagline) — próxima discussão da sessão
- [ ] Escopo do protótipo pro pitch (mockup vs. funcional) — próxima discussão

## Próximos passos

1. Discutir identidade visual e as demais decisões em aberto (equipe,
   município piloto pro pitch, escopo do protótipo) — perguntas com
   alternativas a apresentar na sequência desta sessão
2. Escrever `features/007` (documento de submissão)
3. Scaffold Flutter + Supabase (Fase 0 do Roadmap)
