---
data: 2026-09-17
status: aprovado
---

# 002 — Stack herdada do SIGAU: Flutter + Supabase + Riverpod

**Contexto:** o SIGAU (projeto do amigo do usuário) é um SaaS multi-tenant
maduro — 43 migrations, 64/64 testes, beta real em produção em Picos-PI —
resolvendo um problema com a mesma forma (cidadão denuncia com foto+GPS →
operador atende em campo → gestor prioriza no dashboard), só que para animais
urbanos em vez de saneamento. Reescrever essa arquitetura do zero em 6 dias
seria desperdiçar o maior ativo disponível.

**Decisão:** adotar a stack do SIGAU integralmente:
- Flutter + Dart para mobile e web dashboard (sem React/Next.js)
- Supabase como backend completo: Auth, Postgres + PostGIS, Storage,
  Realtime, Edge Functions em Deno/TypeScript (sem Node.js standalone)
- Riverpod 2.x (`AsyncNotifier`) para estado
- Clean Architecture por feature (`data/domain/presentation`)
- `flutter_map` + OpenStreetMap para mapas (nunca Google Maps — SIGAU já
  aprendeu essa lição em SGAU-005→SGAU-008, billing indesejado)
- OneSignal para push, sempre via `external_id` (nunca filtro por tag — ver
  `referencia/erros-herdados-do-sigau.md`, ERR-017)
- drift (SQLite local) + fila de sincronização para offline-first

**Motivo:** stack validada, gratuita, sem infraestrutura própria pra manter,
e com um catálogo de 44 erros já resolvidos que não precisamos redescobrir.

**Impacto:** toda a codebase segue as mesmas convenções do SIGAU. Novo
`pubspec.yaml` espelha as dependências do SIGAU, trocando `google_maps_flutter`
por já ir direto com `flutter_map`.

**Não fazer:** não introduzir Node.js/Express standalone, Firebase, MongoDB,
Redis separado ou Google Maps. Ver `referencia/erros-herdados-do-sigau.md`
antes de mexer em RLS, Edge Functions, mapas, push ou PDF.
