-- Complemento do seed de Teresina: casos DOCUMENTADOS em fontes públicas.
--
-- Aditivo e idempotente (não apaga nada; se já aplicado, não faz nada).
-- Cada registro cita a fonte e a data da reportagem no começo da descrição
-- ("[Fonte pública: ...]"), parafraseada — sem nomes de moradores. As datas
-- são as das reportagens. O texto NÃO afirma desfecho que a fonte não traz.
--
-- Fontes conferidas nas páginas originais em 09/10/2026:
--  * GP1, 05/08/2026 — vazamento e buraco na Av. Joaquim Nelson (zona sudeste)
--  * Portal O Dia, 06/07/2022 — esgoto a céu aberto no Parque Progresso/Parque do Sol
--  * Correio da Manhã, 03/10/2024 — falta d'água por problema na ETA Sul
-- Coordenadas: geocodificação do OpenStreetMap (Nominatim) por bairro/avenida;
-- os casos da ETA Sul usam um ponto representativo de cada zona.
--
-- Os casos históricos (2022 e 2024) entram como 'arquivada' e sem ordem de
-- serviço: o SISAN não atendeu esses casos, eles só ancoram o histórico.
-- O caso de 2026 fica 'pendente' (a concessionária não respondeu à matéria).
--
-- Triggers com efeito colateral (IA, push, notificação) são desligados
-- durante a carga e religados no fim, como no seed principal.

do $seed$
declare
  v_mun uuid;
  v_den uuid;
  v_agora timestamptz := now();
  v_id uuid;
  v_ids uuid[] := '{}';
  r record;
