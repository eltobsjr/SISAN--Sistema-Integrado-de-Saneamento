// Camada de provedor de IA com saída estruturada (JSON).
//
// Hoje só o Groq está ativo. O Gemini fica como fallback futuro: basta
// implementar `callGemini`, registrá-lo em `CALLERS` e passar
// ["groq", "gemini"] em `generateStructured` — os chamadores não mudam.
import { HttpError } from "./errors.ts";

export type ProviderName = "groq";

export interface StructuredParams {
  system: string;
  user: string;
  temperature?: number;
}

// Em ordem de preferência. Nem todo modelo está liberado em toda conta do
// Groq: se um vier com `model_not_found`, tenta o próximo da lista.
const GROQ_MODELS = ["llama-3.3-70b-versatile", "openai/gpt-oss-20b", "llama-3.1-8b-instant"];
const TIMEOUT_MS = 20_000;

async function callGroq(params: StructuredParams): Promise<string> {
  const key = Deno.env.get("GROQ_API_KEY");
  if (!key) throw new HttpError(503, "IA indisponível", "GROQ_API_KEY não configurada");

  let res!: Response;
  for (const model of GROQ_MODELS) {
    res = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${key}` },
      signal: AbortSignal.timeout(TIMEOUT_MS),
      body: JSON.stringify({
        model,
        temperature: params.temperature ?? 0.1,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: params.system },
          { role: "user", content: params.user },
        ],
      }),
    });
    if (res.status !== 404) break;
    console.error(`Groq: modelo ${model} indisponível (404), tentando o próximo`);
  }

  if (!res.ok) {
    // Status + código de erro do provedor vão pro chamador (diagnóstico; o
    // corpo do erro do Groq não carrega chave nem payload). O corpo inteiro
    // fica no log.
    const raw = await res.text();
    const code = (() => {
      try {
        return JSON.parse(raw)?.error?.code ?? "";
      } catch {
        return "";
      }
    })();
    throw new HttpError(502, `Falha no provedor de IA (groq ${res.status} ${code})`.trim(), raw);
  }
  const data = await res.json();
  const content = data?.choices?.[0]?.message?.content;
  if (typeof content !== "string") {
    throw new HttpError(502, "Resposta inválida do provedor de IA", data);
  }
  return content;
}

const CALLERS: Record<ProviderName, (p: StructuredParams) => Promise<string>> = {
  groq: callGroq,
};

/// Tenta cada provedor na ordem; devolve o primeiro resultado que passa em
/// `validate` (que deve lançar se o JSON não bater com o schema esperado).
export async function generateStructured<T>(
  params: StructuredParams,
  validate: (raw: unknown) => T,
  providers: ProviderName[] = ["groq"],
): Promise<T> {
  let lastError: unknown;
  for (const name of providers) {
    try {
      const text = await CALLERS[name](params);
      return validate(JSON.parse(text));
    } catch (err) {
      lastError = err;
      console.error(`Provedor ${name} falhou:`, err);
    }
  }
  if (lastError instanceof HttpError) throw lastError;
  throw new HttpError(502, "Falha no provedor de IA", lastError);
}
