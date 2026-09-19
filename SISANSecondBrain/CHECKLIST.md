# Checklist — SISAN

## Bloqueante para a submissão (23/09/2026)

- [x] Nomes da equipe: **Elto, Kassio e Evillyn** (3/5, dentro do exigido)
- [x] Curso e instituição: ADS / IFPI campus Picos (os 3), nomes completos no documento
- [x] Líder designado: **Elto** (confirmado em 18/09)
- [ ] Decidir se busca um 4º/5º integrante pra multidisciplinaridade
      (edital incentiva mas não exige) ou segue só com os 3 de ADS/TI
- [x] Nome definitivo do projeto: **SISAN** (ver `decisions/007`) — falta só
      a identidade visual simples pro pitch (nome + 1 frase + ícone)
- [x] Documento de submissão escrito e **enviado em 19/09** (`submissao/`)
- [x] Formulário oficial: hackathon.cidadeverde.com (inscrição e envio no mesmo formulário, PDF no modelo da organização)

## Técnico (se decidirmos ter protótipo funcional para o pitch)

- [x] Scaffold Flutter + Supabase (ver `prioridade/atual.md`)
- [x] Fork de `ocorrencias` (ex-`denuncias` do SIGAU)
- [x] Fork de `ordens_de_servico` (ex-`resgates` do SIGAU + checklist do Confia)
- [x] Dashboard básico (KPIs + mapa) pro gestor
- [x] Edge Function `classify-ocorrencia` (IA, padrão polimata-concursos)
- [x] Edge Function `insight-dashboard` (resumo executivo por IA)

## Pendências abertas (responsável: Kassio, salvo indicação)

Detalhe e ordem em `prioridade/atual.md`. Resumo: setup do OneSignal, trocar a
chave do Groq (foi colada no chat), teste dos 3 perfis num aparelho real e da
fila offline, Gemini como fallback, hardening de segurança. A decisão sobre
um 4º/5º integrante é da equipe; convidar Kassio e Evillyn no Supabase/GitHub
é do Elto.

## Decisões já tomadas

- [x] Escopo do protótipo: os 3 perfis ponta a ponta (`decisions/010`)
