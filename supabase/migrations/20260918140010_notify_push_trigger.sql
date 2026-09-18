-- Dispara a Edge Function notify-push a cada INSERT em notificacoes
-- (cobre nova_os, status_os e alerta_sanitario — qualquer tipo futuro
-- inserido nessa tabela já ganha push de graça, sem trigger dedicado).
create or replace function public.enviar_push_notificacao()
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
    url := 'https://gzoosgugbgbtcrjhfoot.supabase.co/functions/v1/notify-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-notify-secret', v_secret
    ),
    body := jsonb_build_object(
      'id', new.id,
      'usuario_id', new.usuario_id,
      'tipo', new.tipo,
      'titulo', new.titulo,
      'corpo', new.corpo,
      'dados', new.dados
    )
  );
  return new;
end;
$$;

revoke all on function public.enviar_push_notificacao() from public;
revoke all on function public.enviar_push_notificacao() from anon;
revoke all on function public.enviar_push_notificacao() from authenticated;

drop trigger if exists trg_enviar_push_notificacao on public.notificacoes;
create trigger trg_enviar_push_notificacao
  after insert on public.notificacoes
  for each row
  execute function public.enviar_push_notificacao();
