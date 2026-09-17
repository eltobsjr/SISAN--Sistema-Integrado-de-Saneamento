---
data: 2026-09-17
---

# SISAN — Visão Geral

## O que é

Proposta para o Hackathon "O Piauí que Queremos" (Cidade Verde + Movimento
Saneamento Salva + Águas do Piauí / Águas de Teresina / Águas de Timon +
Programe Studio, tema saneamento — abastecimento de água potável e
esgotamento sanitário, submissão até 23/09/2026).

**SISAN** (Sistema Integrado de Saneamento) é um app de três perfis:

- **Cidadão**: denuncia vazamento, esgoto a céu aberto, falta d'água ou água
  contaminada com foto + GPS, acompanha o status pelo protocolo.
- **Técnico da concessionária**: recebe a ordem de serviço, aceita, chega ao
  local, resolve e registra evidências (checklist obrigatório + fotos).
- **Gestor da concessionária/prefeitura**: dashboard com priorização por
  risco, mapa de calor, alertas sanitários (correlação com indicadores de
  saúde) e relatório em PDF.

Não é um projeto do zero: reaproveita arquitetura e padrões já validados nos
outros projetos do usuário — ver `referencia/reaproveitamento-por-projeto.md`.

## Stack técnica

| Tecnologia | Detalhe |
|---|---|
| Flutter + Dart | mobile (Android/iOS) + web dashboard, um único código-fonte |
| Supabase | Auth, Postgres + PostGIS, Storage, Realtime, Edge Functions (Deno) |
| Riverpod 2.x | `AsyncNotifier`, Clean Architecture por feature |
| flutter_map + OpenStreetMap | mapas, sem billing do Google |
| OneSignal | push via `external_id` |
| drift (SQLite local) | offline-first, fila de sincronização |
| IA nas Edge Functions | Groq → Gemini fallback, JSON schema estruturado, cota diária — padrão do `polimata-concursos` |

## Como rodar

Projeto ainda greenfield — nenhum `pubspec.yaml` criado ainda. Primeiro passo
de implementação: `flutter create` + configurar dependências (ver
`prioridade/atual.md`).

## Estrutura de pastas principais (planejada)

```
lib/
├── core/          # supabase client, router, theme, constants
├── features/
│   ├── auth/                # cidadão / técnico / gestor
│   ├── ocorrencias/         # fork de denuncias do SIGAU
│   ├── ordens_de_servico/   # fork de resgates do SIGAU + verificação do Confia
│   ├── alertas_sanitarios/  # fork de zoonoses do SIGAU
│   ├── dashboard/           # fork de dashboard do SIGAU
│   ├── campanhas/           # fork de campanhas do SIGAU
│   ├── mapa/
│   └── notificacoes/
└── shared/
supabase/
├── migrations/
└── functions/
    ├── classify-ocorrencia/   # IA — tipo/urgência/risco à saúde por denúncia
    ├── insight-dashboard/     # IA — resumo executivo dos agregados mensais pro gestor
    ├── notify-*/              # push, fork do SIGAU
    └── _shared/               # provider.ts, quota.ts, errors.ts — padrão do polimata-concursos
```

## Estado atual

Setup inicial do SecondBrain realizado em 2026-09-17. Nenhum código Flutter
escrito ainda — projeto greenfield. Documento de submissão do edital (PDF de
8 seções) ainda não escrito. Equipe do hackathon ainda não registrada — ver
pendência em `prioridade/atual.md`.
