---
data: 2026-09-19
status: aprovado e aplicado em 19/09/2026
---

# 014 — Mover o PostGIS para o schema `extensions`

**Contexto:** o advisor de segurança do Supabase acusa `public.spatial_ref_sys`
sem RLS (nível ERROR) e "extension in public". A tabela e a extensão
pertencem ao `supabase_admin`; o role `postgres` (o do MCP e do SQL Editor do
Dashboard) recebe `must be owner of table` em `ENABLE ROW LEVEL SECURITY` e o
`REVOKE` não tem efeito. Enquanto isso, `anon` e `authenticated` têm
INSERT/UPDATE/DELETE/TRUNCATE nessa tabela de referência do PostGIS.

**Decisão:** recriar o PostGIS em `extensions` (schema que a API REST não
expõe), com o script `supabase/manual/2026-09-19_mover_postgis_para_
extensions.sql`. Só quatro colunas dependem dele (`municipios.centro` e as
geradas `centro_latitude`/`centro_longitude`, mais `ocorrencias.localizacao`)
e todas são reconstruíveis (o centro é salvo antes; a localização vem de
`latitude`/`longitude`). O trigger `fn_ocorrencia_localizacao` ganha
`search_path = public, extensions`.

**Aplicado (19/09):** o Elto rodou o script no SQL Editor do Dashboard. A
primeira versão (BEGIN/COMMIT + tabela temporária `ON COMMIT DROP`) foi
executada pelo editor em lotes separados: os passos de 1 a 6 foram
confirmados e a validação final falhou com `42P01` (a tabela temporária já
não existia) — **sem perda de dado**, conferido no banco (centros dos 2
municípios, 66/66 localizações, trigger com `search_path = public,
extensions`). O advisor deixou de acusar `rls_disabled_in_public` e a
extensão postgis em `public`. O script foi reescrito como **um único bloco
`DO`** (atômico em qualquer editor) e retestado com rollback.

**Validação prévia (19/09):** o script inteiro foi executado numa transação com
rollback forçado: as validações internas passaram, o centro de Teresina foi
preservado, e o trigger continuou preenchendo `localizacao` para um usuário
`authenticated`. O banco ficou intacto depois (PostGIS ainda em `public`).

**Motivo:** é a única saída disponível para o role `postgres`, é a
recomendação do próprio Supabase e não muda nada no app (que só lê
`centro_latitude/longitude` e `latitude/longitude`).

**Impacto:** trava `municipios` e `ocorrencias` por alguns segundos —
rodar fora de demo. `pg_net` também aparece como "extension in public", mas
não é relocável e mexer nele derrubaria a fila do push; fica como está.
Um projeto novo que reaplique as migrations do zero recria o PostGIS em
`public` (a migration `enable_postgis` não foi alterada).

**Não fazer:** não rodar o script durante uma demo; não usar `DROP EXTENSION`
avulso sem o passo de backup do centro dos municípios.
