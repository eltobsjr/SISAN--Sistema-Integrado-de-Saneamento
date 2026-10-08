---
atualizado: 2026-10-07
---

# Prioridades — SISAN

> **07/10/2026: SISAN aprovado entre as 5 finalistas.** Fase final: mentoria
> e Programe Studio 07-13/10, apresentação gravada **14/10**, resultado
> **19/10**. Ver `devtrack/2026-10-07 - SISAN aprovado entre as 5 finalistas.md`.
> Itens abaixo de 21/09 seguem válidos; o foco agora é o pitch.

> Prazo real: submissão do PDF até **23/09/2026**. Documento **enviado em
> 19/09** (`submissao/`, `devtrack/2026-09-19`). Hoje é **21/09/2026**.
>
> **Responsável pelas pendências abaixo: Kassio** (definido pelo Elto em
> 19/09), exceto onde estiver indicado outro nome.
>
> Escopo confirmado (`decisions/010`): os 3 perfis (cidadão/técnico/gestor)
> funcionando de ponta a ponta antes da submissão — não só documento.
> Estado técnico real (confirmado via MCP `supabase-sisan` e código):
> Fases 0-5 **concluídas**. Fase 3 (push): código pronto e mergeado, falta o
> setup manual do OneSignal. Fase 5 (IA): `classify-ocorrencia` e
> `insight-dashboard` em produção com Groq. Fase 6 (campanhas): fora do
> escopo por ora. Código e migrations commitados em `main` até `5df4bfa`;
> ficam sem commit só a documentação desta rodada e `supabase/manual/`.

## Alta

- [ ] **Setup do OneSignal** — *Responsável: Kassio.* Criar o app (gratuito),
      colocar `ONESIGNAL_APP_ID` no `.env` e `ONESIGNAL_REST_API_KEY` como
      secret da Edge Function `notify-push`. Sem isso o push não dispara.
- [ ] **Checkpoint de 21/09** (`decisions/010`) — conferir de novo os 3
      perfis no aparelho depois do design system novo (21/09).

## Média

- [ ] **Leaked password protection** no Auth — botão no Dashboard
      (Authentication → Providers/Policies); pode exigir plano pago.
      *Responsável: Elto.*

## Baixa

- [ ] Tagline/slogan da identidade visual (`decisions/008`) — *decisão da equipe.*

## Descartado (decisão de 21/09)

- Gemini como fallback — não vai ser feito (o PDF cita "dois provedores em
  cascata"; hoje é só Groq).
- Fotos no seed de Teresina.
- Isolamento de working directory pro Antigravity.
- 4º/5º integrante — a equipe fica como está.
- Fase 6 — Campanhas educativas (citada no PDF como fase seguinte).

## Concluído em 21/09

- [x] Chave nova do Groq (Kassio)
- [x] Teste dos 3 perfis num aparelho real (Kassio)
- [x] Hardening: rate limit em `validar_codigo_ativacao_staff` (10/10 min
      por IP, 30/h por município) e bucket `ocorrencias-fotos` limitado a
      10 MB e imagens (migration `20260921120000`)
- [x] Homes de técnico e gestor com bottom nav igual à do cidadão; painel
      do técnico (fila, em andamento, desempenho 30 dias)
- [x] Design system e componentização (`decisions/015`): dashboards dos 3
      perfis, Ordens, Notificações, Alertas e detalhe da OS redesenhados
- [x] E-mails de demo simplificados (`gestor1@sisan.com` etc.)
- [x] Branches antigas apagadas (local e remoto) — tudo já estava na `main`

## Concluído em 19/09

- [x] Documento de submissão escrito e enviado (ADS / IFPI Picos; líder Elto)
- [x] Fase 5 — IA em produção (Groq): `classify-ocorrencia`, `insight-dashboard`
- [x] Rate limit (ocorrências 10/h e 30/dia; insight 10/h; código de equipe 5/h)
- [x] Seed de Teresina (2 gestores, 3 técnicos, 4 cidadãos, 65 ocorrências)
- [x] Tela "Meu município" do gestor
- [x] PostGIS movido para `extensions`

## Plano dia a dia (referência)

| Dia | Data | Foco |
|---|---|---|
| 1 | 17/09 | Fases 0-4 do app, fila offline, retrofit visual — tudo commitado |
| 2 | 18/09 | Wizard de Nova Ocorrência + Fase 3 (push) |
| 3 | 19/09 | Documento de submissão enviado + Fase 5 (IA) + rate limit + seed + PostGIS |
| 4 | 20/09 | OneSignal, chave nova do Groq e teste dos 3 perfis num aparelho real (Kassio) |
| 5 | 21/09 | **Checkpoint de risco** (`decisions/010`) |
| 6 | 22/09 | Folga de segurança / Gemini / hardening |
| — | 23/09 | Prazo final da submissão |

## Depois de garantida a submissão (se sobrar tempo até 07/10 — finalistas)

Só as 5 equipes selecionadas ganham mentoria e acesso ao Programe Studio
para o pitch (07 a 13/10). Se formos selecionados, é quando vale investir
além do que já estiver funcionando — não antes.

---

*Atualizado em 19/09/2026 ao fim da sessão. Detalhes em
`devtrack/2026-09-19 - Documento de submissão, IA em produção, seed de
Teresina e rate limit.md`.*
