-- Tela "Meu município" do gestor: ver os dados do município e o código de
-- ativação de equipe (o que técnicos/gestores digitam no cadastro), e
-- regenerar o código quando ele vazar. A tabela codigos_ativacao_staff não
-- tem policy de propósito (ninguém lê direto); o acesso é só por estas RPCs.

create or replace function public.meu_municipio_staff()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_mun uuid := auth_municipio_id();
begin
  if auth_perfil() is distinct from 'gestor' then
    raise exception 'Acesso restrito a gestor.' using errcode = '42501';
  end if;

  return (
    select jsonb_build_object(
      'nome', m.nome,
      'estado', m.estado,
      'concessionaria', m.concessionaria::text,
      'codigo_ativacao', c.codigo,
      'codigo_atualizado_em', c.atualizado_em,
      'gestores', (select count(*) from usuarios where municipio_id = m.id and perfil = 'gestor' and ativo),
      'tecnicos', (select count(*) from usuarios where municipio_id = m.id and perfil = 'tecnico' and ativo),
      'cidadaos', (select count(*) from usuarios where municipio_id = m.id and perfil = 'cidadao' and ativo)
    )
    from municipios m
    left join codigos_ativacao_staff c on c.municipio_id = m.id
    where m.id = v_mun
  );
end;
$$;

create or replace function public.regenerar_codigo_ativacao_staff()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_mun    uuid := auth_municipio_id();
  v_codigo text := substr(md5(random()::text || clock_timestamp()::text), 1, 8);
begin
  if auth_perfil() is distinct from 'gestor' then
    raise exception 'Acesso restrito a gestor.' using errcode = '42501';
  end if;
  if not fn_check_rate_limit('regen_codigo:' || auth.uid()::text, 5, 3600) then
    raise exception 'Muitas trocas de código seguidas. Tente novamente mais tarde.' using errcode = '54000';
  end if;

  update codigos_ativacao_staff
     set codigo = v_codigo, atualizado_em = now()
   where municipio_id = v_mun;
  if not found then
    insert into codigos_ativacao_staff (municipio_id, codigo) values (v_mun, v_codigo);
  end if;
  return v_codigo;
end;
$$;

revoke all on function public.meu_municipio_staff() from public;
revoke all on function public.meu_municipio_staff() from anon;
grant execute on function public.meu_municipio_staff() to authenticated;

revoke all on function public.regenerar_codigo_ativacao_staff() from public;
revoke all on function public.regenerar_codigo_ativacao_staff() from anon;
grant execute on function public.regenerar_codigo_ativacao_staff() to authenticated;
