-- Corrige `avaliar_resolucao` (20261013120000): há um índice único
-- `ordens_servico_ocorrencia_idx` (uma OS por ocorrência), então "não
-- resolveu" não cria OS nova — devolve a mesma OS para a fila, sem técnico,
-- e avisa os técnicos do município (mesmo tipo `nova_os` da fila normal).
-- O trigger `trg_sincronizar_status_ocorrencia_por_os` leva a ocorrência
-- de volta para 'pendente'.

create or replace function public.avaliar_resolucao(p_ocorrencia_id uuid, p_resolvido boolean)
returns public.ocorrencias
language plpgsql
security definer
set search_path = public
as $$
declare
  v_oc public.ocorrencias;
  v_os_id uuid;
begin
  select * into v_oc from public.ocorrencias where id = p_ocorrencia_id for update;
  if v_oc.id is null or v_oc.denunciante_id is distinct from auth.uid() then
    raise exception 'Ocorrência não encontrada' using errcode = 'P0002';
  end if;
  -- 'nao_resolvido' + 'resolvida' = foi reaberta e concluída de novo: avalia outra vez.
  if v_oc.status <> 'resolvida' or v_oc.avaliacao_cidadao = 'resolvido' then
    raise exception 'Esta ocorrência não está aguardando avaliação' using errcode = 'P0001';
  end if;

  if not p_resolvido then
    update public.ordens_servico
    set status = 'pendente',
        tecnico_id = null,
        aceita_em = null,
        chegada_em = null,
        chegada_latitude = null,
        chegada_longitude = null,
        concluida_em = null,
        checklist = '{}'::jsonb,
        fotos_depois = '{}'::text[]
    where ocorrencia_id = v_oc.id
    returning id into v_os_id;

    insert into public.notificacoes (municipio_id, usuario_id, tipo, titulo, corpo, dados)
    select v_oc.municipio_id, u.id, 'nova_os', 'Ocorrência reaberta',
           'O cidadão informou que o problema não foi resolvido.',
           jsonb_build_object('ordem_servico_id', v_os_id, 'ocorrencia_id', v_oc.id)
    from public.usuarios u
    where u.municipio_id = v_oc.municipio_id and u.perfil = 'tecnico' and u.ativo;
  end if;

  update public.ocorrencias
  set avaliacao_cidadao = case when p_resolvido then 'resolvido' else 'nao_resolvido' end,
      avaliado_em = now(),
      status = case when p_resolvido then 'resolvida' else 'pendente' end,
      atualizado_em = now()
  where id = p_ocorrencia_id
  returning * into v_oc;

  return v_oc;
end;
$$;
