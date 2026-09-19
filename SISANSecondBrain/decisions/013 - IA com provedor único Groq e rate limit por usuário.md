---
data: 2026-09-19
status: aprovado
---

# 013 — IA só com Groq por enquanto, e rate limit por usuário

**Contexto:** a `decisions/004` previa Groq com Gemini de fallback. Na hora de
implementar (19/09), o Gemini não tinha chave disponível ("tá parado"), e o
usuário decidiu seguir só com o Groq. Ao mesmo tempo, as escritas mais
expostas a abuso (criar ocorrência, gerar insight, trocar código de equipe)
precisavam de limite por usuário.

**Decisão:**
1. `supabase/functions/_shared/provider.ts` expõe `generateStructured(params,
   validate, providers)` com uma tabela `CALLERS`. Hoje só há `groq`. Ligar o
   Gemini é implementar `callGemini`, registrá-lo em `CALLERS` e passar
   `["groq","gemini"]` — os chamadores não mudam.
2. No Groq, a função tenta uma lista de modelos e segue pro próximo em
   `404 model_not_found` (`llama-3.3-70b-versatile` → `openai/gpt-oss-20b` →
   `llama-3.1-8b-instant`), porque nem todo modelo está liberado em toda conta
   (aconteceu com o primeiro nesta conta).
3. Rate limit: tabela `rate_limit_hits` + `fn_check_rate_limit(chave, máx,
   janela)` (fork do `032_rate_limiting` do SIGAU). Limites: ocorrências 10/h
   e 30/dia por usuário (na policy de INSERT), insight 10/h por gestor (só em
   cache miss), troca de código de equipe 5/h.
4. A chave de rate limit **precisa terminar com o `auth.uid()` do chamador**
   (migration `rate_limit_key_ownership`). Sem isso, qualquer usuário logado
   poderia gastar a cota de outro chamando a RPC com uma chave forjada (achado
   do advisor + teste em 19/09).
5. Chaves de API só como secrets do projeto Supabase, colados por quem as
   criou direto no Dashboard. Nenhuma credencial de outro projeto é reusada.

**Motivo:** entregar a IA no prazo sem depender de uma chave que não existe,
mantendo o ponto de extensão barato; e impedir que o limite vire vetor de
negação de serviço.

**Impacto:**
- O PDF de submissão (enviado em 19/09) fala em "dois provedores em cascata";
  hoje é só o Groq. Até o Gemini ser ligado, a resposta honesta é "Groq
  principal, Gemini previsto".
- A chave do Groq foi colada no chat em 19/09: deve ser revogada e trocada.

**Não fazer:** não voltar a chamar o provedor de IA a cada abertura do
dashboard (o cache por hash existe pra isso); não mandar nome, e-mail,
coordenada ou texto livre de relato pro `insight-dashboard` (só agregados);
não expor chave de IA no cliente Flutter.
