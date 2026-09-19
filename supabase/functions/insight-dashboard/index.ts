// Resumo executivo do mês pro gestor, gerado por IA a partir de agregados
// ANÔNIMOS (contagens por tipo/urgência/bairro — nenhum dado do cidadão).
//
// Chamada pelo app com o JWT do gestor (verify_jwt: true). Fluxo:
//   1. valida o usuário e pega os agregados pela RPC `insight_agregados`
//      (que já exige perfil gestor e filtra pelo município dele);
//   2. se os números não mudaram desde o último insight do período, devolve
//      o cache — não gasta IA nem cota;
//   3. senão aplica rate limit por usuário, pede o texto ao provedor e
//      guarda no cache.
//
// Se a IA falhar, só este card do dashboard some; o resto continua igual.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders, errorResponse, HttpError, jsonResponse } from "../_shared/errors.ts";
import { generateStructured } from "../_shared/provider.ts";

interface Insight {
  titulo: string;
  frases: string[];
}

function validar(raw: unknown): Insight {
  const o = raw as Record<string, unknown> | null;
  const titulo = o?.titulo;
  const frases = o?.frases;
  if (
    typeof titulo !== "string" || titulo.length < 1 || titulo.length > 120 ||
    !Array.isArray(frases) || frases.length < 2 || frases.length > 3 ||
    !frases.every((f) => typeof f === "string" && f.length > 0 && f.length <= 400)
  ) {
    throw new Error("JSON fora do schema esperado");
  }
  return { titulo, frases: frases as string[] };
}

const SYSTEM = `Você é analista de saneamento e escreve um resumo executivo para o gestor de uma concessionária de água e esgoto.

Você recebe os dados agregados e anônimos do mês de um município (contagens de ocorrências por tipo, urgência e bairro). Responda SOMENTE um JSON: {"titulo": "...", "frases": ["...", "..."]}

Regras:
- "titulo": curto, até 70 caracteres, resumindo o ponto principal.
- "frases": 2 a 3 frases, em português simples e sem jargão, cada uma acionável (diga onde e o que priorizar).
- Priorize risco à saúde: esgoto a céu aberto e água contaminada, principalmente onde há reincidência.
- Tipos: vazamento, esgoto_ceu_aberto = esgoto a céu aberto, falta_dagua = falta d'água, agua_contaminada = água contaminada, baixa_pressao = baixa pressão.
- Use SOMENTE números e bairros que aparecem nos dados. Nunca invente números, nomes ou causas. Se houver poucos dados, diga isso em vez de concluir demais.`;

async function sha256(texto: string): Promise<string> {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(texto));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    if (req.method !== "POST") throw new HttpError(405, "Method not allowed");

    const authorization = req.headers.get("Authorization");
    if (!authorization) throw new HttpError(401, "Unauthorized");

    const url = Deno.env.get("SUPABASE_URL")!;
    const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authorization } },
    });
    const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    const { data: userData, error: userErr } = await userClient.auth.getUser();
    if (userErr || !userData.user) throw new HttpError(401, "Unauthorized");
    const userId = userData.user.id;

    const { data: agregados, error: aggErr } = await userClient.rpc("insight_agregados");
    if (aggErr) {
      if (aggErr.code === "42501") throw new HttpError(403, "Acesso restrito a gestor");
      throw new HttpError(500, "Erro ao ler dados do município", aggErr);
    }

    // Sem ocorrências no mês não há o que resumir.
    if (!agregados.ocorrencias_mes) {
      return jsonResponse({ vazio: true }, 200, corsHeaders);
    }

    const { data: perfil, error: perfilErr } = await admin
      .from("usuarios")
      .select("municipio_id")
      .eq("id", userId)
      .maybeSingle();
    if (perfilErr || !perfil) throw new HttpError(500, "Erro ao ler perfil", perfilErr);
    const municipioId = perfil.municipio_id as string;
    const periodo = agregados.periodo as string;
    const hash = await sha256(JSON.stringify(agregados));

    const { data: cache } = await admin
      .from("insights_dashboard")
      .select("hash_agregados, titulo, frases, criado_em")
      .eq("municipio_id", municipioId)
      .eq("periodo", periodo)
      .maybeSingle();

    if (cache && cache.hash_agregados === hash) {
      return jsonResponse(
        { titulo: cache.titulo, frases: cache.frases, gerado_em: cache.criado_em, cache: true },
        200,
        corsHeaders,
      );
    }

    // Só chega aqui quando vai gastar IA: limita a 10 gerações por hora por gestor.
    const { data: dentroDoLimite } = await userClient.rpc("fn_check_rate_limit", {
      p_key: `insight:${userId}`,
      p_max_hits: 10,
      p_window_seconds: 3600,
    });
    if (dentroDoLimite === false) {
      throw new HttpError(429, "Muitas atualizações seguidas. Tente novamente em alguns minutos.");
    }

    const insight = await generateStructured(
      {
        system: SYSTEM,
        user: `Dados agregados do mês (JSON):\n${JSON.stringify(agregados)}`,
        temperature: 0.3,
      },
      validar,
    );

    const geradoEm = new Date().toISOString();
    const { error: upErr } = await admin.from("insights_dashboard").upsert({
      municipio_id: municipioId,
      periodo,
      hash_agregados: hash,
      titulo: insight.titulo,
      frases: insight.frases,
      criado_em: geradoEm,
    });
    if (upErr) console.error("insight-dashboard: falha ao gravar cache", upErr);

    return jsonResponse({ ...insight, gerado_em: geradoEm, cache: false }, 200, corsHeaders);
  } catch (err) {
    return errorResponse(err, corsHeaders);
  }
});
