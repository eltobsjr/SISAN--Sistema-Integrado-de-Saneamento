-- Endurece fn_check_rate_limit: como a função é executável por qualquer
-- usuário autenticado (a policy de INSERT em ocorrencias roda com os
-- privilégios de quem chama), um usuário poderia gastar a cota de OUTRO
-- chamando-a com a chave 'ocorrencia_h:<uuid da vítima>'. Agora, quando há
-- usuário logado, a chave precisa terminar com o próprio auth.uid().
-- service_role (auth.uid() nulo) continua livre pra chaves de sistema.
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
  v_uid   uuid := auth.uid();
begin
  if v_uid is not null and right(p_key, 36) is distinct from v_uid::text then
    raise exception 'Chave de rate limit inválida.' using errcode = '42501';
  end if;

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
