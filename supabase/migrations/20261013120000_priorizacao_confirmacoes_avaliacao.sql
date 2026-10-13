-- Priorização por risco sanitário de ponta a ponta (revisão de 13/10/2026):
--
-- 1. Confirmações: outro morador confirma um relato aberto perto dele em vez
--    de abrir uma ocorrência duplicada (busca por raio com PostGIS).
-- 2. Prioridade calculada no banco (campo computado `prioridade`, lido pelo
--    PostgREST como `select=*,prioridade`): urgência + nível de risco à
--    saúde + confirmações + tempo em aberto. Uma fonte só para o painel do
--    gestor e a fila do técnico.
-- 3. Gestor corrige a classificação da IA (`classificacao_manual`).
-- 4. Cidadão avalia a resolução; "não resolveu" reabre com uma OS nova.

-- ─── Colunas ──────────────────────────────────────────────────────────────

alter table public.ocorrencias
  add column if not exists confirmacoes integer not null default 0,
  add column if not exists classificacao_manual boolean not null default false,
  add column if not exists avaliacao_cidadao text
    check (avaliacao_cidadao in ('resolvido', 'nao_resolvido')),
  add column if not exists avaliado_em timestamptz;

alter table public.ocorrencias
  add constraint ocorrencias_risco_saude_check
  check (risco_saude is null or risco_saude in ('baixo', 'medio', 'alto'));

create index if not exists idx_ocorrencias_localizacao
  on public.ocorrencias using gist (localizacao);

-- ─── Confirmações ─────────────────────────────────────────────────────────

create table if not exists public.ocorrencia_confirmacoes (
  ocorrencia_id uuid not null references public.ocorrencias(id) on delete cascade,
  usuario_id uuid not null references public.usuarios(id) on delete cascade,
  criado_em timestamptz not null default now(),
  primary key (ocorrencia_id, usuario_id)
);

alter table public.ocorrencia_confirmacoes enable row level security;

-- Cada um vê só as próprias confirmações; a escrita é só pela RPC.
create policy ocorrencia_confirmacoes_select_proprias
  on public.ocorrencia_confirmacoes for select to authenticated
  using (usuario_id = (select auth.uid()));

create index if not exists idx_ocorrencia_confirmacoes_usuario
  on public.ocorrencia_confirmacoes (usuario_id);

-- ─── Prioridade (campo computado) ─────────────────────────────────────────
-- Até 120 pontos: urgência (0/25/50) + risco (0/10/20) + confirmações
-- (3 por morador, teto 30) + dias em aberto (2 por dia, teto 20).

create or replace function public.prioridade(o public.ocorrencias)
returns integer
language sql
stable
set search_path = public
as $$
  select
    (case o.urgencia when 'risco_saude' then 50 when 'atencao' then 25 else 0 end)
  + (case o.risco_saude when 'alto' then 20 when 'medio' then 10 else 0 end)
  + least(o.confirmacoes, 10) * 3
  + case when o.status in ('pendente', 'em_analise')
      then least(floor(extract(epoch from (now() - o.criado_em)) / 86400)::int, 10) * 2
      else 0
    end;
$$;

-- Abertas do município do usuário, da mais prioritária para a menos.
create or replace function public.prioridades_abertas(p_limite integer default 5)
returns setof public.ocorrencias
language sql
stable
set search_path = public
as $$
  select o.*
  from public.ocorrencias o
  where o.municipio_id = public.auth_municipio_id()
    and o.status in ('pendente', 'em_analise')
  order by public.prioridade(o) desc, o.criado_em asc
  limit greatest(1, least(p_limite, 50));
$$;

-- ─── Relatos próximos (antes de abrir um novo) ────────────────────────────

create or replace function public.ocorrencias_proximas(
  p_latitude double precision,
  p_longitude double precision,
  p_tipo text,
  p_raio_m integer default 80
)
returns table (
  id uuid,
  protocolo text,
  tipo text,
  descricao text,
  endereco text,
  criado_em timestamptz,
  confirmacoes integer,
  distancia_m integer
)
language sql
stable
set search_path = public, extensions
as $$
  select o.id, o.protocolo, o.tipo, o.descricao, o.endereco, o.criado_em, o.confirmacoes,
         round(st_distance(o.localizacao, st_makepoint(p_longitude, p_latitude)::geography))::int
  from public.ocorrencias o
  where o.municipio_id = public.auth_municipio_id()
    and o.status in ('pendente', 'em_analise')
    and o.tipo = p_tipo
    and o.localizacao is not null
    and st_dwithin(o.localizacao, st_makepoint(p_longitude, p_latitude)::geography, least(p_raio_m, 300))
  order by 8
  limit 5;
$$;

