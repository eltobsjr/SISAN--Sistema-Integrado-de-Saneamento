-- Fase 5: resumo executivo por IA no dashboard do gestor (insight-dashboard).

-- Cache do insight por município + período. Só a Edge Function (service_role)
-- lê e grava; o cliente recebe o resultado pela função. `hash_agregados` deixa
-- reaproveitar o texto enquanto os números do mês não mudarem.
create table if not exists public.insights_dashboard (
  municipio_id   uuid not null references public.municipios(id),
  periodo        text not null, -- 'YYYY-MM'
  hash_agregados text not null,
  titulo         text not null,
  frases         jsonb not null,
  criado_em      timestamptz not null default now(),
  primary key (municipio_id, periodo)
);

alter table public.insights_dashboard enable row level security;
-- Sem policy de propósito: negado pra anon/authenticated, service_role ignora RLS.

-- Agregados ANÔNIMOS do município do gestor logado — é tudo que a IA vê.
-- Nada de nome, e-mail, texto livre de relato ou coordenada: só contagens.
create or replace function public.insight_agregados()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_mun        uuid := auth_municipio_id();
  v_ini_mes    timestamptz := date_trunc('month', now() at time zone 'utc') at time zone 'utc';
  v_ini_ant    timestamptz := (date_trunc('month', now() at time zone 'utc') - interval '1 month') at time zone 'utc';
  v_por_tipo   jsonb;
  v_por_urg    jsonb;
  v_bairros    jsonb;
begin
  if auth_perfil() is distinct from 'gestor' then
    raise exception 'Acesso restrito a gestor.' using errcode = '42501';
  end if;

  select coalesce(jsonb_object_agg(tipo, n), '{}'::jsonb) into v_por_tipo
    from (select tipo, count(*) n from ocorrencias
           where municipio_id = v_mun and criado_em >= v_ini_mes group by tipo) t;

  select coalesce(jsonb_object_agg(urgencia, n), '{}'::jsonb) into v_por_urg
    from (select urgencia, count(*) n from ocorrencias
           where municipio_id = v_mun and criado_em >= v_ini_mes group by urgencia) t;

  -- Reincidência: bairro (extraído do endereço "Rua, nº - Bairro, Cidade - UF")
  -- e tipo com 2+ ocorrências nos últimos 30 dias. Top 5.
  select coalesce(jsonb_agg(b order by (b->>'total')::int desc), '[]'::jsonb) into v_bairros
    from (
      select jsonb_build_object(
               'bairro', bairro, 'tipo', tipo, 'total', count(*),
               'com_risco_saude', count(*) filter (where urgencia = 'risco_saude')) b
        from (
          select tipo, urgencia,
                 nullif(trim(split_part(split_part(endereco, ' - ', 2), ',', 1)), '') as bairro
            from ocorrencias
           where municipio_id = v_mun and criado_em >= now() - interval '30 days'
        ) x
       where bairro is not null
       group by bairro, tipo
      having count(*) >= 2
       order by count(*) desc
       limit 5
    ) y;

  return jsonb_build_object(
    'periodo',            to_char(now() at time zone 'utc', 'YYYY-MM'),
    'municipio',          (select nome from municipios where id = v_mun),
    'ocorrencias_mes',    (select count(*) from ocorrencias where municipio_id = v_mun and criado_em >= v_ini_mes),
    'ocorrencias_mes_anterior',
                          (select count(*) from ocorrencias where municipio_id = v_mun and criado_em >= v_ini_ant and criado_em < v_ini_mes),
    'por_tipo',           v_por_tipo,
    'por_urgencia',       v_por_urg,
    'abertas_agora',      (select count(*) from ocorrencias where municipio_id = v_mun and status in ('pendente','em_analise')),
    'abertas_risco_saude',(select count(*) from ocorrencias where municipio_id = v_mun and status in ('pendente','em_analise') and urgencia = 'risco_saude'),
    'tempo_medio_resolucao_horas_mes',
                          coalesce((select round(avg(extract(epoch from (os.concluida_em - o.criado_em)) / 3600)::numeric, 1)
                                      from ordens_servico os join ocorrencias o on o.id = os.ocorrencia_id
                                     where os.municipio_id = v_mun and os.status = 'concluida' and os.concluida_em >= v_ini_mes), 0),
    'alertas_sanitarios_ativos',
                          (select count(*) from alertas_sanitarios where municipio_id = v_mun and ativo),
    'reincidencia_30_dias', v_bairros
  );
end;
$$;

revoke all on function public.insight_agregados() from public;
revoke all on function public.insight_agregados() from anon;
grant execute on function public.insight_agregados() to authenticated;
