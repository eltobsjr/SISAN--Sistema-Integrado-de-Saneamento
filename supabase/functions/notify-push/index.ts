// Edge Function genérica de push: dispara pra QUALQUER INSERT na tabela
// `notificacoes` (nova_os, status_os, alerta_sanitario — e o que mais vier),
// chamada pelo trigger `trg_enviar_push_notificacao` via pg_net.
//
// Autenticação: não usa o JWT padrão do Supabase (a chamada vem do
// Postgres, não de um usuário logado) — usa um segredo compartilhado
// (`x-notify-secret`) guardado no Vault do lado do banco e como secret da
// função do lado do Deno. Por isso o deploy precisa de `verify_jwt: false`.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID");
const ONESIGNAL_REST_API_KEY = Deno.env.get("ONESIGNAL_REST_API_KEY");
const NOTIFY_INTERNAL_SECRET = Deno.env.get("NOTIFY_INTERNAL_SECRET");

interface NotificacaoPayload {
  usuario_id?: string;
  titulo?: string;
  corpo?: string;
  dados?: Record<string, unknown>;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const receivedSecret = req.headers.get("x-notify-secret");
  if (!NOTIFY_INTERNAL_SECRET || receivedSecret !== NOTIFY_INTERNAL_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  const payload = (await req.json().catch(() => null)) as NotificacaoPayload | null;
  const usuarioId = payload?.usuario_id;
  const titulo = payload?.titulo;
  const corpo = payload?.corpo;

  if (!usuarioId || !titulo || !corpo) {
    return new Response("Payload inválido", { status: 400 });
  }

  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
    console.error("notify-push: ONESIGNAL_APP_ID/ONESIGNAL_REST_API_KEY não configurados — pulando push");
    return new Response(JSON.stringify({ skipped: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }

  const oneSignalRes = await fetch("https://onesignal.com/api/v1/notifications", {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      // Segmentação sempre por external_id (nunca tags — lição SIGAU).
      Authorization: `Basic ${ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: ONESIGNAL_APP_ID,
      include_aliases: { external_id: [usuarioId] },
      target_channel: "push",
      // A chave `en` é obrigatória mesmo num app 100% português — o
      // OneSignal rejeita o payload sem ela.
      headings: { en: titulo },
      contents: { en: corpo },
      data: payload?.dados ?? {},
    }),
  });

  if (!oneSignalRes.ok) {
    console.error("notify-push: OneSignal respondeu", oneSignalRes.status, await oneSignalRes.text());
  }

  // Sempre 200 pro chamador (pg_net) — falha de push não deve gerar retry
  // nem aparecer como erro de banco; o log acima já registra o problema.
  return new Response(JSON.stringify({ ok: oneSignalRes.ok }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
