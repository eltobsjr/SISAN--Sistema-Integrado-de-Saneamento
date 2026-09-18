-- Fase 3: infraestrutura pra push real. pg_net permite chamar a Edge
-- Function notify-push de dentro de um trigger, sem bloquear a transação
-- que gerou a notificação (net.http_post é assíncrono).
create extension if not exists pg_net;

-- Segredo compartilhado entre o trigger (abaixo, em
-- 20260918140010_notify_push_trigger.sql) e a Edge Function notify-push.
-- Sem isso, qualquer detentor da anon key (que é pública) poderia chamar a
-- função diretamente e forçar push arbitrário pra qualquer usuário.
select vault.create_secret(
  encode(extensions.gen_random_bytes(32), 'hex'),
  'notify_internal_secret',
  'Segredo interno entre triggers Postgres (net.http_post) e a Edge Function notify-push'
)
where not exists (
  select 1 from vault.decrypted_secrets where name = 'notify_internal_secret'
);