begin
  select id into v_mun from public.municipios where nome = 'Teresina' and estado = 'PI';
  if v_mun is null then
    raise exception 'Município Teresina não encontrado — aplique antes o seed_demo_teresina.sql';
  end if;
  if exists (select 1 from public.ocorrencias where municipio_id = v_mun and descricao like '[Fonte pública:%') then
    raise notice 'Complemento de fontes públicas já aplicado — nada a fazer.';
    return;
  end if;

  select id into v_den from auth.users where email = 'cidadao4@sisan.com';
  if v_den is null then
    raise exception 'Conta de demonstração cidadao4@sisan.com não encontrada';
  end if;

  alter table public.ocorrencias      disable trigger trg_classificar_ocorrencia;
  alter table public.ordens_servico   disable trigger trg_notificar_tecnicos_nova_os;
  alter table public.ordens_servico   disable trigger trg_notificar_cidadao_status_os;
  alter table public.ordens_servico   disable trigger trg_sincronizar_status_ocorrencia_por_os;
  alter table public.notificacoes     disable trigger trg_enviar_push_notificacao;

  -- (tipo, descricao, endereco, lat, lon, urgencia, risco, criado_em, status)
  for r in
    select * from (values
      ('vazamento',
       '[Fonte pública: GP1, 05/08/2026] Vazamento de água na Avenida Joaquim Nelson, na zona sudeste: segundo moradores, começou há cerca de três semanas e a água se espalha pela avenida. A intervenção anterior deixou um buraco no asfalto, coberto pela água e sem sinalização, com risco para motociclistas. A concessionária não respondeu à reportagem.',
       'Avenida Joaquim Nelson, zona sudeste, Teresina - PI', -5.0926408, -42.7530443,
       'atencao', 'baixo', timestamptz '2026-08-05 17:14:00-03', 'pendente'),

      ('esgoto_ceu_aberto',
       '[Fonte pública: Portal O Dia, 06/07/2022] Esgoto a céu aberto escorrendo pela Rua Albânia (Rua 04), no Parque Progresso, segundo moradores há cerca de 25 anos: mau cheiro, lama, quedas de pedestres e carros atolados. Abaixo-assinado sem resposta. A SAAD Sudeste informou que enviou equipe técnica e elaboraria projeto de restauração.',
       'Rua Albânia (Rua 04), Parque Progresso, Teresina - PI', -5.0951826, -42.7429804,
       'risco_saude', 'medio', timestamptz '2022-07-06 09:25:00-03', 'arquivada'),

      ('esgoto_ceu_aberto',
       '[Fonte pública: Portal O Dia, 06/07/2022] Na Rua Poncion Caldas (Parque do Sol/Parque Progresso) o trecho é mais baixo: moradores relatam esgoto escorrendo no meio da rua o ano todo, alagamento com a chuva, risco de doenças e proliferação de mosquitos. Moradores dizem que a prefeitura alegou que a via já tem calçamento.',
       'Rua Poncion Caldas, Parque do Sol, Teresina - PI', -5.0935360, -42.7441012,
       'risco_saude', 'medio', timestamptz '2022-07-06 09:25:00-03', 'arquivada'),

      ('falta_dagua',
       '[Fonte pública: Correio da Manhã, 03/10/2024] Abastecimento interrompido por problema na ETA Sul; a concessionária informou que não havia previsão de retorno. A zona sul está entre as mais afetadas. Localização representativa da zona.',
       'Zona Sul de Teresina (ponto representativo)', -5.1818157, -42.7810193,
       'atencao', 'baixo', timestamptz '2024-10-03 00:01:00-03', 'arquivada'),

      ('falta_dagua',
       '[Fonte pública: Correio da Manhã, 03/10/2024] Abastecimento interrompido por problema na ETA Sul; sem previsão de retorno informada. A zona sudeste está entre as mais afetadas. Localização representativa da zona.',
       'Zona Sudeste de Teresina (ponto representativo)', -5.0930, -42.7500,
       'atencao', 'baixo', timestamptz '2024-10-03 00:01:00-03', 'arquivada'),

      ('falta_dagua',
       '[Fonte pública: Correio da Manhã, 03/10/2024] Abastecimento interrompido por problema na ETA Sul; sem previsão de retorno informada. A zona leste está entre as mais afetadas. Localização representativa da zona.',
       'Zona Leste de Teresina (ponto representativo)', -5.0620, -42.7640,
       'atencao', 'baixo', timestamptz '2024-10-03 00:01:00-03', 'arquivada'),

      ('falta_dagua',
       '[Fonte pública: Correio da Manhã, 03/10/2024] Abastecimento interrompido por problema na ETA Sul; sem previsão de retorno informada. Parte da zona norte está entre as afetadas. Localização representativa da zona.',
       'Zona Norte de Teresina (ponto representativo)', -5.0253266, -42.8128339,
       'atencao', 'baixo', timestamptz '2024-10-03 00:01:00-03', 'arquivada'),

      ('falta_dagua',
       '[Fonte pública: Correio da Manhã, 03/10/2024] Abastecimento interrompido por problema na ETA Sul; sem previsão de retorno informada. A região central está entre as mais afetadas. Localização representativa da zona.',
       'Centro de Teresina (ponto representativo)', -5.0892, -42.8019,
       'atencao', 'baixo', timestamptz '2024-10-03 00:01:00-03', 'arquivada')
    ) as t(tipo, descricao, endereco, lat, lon, urgencia, risco, criado, status)
  loop
    insert into public.ocorrencias (
      municipio_id, denunciante_id, tipo, descricao, endereco, latitude, longitude,
      urgencia, risco_saude, classificado_em, criado_em, status
    ) values (
      v_mun, v_den, r.tipo, r.descricao, r.endereco, r.lat, r.lon,
      r.urgencia, r.risco, r.criado + interval '40 seconds', r.criado, 'pendente'
    ) returning id into v_id;

    update public.ocorrencias
       set protocolo = 'OCR-' || to_char(r.criado, 'YYYYMM') || '-' || right(protocolo, 5),
           status = r.status,
           atualizado_em = r.criado
     where id = v_id;

    if r.status = 'pendente' then
      update public.ordens_servico set criado_em = r.criado, atualizado_em = r.criado
       where ocorrencia_id = v_id;
    else
      v_ids := v_ids || v_id;
    end if;
  end loop;

  -- Casos históricos não geraram ordem de serviço no SISAN.
  delete from public.ordens_servico where ocorrencia_id = any(v_ids);

  alter table public.ocorrencias      enable trigger trg_classificar_ocorrencia;
  alter table public.ordens_servico   enable trigger trg_notificar_tecnicos_nova_os;
  alter table public.ordens_servico   enable trigger trg_notificar_cidadao_status_os;
  alter table public.ordens_servico   enable trigger trg_sincronizar_status_ocorrencia_por_os;
  alter table public.notificacoes     enable trigger trg_enviar_push_notificacao;

  raise notice 'Complemento de fontes públicas aplicado (8 registros).';
end
$seed$;