create or replace function public.confirmar_ocorrencia(p_ocorrencia_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_oc public.ocorrencias;
  v_total integer;
begin
  if v_uid is null then
    raise exception 'Não autenticado' using errcode = '42501';
  end if;

  select * into v_oc from public.ocorrencias where id = p_ocorrencia_id for update;
  if v_oc.id is null or v_oc.municipio_id is distinct from public.auth_municipio_id() then
    raise exception 'Ocorrência não encontrada' using errcode = 'P0002';
  end if;
  if v_oc.status not in ('pendente', 'em_analise') then
    raise exception 'Esta ocorrência já foi encerrada' using errcode = 'P0001';
  end if;
  if v_oc.denunciante_id = v_uid then
    raise exception 'Você mesmo registrou esta ocorrência' using errcode = 'P0001';
  end if;
  if not public.fn_check_rate_limit('confirmacao_h:' || v_uid::text, 20, 3600) then
    raise exception 'Muitas confirmações em pouco tempo. Tente mais tarde.' using errcode = 'P0001';
  end if;

  insert into public.ocorrencia_confirmacoes (ocorrencia_id, usuario_id)
  values (p_ocorrencia_id, v_uid)
  on conflict do nothing;

  if found then
    update public.ocorrencias
    set confirmacoes = confirmacoes + 1
    where id = p_ocorrencia_id
    returning confirmacoes into v_total;
  else
    v_total := v_oc.confirmacoes;
  end if;

  return v_total;
end;
$$;

-- ─── Correção da classificação pelo gestor ────────────────────────────────

create or replace function public.reclassificar_ocorrencia(
  p_ocorrencia_id uuid,
  p_urgencia text,
  p_risco_saude text
)
returns public.ocorrencias
language plpgsql
security definer
set search_path = public
as $$
declare
  v_oc public.ocorrencias;
begin
  if public.auth_perfil() is distinct from 'gestor' then
    raise exception 'Só o gestor pode corrigir a classificação' using errcode = '42501';
  end if;
  if p_urgencia not in ('normal', 'atencao', 'risco_saude') or p_risco_saude not in ('baixo', 'medio', 'alto') then
    raise exception 'Classificação inválida' using errcode = '22023';
  end if;

  update public.ocorrencias
  set urgencia = p_urgencia,
      risco_saude = p_risco_saude,
      classificacao_manual = true,
      -- Preenchido também impede a IA de sobrescrever depois.
      classificado_em = coalesce(classificado_em, now()),
      atualizado_em = now()
  where id = p_ocorrencia_id
    and municipio_id = public.auth_municipio_id()
  returning * into v_oc;

  if v_oc.id is null then
    raise exception 'Ocorrência não encontrada' using errcode = 'P0002';
  end if;
  return v_oc;
end;
$$;

-- ─── Avaliação da resolução pelo cidadão ──────────────────────────────────

create or replace function public.avaliar_resolucao(p_ocorrencia_id uuid, p_resolvido boolean)
returns public.ocorrencias
language plpgsql
security definer
set search_path = public
as $$
declare
  v_oc public.ocorrencias;
begin
  select * into v_oc from public.ocorrencias where id = p_ocorrencia_id for update;
  if v_oc.id is null or v_oc.denunciante_id is distinct from auth.uid() then
    raise exception 'Ocorrência não encontrada' using errcode = 'P0002';
  end if;
  if v_oc.status <> 'resolvida' or v_oc.avaliacao_cidadao is not null then
    raise exception 'Esta ocorrência não está aguardando avaliação' using errcode = 'P0001';
  end if;

  update public.ocorrencias
  set avaliacao_cidadao = case when p_resolvido then 'resolvido' else 'nao_resolvido' end,
      avaliado_em = now(),
      status = case when p_resolvido then status else 'pendente' end,
      atualizado_em = now()
  where id = p_ocorrencia_id
  returning * into v_oc;

  -- Reaberta: OS nova volta pra fila (o trigger já avisa os técnicos).
  if not p_resolvido then
    insert into public.ordens_servico (ocorrencia_id, municipio_id)
    values (v_oc.id, v_oc.municipio_id);
  end if;

  return v_oc;
end;
$$;

-- Fotos do reparo para o próprio denunciante (ordens_servico é só staff).
create or replace function public.evidencias_resolucao(p_ocorrencia_id uuid)
returns table (fotos_depois text[], concluida_em timestamptz)
language sql
stable
security definer
set search_path = public
as $$
  select os.fotos_depois, os.concluida_em
  from public.ordens_servico os
  join public.ocorrencias o on o.id = os.ocorrencia_id
  where os.ocorrencia_id = p_ocorrencia_id
    and os.status = 'concluida'
    and o.denunciante_id = auth.uid()
  order by os.concluida_em desc nulls last
  limit 1;
$$;

-- ─── Permissões ───────────────────────────────────────────────────────────

revoke execute on function public.confirmar_ocorrencia(uuid) from public, anon;
revoke execute on function public.reclassificar_ocorrencia(uuid, text, text) from public, anon;
revoke execute on function public.avaliar_resolucao(uuid, boolean) from public, anon;
revoke execute on function public.evidencias_resolucao(uuid) from public, anon;
revoke execute on function public.ocorrencias_proximas(double precision, double precision, text, integer) from public, anon;
revoke execute on function public.prioridades_abertas(integer) from public, anon;

grant execute on function public.confirmar_ocorrencia(uuid) to authenticated;
grant execute on function public.reclassificar_ocorrencia(uuid, text, text) to authenticated;
grant execute on function public.avaliar_resolucao(uuid, boolean) to authenticated;
grant execute on function public.evidencias_resolucao(uuid) to authenticated;
grant execute on function public.ocorrencias_proximas(double precision, double precision, text, integer) to authenticated;
grant execute on function public.prioridades_abertas(integer) to authenticated;
grant execute on function public.prioridade(public.ocorrencias) to authenticated;
