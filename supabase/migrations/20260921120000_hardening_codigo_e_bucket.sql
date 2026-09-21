-- Hardening pré-submissão (prioridade/atual.md, item "Hardening").
--
-- 1) validar_codigo_ativacao_staff é chamável sem login (o cadastro valida o
--    código ANTES do signUp), então dava pra testar os 4 bilhões de códigos
--    de 8 hex sem limite. Agora: 10 tentativas por IP a cada 10 min e 30 por
--    município por hora (teto global mesmo trocando de IP).
--    Não usa fn_check_rate_limit porque ela exige chave terminando no
--    auth.uid() quando há sessão; aqui a chave é IP/município. Usa a mesma
--    tabela rate_limit_hits, direto (a função é SECURITY DEFINER).
--
-- 2) Bucket ocorrencias-fotos sem limite de tamanho nem tipo. O app envia
--    fotos com imageQuality 80-85 (~2 MB); 10 MB dá folga. O storage_client
--    deduz o mime pela extensão do caminho, e o app usa a extensão da foto
--    escolhida (jpg/jpeg/png/heic/webp) ou .jpg fixo no fluxo offline.

create or replace function public.validar_codigo_ativacao_staff(p_municipio_id uuid, p_codigo text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_headers jsonb := coalesce(nullif(current_setting('request.headers', true), '')::jsonb, '{}'::jsonb);
  v_ip      text  := coalesce(split_part(v_headers->>'x-forwarded-for', ',', 1), 'desconhecido');
  v_chaves  text[] := array['codigo_staff_ip:' || v_ip, 'codigo_staff_mun:' || p_municipio_id::text];
  v_limites int[]  := array[10, 30];
  v_janelas int[]  := array[600, 3600];
  i int;
begin
  for i in 1..2 loop
    delete from public.rate_limit_hits
     where rl_key = v_chaves[i]
       and criado_em < now() - make_interval(secs => v_janelas[i]);
    if (select count(*) from public.rate_limit_hits where rl_key = v_chaves[i]) >= v_limites[i] then
      raise exception 'Muitas tentativas de código. Aguarde alguns minutos e tente de novo.'
        using errcode = 'P0001';
    end if;
  end loop;

  insert into public.rate_limit_hits (rl_key) select unnest(v_chaves);

  return exists(
    select 1 from codigos_ativacao_staff
     where municipio_id = p_municipio_id and codigo = p_codigo
  );
end;
$$;

update storage.buckets
   set file_size_limit = 10485760,
       allowed_mime_types = array[
         'image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'image/gif'
       ]
 where id = 'ocorrencias-fotos';
