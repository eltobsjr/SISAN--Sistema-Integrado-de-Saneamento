-- Alertas sanitários são staff-only (features/003, CA01) — quando um é
-- criado (manual pelo gestor, ou futuramente automático), notifica
-- técnicos e gestores do município, exceto quem criou o próprio alerta.
create or replace function public.notificar_staff_novo_alerta()
returns trigger
language plpgsql
security definer
set search_path = 'public'
as $$
begin
  insert into public.notificacoes (municipio_id, usuario_id, tipo, titulo, corpo, dados)
  select
    new.municipio_id,
    u.id,
    'alerta_sanitario',
    'Novo alerta sanitário',
    new.descricao,
    jsonb_build_object('alerta_sanitario_id', new.id)
  from public.usuarios u
  where u.municipio_id = new.municipio_id
    and u.perfil in ('tecnico', 'gestor')
    and u.ativo
    and u.id <> new.criado_por;
  return new;
end;
$$;

revoke all on function public.notificar_staff_novo_alerta() from public;
revoke all on function public.notificar_staff_novo_alerta() from anon;
revoke all on function public.notificar_staff_novo_alerta() from authenticated;

drop trigger if exists trg_notificar_staff_novo_alerta on public.alertas_sanitarios;
create trigger trg_notificar_staff_novo_alerta
  after insert on public.alertas_sanitarios
  for each row
  execute function public.notificar_staff_novo_alerta();
