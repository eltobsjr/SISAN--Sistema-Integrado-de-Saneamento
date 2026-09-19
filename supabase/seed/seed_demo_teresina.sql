-- Seed de demonstração: município de Teresina (Águas de Teresina) com
-- 2 gestores, 3 técnicos, 4 cidadãos e ~65 ocorrências fictícias espalhadas
-- pelos últimos 6 meses, com ordens de serviço, alertas e notificações.
--
-- TODOS OS DADOS SÃO FICTÍCIOS (nomes, endereços, relatos). Coordenadas são
-- aproximadas por bairro só pra o mapa ficar plausível.
--
-- Como aplicar: substitua __SENHA_DEMO__ pela senha das contas de demo
-- (nunca commite a senha real) e rode no SQL Editor / MCP. É idempotente:
-- se Teresina já existir, não faz nada.
--
-- Os triggers de classificação por IA, push e notificação são desligados
-- durante o seed (senão dispararia ~65 chamadas ao Groq e centenas de
-- notificações) e religados no fim; a classificação vem pré-preenchida.

do $seed$
declare
  v_senha   constant text := '__SENHA_DEMO__';
  v_mun     uuid;
  v_codigo  text;
  v_agora   timestamptz := now();

  v_gestores uuid[] := '{}';
  v_tecnicos uuid[] := '{}';
  v_cidadaos uuid[] := '{}';

  -- (nome, email, perfil)
  v_pessoas text[][] := array[
    ['Marcos Vinícius Andrade',     'gestor1.teresina@sisan.dev',  'gestor'],
    ['Renata Cavalcante Lima',      'gestor2.teresina@sisan.dev',  'gestor'],
    ['José Ribamar Sousa',          'tecnico1.teresina@sisan.dev', 'tecnico'],
    ['Antônio Carlos Nogueira',     'tecnico2.teresina@sisan.dev', 'tecnico'],
    ['Francisco das Chagas Pereira','tecnico3.teresina@sisan.dev', 'tecnico'],
    ['Maria do Socorro Silva',      'cidadao1.teresina@sisan.dev', 'cidadao'],
    ['Ana Beatriz Rocha',           'cidadao2.teresina@sisan.dev', 'cidadao'],
    ['Carlos Eduardo Moura',        'cidadao3.teresina@sisan.dev', 'cidadao'],
    ['Luciana Fontenele Araújo',    'cidadao4.teresina@sisan.dev', 'cidadao']
  ];

  -- bairros repetidos = mais chamados (Dirceu Arcoverde, Santa Maria da
  -- Codipi e Mocambinho concentram esgoto reincidente perto de escola).
  v_bairros jsonb := '[
    {"n":"Centro","lat":-5.0892,"lon":-42.8019},
    {"n":"Dirceu Arcoverde","lat":-5.1230,"lon":-42.7560},
    {"n":"Dirceu Arcoverde","lat":-5.1230,"lon":-42.7560},
    {"n":"Dirceu Arcoverde","lat":-5.1230,"lon":-42.7560},
    {"n":"Santa Maria da Codipi","lat":-5.0290,"lon":-42.7950},
    {"n":"Santa Maria da Codipi","lat":-5.0290,"lon":-42.7950},
    {"n":"Mocambinho","lat":-5.0000,"lon":-42.8000},
    {"n":"Mocambinho","lat":-5.0000,"lon":-42.8000},
    {"n":"Vila Operária","lat":-5.0980,"lon":-42.7850},
    {"n":"Piçarra","lat":-5.1140,"lon":-42.7990},
    {"n":"Angelim","lat":-5.1230,"lon":-42.8110},
    {"n":"Ininga","lat":-5.0620,"lon":-42.7640},
    {"n":"Fátima","lat":-5.0680,"lon":-42.7830}
  ]';
  v_tipos text[] := array[
    'vazamento','vazamento','vazamento','vazamento',
    'esgoto_ceu_aberto','esgoto_ceu_aberto','esgoto_ceu_aberto',
    'falta_dagua','falta_dagua','falta_dagua',
    'agua_contaminada','agua_contaminada',
    'baixa_pressao','baixa_pressao',
    'outros'
  ];
  v_ruas text[] := array[
    'Rua das Acácias','Av. Boa Esperança','Rua São Francisco','Rua Projetada 3',
    'Av. Nossa Senhora de Fátima','Rua Alegria','Rua Dom Pedro II','Rua Maranhão',
    'Rua dos Ipês','Rua Santa Luzia','Av. Universitária','Rua do Campo'
  ];
  -- contagem de ocorrências por mês, do mais antigo (5 meses atrás) ao atual
  v_por_mes int[] := array[6, 8, 10, 12, 15, 14];

  v_mes_ini timestamptz;
  v_mes_fim timestamptz;
  m int; i int;
  v_b jsonb; v_tipo text; v_desc text; v_urg text; v_risco text;
  v_criado timestamptz; v_span double precision;
  v_lat double precision; v_lon double precision;
  v_escola boolean;
  v_den uuid; v_id uuid; v_os_status text; v_tec uuid;
  v_idade_dias double precision; v_r double precision;
  v_aceita timestamptz; v_chegada timestamptz; v_concl timestamptz;
  v_check jsonb; v_status_oc text; v_ultimo timestamptz;
  v_uid uuid; v_perfil text; v_k int;
