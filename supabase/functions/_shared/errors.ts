// Erro seguro pra devolver ao chamador: `publicMessage` nunca carrega detalhe
// de provedor, chave ou payload — o detalhe cru vai só pro console.error.
export class HttpError extends Error {
  constructor(
    public status: number,
    public publicMessage: string,
    detail?: unknown,
  ) {
    super(publicMessage);
    if (detail !== undefined) console.error(`HttpError ${status}:`, detail);
  }
}

// CORS pras funções chamadas direto do app (Flutter web). As funções
// internas, chamadas só pelo Postgres, simplesmente ignoram.
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function jsonResponse(body: unknown, status = 200, extraHeaders: HeadersInit = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...extraHeaders },
  });
}

export function errorResponse(err: unknown, extraHeaders: HeadersInit = {}): Response {
  if (err instanceof HttpError) {
    return jsonResponse({ error: err.publicMessage }, err.status, extraHeaders);
  }
  console.error("Erro inesperado:", err);
  return jsonResponse({ error: "Erro interno" }, 500, extraHeaders);
}
