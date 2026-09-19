-- Move o PostGIS do schema `public` para `extensions`.
--
-- STATUS: JÁ APLICADO em 19/09/2026 no projeto do SISAN (validado: centros dos
-- municípios, 66/66 localizações de ocorrências e trigger conferidos; o aviso
-- rls_disabled_in_public da spatial_ref_sys deixou de aparecer no advisor).
-- Fica versionado como registro e pra recriar o ambiente. Ver decisions/014.
--
-- Resolve dois avisos do advisor de segurança do Supabase:
--   * rls_disabled_in_public: public.spatial_ref_sys sem RLS (tabela do PostGIS,
--     pertence ao supabase_admin — o role `postgres` não consegue habilitar RLS
--     nela, mas consegue recriar a extensão em outro schema, que o PostgREST
--     não expõe);
--   * extension_in_public: postgis instalado em public.
--
-- COMO RODAR: SQL Editor do Dashboard, colar tudo e executar UMA vez, fora de
-- demo (trava as tabelas por alguns segundos).
--
-- POR QUE UM ÚNICO BLOCO `DO`: a primeira versão deste script usava
-- BEGIN/COMMIT com uma tabela temporária `ON COMMIT DROP`. O SQL Editor do
-- Dashboard executou os passos em lotes separados: os passos de 1 a 6 foram
-- confirmados e a tabela temporária já não existia quando a validação rodou
-- (erro 42P01), sem dano — mas sem a atomicidade prometida. Um único
-- statement é atômico em qualquer editor: qualquer falha desfaz tudo.
--
-- O que depende do PostGIS (conferido): municipios.centro,
-- municipios.centro_latitude/longitude (geradas) e ocorrencias.localizacao.
-- Nenhum índice GIST, nenhuma view nossa, nenhuma RPC usa PostGIS; a única
-- função é o trigger fn_ocorrencia_localizacao. O app lê apenas
-- centro_latitude/centro_longitude e latitude/longitude.

do $mover$
declare
  v_bkp int; v_centro int; v_lat int; v_com int; v_loc int;
begin
  -- 1. Guarda o que não dá pra recalcular depois do DROP
  --    (ocorrencias.localizacao é reconstruída de latitude/longitude).
  create temp table _bkp_municipios_centro on commit drop as
    select id, centro_latitude as lat, centro_longitude as lon
      from public.municipios
     where centro is not null;

  -- 2. Remove o PostGIS. O CASCADE só leva as 4 colunas acima e as views
  --    geography_columns/geometry_columns.
  drop extension postgis cascade;

  -- 3. Recria no schema `extensions` (não exposto pela API REST).
  create schema if not exists extensions;
  create extension postgis with schema extensions;

  -- 4. Recria as colunas, com a mesma definição de antes.
  alter table public.municipios
    add column centro extensions.geography(Point, 4326);

  alter table public.municipios
    add column centro_latitude double precision generated always as (
      case when centro is null then null else extensions.st_y(centro::extensions.geometry) end
    ) stored;

  alter table public.municipios
    add column centro_longitude double precision generated always as (
      case when centro is null then null else extensions.st_x(centro::extensions.geometry) end
    ) stored;

  alter table public.ocorrencias
    add column localizacao extensions.geography(Point, 4326);

  -- 5. O trigger que preenche `localizacao` precisa enxergar o novo schema.
  create or replace function public.fn_ocorrencia_localizacao()
  returns trigger
  language plpgsql
  set search_path = public, extensions
  as $fn$
  begin
    if new.latitude is not null and new.longitude is not null then
      new.localizacao := st_setsrid(st_makepoint(new.longitude, new.latitude), 4326)::geography;
    end if;
    return new;
  end;
  $fn$;

  -- 6. Restaura os dados.
  update public.municipios m
     set centro = extensions.st_setsrid(extensions.st_makepoint(b.lon, b.lat), 4326)::extensions.geography
    from _bkp_municipios_centro b
   where b.id = m.id;

  update public.ocorrencias
     set localizacao = extensions.st_setsrid(extensions.st_makepoint(longitude, latitude), 4326)::extensions.geography
   where latitude is not null and longitude is not null;

  -- 7. Confere tudo; qualquer divergência levanta exceção e desfaz o bloco inteiro.
  select count(*) into v_bkp    from _bkp_municipios_centro;
  select count(*) into v_centro from public.municipios where centro is not null;
  select count(*) into v_lat    from public.municipios where centro_latitude is not null and centro_longitude is not null;
  select count(*) into v_com    from public.ocorrencias where latitude is not null and longitude is not null;
  select count(*) into v_loc    from public.ocorrencias where localizacao is not null;

  if v_centro <> v_bkp or v_lat <> v_bkp then
    raise exception 'Centros dos municípios não bateram (backup=%, centro=%, lat/lon=%)', v_bkp, v_centro, v_lat;
  end if;
  if v_loc <> v_com then
    raise exception 'Localizações das ocorrências não bateram (esperado=%, obtido=%)', v_com, v_loc;
  end if;
  if to_regclass('public.spatial_ref_sys') is not null then
    raise exception 'public.spatial_ref_sys ainda existe';
  end if;
  if to_regclass('extensions.spatial_ref_sys') is null then
    raise exception 'PostGIS não foi recriado em extensions';
  end if;

  raise notice 'OK: % municípios e % ocorrências com geografia restaurada.', v_centro, v_loc;
end
$mover$;
