# 2026-09-19 — Documento de submissão, IA em produção, seed de Teresina e rate limit

## O que foi feito

1. **Documento de submissão escrito e enviado.** Rascunho em
   `submissao/Documento de Submissão - SISAN.md` (8 seções do edital, resumo
   de 260 palavras), PDF gerado a partir dele. Equipe: Elto Borges dos Santos
   Junior (líder designado), Kassio de Sousa Dias, Evillyn Kelle Ibiapina
   Costa — ADS, IFPI campus Picos. Só 4 números de terceiros, todos com fonte
   consultada em 18/09 (Lei 14.026/2020, IAS/SNIS-SINISA, Águas do Piauí,
   ONU News). O PDF enviado trata a IA como entregue (decisão do usuário) e
   diz "dois provedores em cascata" — **hoje só o Groq está ativo**.
   Inscrição: hackathon.cidadeverde.com (inscrição e envio no mesmo
   formulário, PDF no modelo da organização).

2. **`classify-ocorrencia` (IA) em produção.** Edge Function + trigger
   `trg_classificar_ocorrencia` (pg_net, mesmo padrão da `notify-push`,
   segredo compartilhado `NOTIFY_INTERNAL_SECRET`). Só tipo e descrição vão
   pro prompt; nunca reclassifica; falha de IA não afeta o fluxo. Camada
   `_shared/provider.ts` com Groq (tenta `llama-3.3-70b-versatile` →
   `openai/gpt-oss-20b` → `llama-3.1-8b-instant`; o primeiro deu
   `model_not_found` nesta conta). Gemini fica como fallback futuro (uma
   linha em `CALLERS`) — sem chave por enquanto.

3. **`insight-dashboard` (IA) em produção.** RPC `insight_agregados()`
   (só gestor, agregados anônimos: tipo/urgência/bairro/reincidência), cache
   por município+período com hash dos agregados (`insights_dashboard`),
   rate limit de 10 gerações/h por gestor, `verify_jwt: true`. Card
   `InsightCard` no dashboard do gestor, com falha contida no próprio card.

4. **Rate limit.** `fn_check_rate_limit` (fork do 032 do SIGAU) aplicado na
   policy de INSERT de ocorrências: 10/hora e 30/dia por usuário. Testado:
   12 tentativas → 10 passam. O advisor apontou que qualquer autenticado
   podia gastar a cota de outro com chave forjada; corrigido exigindo que a
   chave termine com o próprio `auth.uid()` (migration
   `20260919160000_rate_limit_key_ownership.sql`).

5. **Seed de Teresina** (`supabase/seed/seed_demo_teresina.sql`, com
   placeholder de senha — a real não vai pro repositório): município
   Teresina (Águas de Teresina), 2 gestores, 3 técnicos, 4 cidadãos
   (`*.teresina@sisan.dev`), 65 ocorrências fictícias em 6 meses
   (6→8→10→12→15→14, com clusters de esgoto perto de escola no Dirceu
   Arcoverde / Santa Maria da Codipi / Mocambinho), ordens de serviço em
   todos os estados, 6 alertas (4 ativos), 29 notificações. Logins testados.
   Sem fotos (não há imagens no storage).

6. **Tela "Meu município"** do gestor: dados do município, contagem de
   equipe e código de ativação de equipe, com "gerar novo" (RPCs
   `meu_municipio_staff` / `regenerar_codigo_ativacao_staff`, gestor-only,
   rate limit de 5 trocas/h).

## Decisões

- **Campanhas educativas fora do escopo** por ora (pedido do usuário). O PDF
  ainda cita campanhas como etapa da fase seguinte.
- **OneSignal fica com o Kassio** (criar app, `ONESIGNAL_APP_ID` no `.env`,
  `ONESIGNAL_REST_API_KEY` como secret).
- **Credenciais nunca compartilhadas entre projetos** e nunca em arquivo do
  repositório: chave do Groq só como secret do projeto no Dashboard.
- **Bucket `ordens-fotos` desnecessário**: as fotos do "depois" já vão pro
  `ocorrencias-fotos` (pendência era só da documentação).

## Pendências abertas

- [ ] OneSignal (Kassio).
- [ ] Chave do Groq foi colada no chat: **revogar e gerar outra**, colando
      direto no Dashboard.
- [ ] Teste dos 3 perfis num aparelho real e da fila offline em modo avião.
- [ ] Gemini como fallback (precisa de chave) — o PDF já cita dois provedores.
- [ ] `spatial_ref_sys` sem RLS: a tabela é do `supabase_admin`, o
      `postgres` não consegue alterar; a saída é mover o PostGIS pra outro
      schema (destrutivo) — deixar pra depois de 23/09.
- [ ] `validar_codigo_ativacao_staff` é executável por `anon` sem rate limit
      (herdado): possível força bruta do código de 8 hex.
- [ ] Limites de tamanho/mime no bucket `ocorrencias-fotos`.
- [ ] Ligar "Leaked password protection" no Auth.