begin
  if exists (select 1 from public.municipios where nome = 'Teresina' and estado = 'PI') then
    raise notice 'Seed de Teresina já aplicado — nada a fazer.';
    return;
  end if;

  perform setseed(0.37);

  -- Desliga triggers com efeito colateral (religados no fim do bloco).
  alter table public.ocorrencias      disable trigger trg_classificar_ocorrencia;
  alter table public.ordens_servico   disable trigger trg_notificar_tecnicos_nova_os;
  alter table public.ordens_servico   disable trigger trg_notificar_cidadao_status_os;
  alter table public.ordens_servico   disable trigger trg_sincronizar_status_ocorrencia_por_os;
  alter table public.alertas_sanitarios disable trigger trg_notificar_staff_novo_alerta;
  alter table public.notificacoes     disable trigger trg_enviar_push_notificacao;

  -- ── Município + código de ativação de staff ───────────────────────────
  -- centro_latitude/centro_longitude são colunas geradas a partir de `centro`.
  insert into public.municipios (nome, estado, concessionaria, centro)
  values ('Teresina', 'PI', 'aguas_teresina',
          st_setsrid(st_makepoint(-42.8019, -5.0892), 4326)::geography)
  returning id into v_mun;

  insert into public.codigos_ativacao_staff (municipio_id) values (v_mun)
  returning codigo into v_codigo;

  -- ── Usuários (auth.users → trigger handle_new_user cria public.usuarios) ─
  for i in 1 .. array_length(v_pessoas, 1) loop
    v_uid := gen_random_uuid();
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000', v_uid, 'authenticated', 'authenticated',
      v_pessoas[i][2], extensions.crypt(v_senha, extensions.gen_salt('bf')), v_agora,
      '{"provider":"email","providers":["email"]}',
      jsonb_build_object('nome', v_pessoas[i][1], 'perfil', v_pessoas[i][3],
                         'municipio_id', v_mun, 'codigo_ativacao', v_codigo),
      v_agora - interval '150 days', v_agora,
      '', '', '', ''
    );
    insert into auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    values (v_uid::text, v_uid,
            jsonb_build_object('sub', v_uid::text, 'email', v_pessoas[i][2], 'email_verified', true),
            'email', v_agora, v_agora, v_agora);

    if    v_pessoas[i][3] = 'gestor'  then v_gestores := v_gestores || v_uid;
    elsif v_pessoas[i][3] = 'tecnico' then v_tecnicos := v_tecnicos || v_uid;
    else                                   v_cidadaos := v_cidadaos || v_uid;
    end if;
  end loop;

  -- ── Ocorrências + ordens de serviço ────────────────────────────────────
  for m in 1 .. 6 loop
    v_mes_ini := date_trunc('month', v_agora at time zone 'utc') at time zone 'utc'
                 - make_interval(months => 6 - m);
    v_mes_fim := least(v_mes_ini + interval '1 month', v_agora - interval '2 hours');
    v_span := extract(epoch from (v_mes_fim - v_mes_ini));

    for i in 1 .. v_por_mes[m] loop
      v_b     := v_bairros -> floor(random() * jsonb_array_length(v_bairros))::int;
      v_tipo  := v_tipos[1 + floor(random() * array_length(v_tipos, 1))::int];
      v_den   := v_cidadaos[1 + floor(random() * array_length(v_cidadaos, 1))::int];
      v_criado := v_mes_ini + make_interval(secs => random() * v_span);
      v_lat := (v_b->>'lat')::double precision + (random() - 0.5) * 0.012;
      v_lon := (v_b->>'lon')::double precision + (random() - 0.5) * 0.012;
      v_escola := (v_b->>'n') in ('Dirceu Arcoverde','Santa Maria da Codipi','Mocambinho')
                  and random() < 0.55;

      v_desc := case v_tipo
        when 'vazamento' then (array[
          'Vazamento de água na rua há dois dias, desperdiçando muita água.',
          'Cano estourado na calçada, a água escorre o dia inteiro.',
          'Vazamento no registro em frente às casas, formou uma poça grande.'])[1 + floor(random()*3)::int]
        when 'esgoto_ceu_aberto' then (array[
          'Esgoto transbordando na rua, mau cheiro forte.',
          'Esgoto a céu aberto correndo pela calçada há vários dias.',
          'Caixa de esgoto estourada, o esgoto está tomando a via.'])[1 + floor(random()*3)::int]
          || case when v_escola then ' Fica perto da escola municipal e as crianças passam pelo local.' else '' end
        when 'falta_dagua' then (array[
          'Sem água nas torneiras desde ontem cedo, vários vizinhos na mesma situação.',
          'Faz três dias que a água não chega na rua toda.',
          'Abastecimento interrompido desde a madrugada, sem aviso.'])[1 + floor(random()*3)::int]
        when 'agua_contaminada' then (array[
          'Água saindo turva e com cheiro forte, moradores com receio de usar.',
          'A água da torneira está amarelada e com gosto estranho.',
          'Água com cor barrenta chegando nas casas da rua.'])[1 + floor(random()*3)::int]
          || case when v_escola then ' Há uma escola e uma creche na mesma rua.' else '' end
        when 'baixa_pressao' then (array[
          'Pressão muito baixa, a água não sobe para a caixa d''água.',
          'Água chega só um fiozinho, impossível encher a caixa.',
          'Pressão caiu muito nos últimos dias, só sai água de madrugada.'])[1 + floor(random()*3)::int]
        else (array[
          'Tampa de bueiro da rede de água quebrada, risco de acidente.',
          'Hidrômetro violado na esquina, água sendo desviada.'])[1 + floor(random()*2)::int]
      end || ' (' || (v_b->>'n') || ')';

      -- Classificação pré-preenchida (no app real, vem da IA).
      v_urg := case
        when v_tipo in ('esgoto_ceu_aberto','agua_contaminada') then 'risco_saude'
        when v_tipo = 'falta_dagua' or (v_tipo = 'vazamento' and random() < 0.35) then 'atencao'
        else 'normal' end;
      v_risco := case
        when v_urg = 'risco_saude' and v_escola then 'alto'
        when v_urg = 'risco_saude' then (case when random() < 0.4 then 'alto' else 'medio' end)
        when v_urg = 'atencao' then (case when random() < 0.25 then 'medio' else 'baixo' end)
        else 'baixo' end;

      insert into public.ocorrencias (
        municipio_id, denunciante_id, tipo, descricao, endereco, latitude, longitude,
        urgencia, risco_saude, classificado_em, criado_em, status
      ) values (
        v_mun, v_den, v_tipo, v_desc,
        v_ruas[1 + floor(random() * array_length(v_ruas, 1))::int] || ', '
          || (10 + floor(random() * 890))::int || ' - ' || (v_b->>'n') || ', Teresina - PI',
        v_lat, v_lon, v_urg, v_risco, v_criado + interval '40 seconds', v_criado, 'pendente'
      ) returning id into v_id;

      -- Protocolo com o mês da criação (o trigger usa now()).
      update public.ocorrencias
         set protocolo = 'OCR-' || to_char(v_criado, 'YYYYMM') || '-' || right(protocolo, 5)
       where id = v_id;

      -- Destino da ordem de serviço criada automaticamente pelo trigger.
      v_idade_dias := extract(epoch from (v_agora - v_criado)) / 86400;
      v_r := random();
      v_os_status := case
        when v_idade_dias > 14 then case when v_r < 0.92 then 'concluida' when v_r < 0.96 then 'a_caminho' else 'pendente' end
        when v_idade_dias > 3  then case when v_r < 0.65 then 'concluida' when v_r < 0.77 then 'a_caminho' when v_r < 0.87 then 'aceita' else 'pendente' end
        else                        case when v_r < 0.20 then 'concluida' when v_r < 0.35 then 'a_caminho' when v_r < 0.55 then 'aceita' else 'pendente' end
      end;

      v_ultimo := v_criado;
      v_aceita := null; v_chegada := null; v_concl := null; v_tec := null; v_check := '{}'::jsonb;

      if v_os_status <> 'pendente' then
        v_tec    := v_tecnicos[1 + floor(random() * array_length(v_tecnicos, 1))::int];
        v_aceita := least(v_criado + make_interval(mins => 20 + floor(random() * 460)::int), v_agora - interval '10 minutes');
        v_ultimo := v_aceita;
        if v_os_status in ('a_caminho','concluida') then
          v_chegada := least(v_aceita + make_interval(mins => 30 + floor(random() * 150)::int), v_agora - interval '5 minutes');
          v_ultimo := v_chegada;
        end if;
        if v_os_status = 'concluida' then
          -- casos de risco à saúde são resolvidos mais rápido
          v_concl := least(v_chegada + make_interval(mins => (case when v_urg = 'risco_saude' then 60 else 120 end) + floor(random() * 900)::int),
                           v_agora - interval '2 minutes');
          v_ultimo := v_concl;
          v_check := case v_tipo
            when 'vazamento'         then '{"Vazamento estancado":true,"Via/calçada recomposta":true}'
            when 'esgoto_ceu_aberto' then '{"Fluxo de esgoto interrompido":true,"Área higienizada":true}'
            when 'falta_dagua'       then '{"Abastecimento normalizado":true,"Rede verificada":true}'
            when 'agua_contaminada'  then '{"Fonte de contaminação identificada":true,"Qualidade da água verificada":true}'
            when 'baixa_pressao'     then '{"Pressão normalizada":true,"Rede verificada":true}'
            else                          '{"Problema resolvido":true}'
          end::jsonb;
        end if;
      end if;

      update public.ordens_servico
         set status = v_os_status, tecnico_id = v_tec, aceita_em = v_aceita,
             chegada_em = v_chegada, concluida_em = v_concl, checklist = v_check,
             chegada_latitude  = case when v_chegada is not null then v_lat + (random() - 0.5) * 0.0004 end,
             chegada_longitude = case when v_chegada is not null then v_lon + (random() - 0.5) * 0.0004 end,
             criado_em = v_criado, atualizado_em = v_ultimo
       where ocorrencia_id = v_id;

      v_status_oc := case v_os_status
        when 'concluida' then case when v_concl < v_agora - interval '30 days' and random() < 0.5 then 'arquivada' else 'resolvida' end
        when 'pendente'  then 'pendente'
        else 'em_analise' end;
      update public.ocorrencias set status = v_status_oc, atualizado_em = v_ultimo where id = v_id;
    end loop;
  end loop;

  -- ── Alertas sanitários (só staff enxerga) ──────────────────────────────
  insert into public.alertas_sanitarios (municipio_id, tipo, descricao, latitude, longitude, raio_metros, ativo, criado_por, criado_em, encerrado_em) values
    (v_mun, 'esgoto_ceu_aberto_recorrente', 'Esgoto a céu aberto reincidente no entorno de escola municipal no Dirceu Arcoverde. Priorizar desobstrução da rede e higienização.', -5.1230, -42.7560, 450, true,  v_gestores[1], v_agora - interval '9 days', null),
    (v_mun, 'agua_contaminada_recorrente',  'Relatos repetidos de água turva na Santa Maria da Codipi. Coletar amostra e verificar a rede antes de novos relatos.',           -5.0290, -42.7950, 600, true,  v_gestores[1], v_agora - interval '5 days', null),
    (v_mun, 'risco_doenca_hidrica',         'Risco de doenças de veiculação hídrica no Mocambinho: esgoto exposto próximo a área de moradias. Acionar vigilância em saúde.',   -5.0000, -42.8000, 500, true,  v_gestores[2], v_agora - interval '2 days', null),
    (v_mun, 'outros',                       'Falta d''água prolongada em parte do Angelim por manutenção emergencial na adutora.',                                            -5.1230, -42.8110, 700, true,  v_gestores[2], v_agora - interval '1 day',  null),
    (v_mun, 'esgoto_ceu_aberto_recorrente', 'Extravasamento recorrente na Piçarra — resolvido após troca do trecho da rede.',                                                 -5.1140, -42.7990, 300, false, v_gestores[1], v_agora - interval '40 days', v_agora - interval '31 days'),
    (v_mun, 'agua_contaminada_recorrente',  'Água barrenta no Ininga após obra na rede — normalizada.',                                                                       -5.0620, -42.7640, 400, false, v_gestores[2], v_agora - interval '70 days', v_agora - interval '64 days');

  -- ── Notificações de exemplo ────────────────────────────────────────────
  -- Cidadãos: status das últimas ocorrências resolvidas de cada um.
  insert into public.notificacoes (municipio_id, usuario_id, tipo, titulo, corpo, lida, dados, criado_em)
  select v_mun, x.denunciante_id, 'status_os', 'Sua ocorrência foi resolvida',
         'O reparo foi concluído. Obrigado por denunciar!', (x.rn > 1),
         jsonb_build_object('ocorrencia_id', x.id), x.atualizado_em
    from (
      select o.id, o.denunciante_id, o.atualizado_em,
             row_number() over (partition by o.denunciante_id order by o.atualizado_em desc) as rn
        from public.ocorrencias o
       where o.municipio_id = v_mun and o.status = 'resolvida'
    ) x
   where x.rn <= 3;

  -- Técnicos: as 3 OS pendentes mais recentes.
  insert into public.notificacoes (municipio_id, usuario_id, tipo, titulo, corpo, lida, dados, criado_em)
  select v_mun, t.id, 'nova_os', 'Nova ordem de serviço',
         'Uma nova ocorrência foi registrada no seu município.', false,
         jsonb_build_object('ordem_servico_id', os.id, 'ocorrencia_id', os.ocorrencia_id), os.criado_em
    from unnest(v_tecnicos) as t(id)
    cross join lateral (
      select id, ocorrencia_id, criado_em from public.ordens_servico
       where municipio_id = v_mun and status = 'pendente'
       order by criado_em desc limit 3
    ) os;

  -- Gestores: os alertas ativos.
  insert into public.notificacoes (municipio_id, usuario_id, tipo, titulo, corpo, lida, dados, criado_em)
  select v_mun, g.id, 'alerta_sanitario', 'Novo alerta sanitário', a.descricao, false,
         jsonb_build_object('alerta_id', a.id), a.criado_em
    from unnest(v_gestores) as g(id)
    cross join public.alertas_sanitarios a
   where a.municipio_id = v_mun and a.ativo;

  -- Religa os triggers.
  alter table public.ocorrencias      enable trigger trg_classificar_ocorrencia;
  alter table public.ordens_servico   enable trigger trg_notificar_tecnicos_nova_os;
  alter table public.ordens_servico   enable trigger trg_notificar_cidadao_status_os;
  alter table public.ordens_servico   enable trigger trg_sincronizar_status_ocorrencia_por_os;
  alter table public.alertas_sanitarios enable trigger trg_notificar_staff_novo_alerta;
  alter table public.notificacoes     enable trigger trg_enviar_push_notificacao;

  raise notice 'Seed de Teresina aplicado.';
end
$seed$;
