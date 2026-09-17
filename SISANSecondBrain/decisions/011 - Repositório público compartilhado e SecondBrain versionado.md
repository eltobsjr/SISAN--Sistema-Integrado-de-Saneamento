---
data: 2026-09-17
status: aprovado
---

# 011 — Repositório no GitHub, SecondBrain versionado (não gitignorado)

**Contexto:** projeto agora é trabalho em grupo — Elto, Kassio e Evillyn.
Usuário forneceu o repositório `eltobsjr/SISAN--Sistema-Integrado-de-Saneamento`
(GitHub, **público**, vazio) e pediu explicitamente para subir também o
vault `SISANSecondBrain/` nele, para os três terem acesso à mesma
documentação viva.

**Decisão:** ao contrário da convenção dos outros projetos do usuário
(Confia, Momentum, Polymata, SIGAU — onde o `*SecondBrain/` é sempre
git-ignorado por ser documentação pessoal de um dev solo), aqui o
`SISANSecondBrain/` **é versionado e compartilhado**. `.gitignore` reescrito
para excluir apenas segredos (`.env`) e artefatos de build do Flutter, sem
excluir o vault.

**Motivo:** com 3 pessoas trabalhando no mesmo projeto num prazo de 6 dias,
decisões/specs/roadmap centralizados e sincronizados via git é mais robusto
do que cada um manter sua própria cópia local de memória.

**Impacto:** `.gitignore`. Nenhuma credencial (Supabase, OneSignal, etc.)
pode aparecer em nenhum arquivo do vault — o repositório é público. Ver
`decisions/012` sobre o tratamento das credenciais do Supabase.

**Não fazer:** não colar chave nenhuma (nem anon key, que é pública mas
ainda assim deve morar só em `.env`/config, por hábito consistente) direto
em arquivo `.md` do vault. Nunca comitar `.env`.
