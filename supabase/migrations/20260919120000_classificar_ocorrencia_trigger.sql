-- Fase 5: classificação por IA. A cada INSERT em ocorrencias, chama a Edge
-- Function classify-ocorrencia via pg_net (assíncrono — não atrasa nem
-- derruba o INSERT do cidadão se a IA estiver fora do ar). Reusa o segredo
-- `notify_internal_secret` do Vault, o mesmo da notify-push.
create or replace function public.classificar_ocorrencia()
returns trigger
language plpgsql
security definer
set search_path = 'public'
as $$
declare
  v_secret text;
begin
  select decrypted_secret into v_secret
  from vault.decrypted_secrets
  where name = 'notify_internal_secret';

  if v_secret is null then
    return new;
  end if;

  perform net.http_post(
    url := 'https://gzoosgugbgbtcrjhfoot.supabase.co/functions/v1/classify-ocorrencia',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-notify-secret', v_secret
    ),
    body := jsonb_build_object('id', new.id)
  );
  return new;
end;
$$;

revoke all on function public.classificar_ocorrencia() from public;
revoke all on function public.classificar_ocorrencia() from anon;
revoke all on function public.classificar_ocorrencia() from authenticated;

drop trigger if exists trg_classificar_ocorrencia on public.ocorrencias;
create trigger trg_classificar_ocorrencia
  after insert on public.ocorrencias
  for each row
  execute function public.classificar_ocorrencia();
