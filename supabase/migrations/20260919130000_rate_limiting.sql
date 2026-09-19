-- Rate limiting genérico por chave (usuário + escopo), fork do 032 do SIGAU.
-- Aplicado ao INSERT de ocorrências (a escrita pública mais exposta a abuso)
-- e disponível por RPC pras Edge Functions chamadas por usuário logado.

create table if not exists public.rate_limit_hits (
  id        bigint generated always as identity primary key,
  rl_key    text not null,
  criado_em timestamptz not null default now()
);

create index if not exists idx_rate_limit_hits_key_criado
  on public.rate_limit_hits (rl_key, criado_em desc);

alter table public.rate_limit_hits enable row level security;
-- Sem policy de propósito: só acessível pela função SECURITY DEFINER abaixo.

-- Registra uma tentativa pra `p_key` e devolve true se ainda está dentro do
-- limite (`p_max_hits` por janela de `p_window_seconds`), false se excedeu.
-- Limpa os hits expirados da própria chave a cada chamada (sem cron).
create or replace function public.fn_check_rate_limit(
  p_key text,
  p_max_hits int,
  p_window_seconds int
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
begin
  delete from public.rate_limit_hits
   where rl_key = p_key
     and criado_em < now() - make_interval(secs => p_window_seconds);

  select count(*) into v_count from public.rate_limit_hits where rl_key = p_key;
  if v_count >= p_max_hits then
    return false;
  end if;

  insert into public.rate_limit_hits (rl_key) values (p_key);
  return true;
end;
$$;

-- Lição da migration restrict_security_definer_grants: por padrão o Postgres
-- dá EXECUTE a PUBLIC; tira de anon e só devolve pra quem precisa.
revoke all on function public.fn_check_rate_limit(text, int, int) from public;
revoke all on function public.fn_check_rate_limit(text, int, int) from anon;
grant execute on function public.fn_check_rate_limit(text, int, int) to authenticated, service_role;

-- ── ocorrencias ─────────────────────────────────────────────────────────────
-- Máximo 10 ocorrências por hora e 30 por dia por usuário autenticado.
drop policy if exists ocorrencias_insert on public.ocorrencias;
create policy ocorrencias_insert on public.ocorrencias
  for insert to authenticated
  with check (
    municipio_id = auth_municipio_id()
    and denunciante_id = (select auth.uid())
    and fn_check_rate_limit('ocorrencia_h:' || (select auth.uid())::text, 10, 3600)
    and fn_check_rate_limit('ocorrencia_d:' || (select auth.uid())::text, 30, 86400)
  );
