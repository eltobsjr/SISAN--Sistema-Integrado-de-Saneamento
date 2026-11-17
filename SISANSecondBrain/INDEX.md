---
tipo: indice
gerado: 2026-11-16
gerado-por: scripts/build_index.py
---

# Índice — SISAN

> Gerado automaticamente. **Não edite**; rode `build_index.py` (o `/devtrack` já faz isso).
> Mapa de pastas e regras do vault: [[_secondbrain]]. Retrato atual: [[ESTADO]].

## Raiz do vault

- [[CHECKLIST]]
- [[Contexto de Criação do Projeto]]
- [[ESTADO]]
- [[Roadmap]]
- [[SISAN — Visão Geral]]

## Devtracks (22)
`devtrack/`

- [[devtrack/2026-10-14 - Mentoria da Flávia, deck v2 com QR e envios]] — 14/10 (madrugada): orientações da Flávia, deck v2 com QR code e envios · devtrack · 2026-10-14
- [[devtrack/2026-10-13 - Priorização por risco, confirmações e avaliação da resolução]] · devtrack · 2026-10-13
- [[devtrack/2026-10-13 - APK release testado no celular e correções de produção]] · devtrack · 2026-10-13
- [[devtrack/2026-10-09 - Refinamento visual e gráficos novos]] — 09/10 — Refinamento visual e gráficos novos · devtrack · 2026-10-09
- [[devtrack/2026-10-09 - Redesign login e cadastro, pitch de 2 minutos e seed de fontes públicas]] · devtrack · 2026-10-09
- [[devtrack/2026-10-07 - SISAN aprovado entre as 5 finalistas]] — 07/10 — SISAN aprovado entre as 5 finalistas · devtrack · 2026-10-07
- [[devtrack/2026-09-21 - Hardening, homes com navbar e design system]] — 21/09 — Hardening, homes com navbar e design system · devtrack · 2026-09-21
- [[devtrack/2026-09-19 - Documento de submissão, IA em produção, seed de Teresina e rate limit]] · devtrack · 2026-09-19
- [[devtrack/2026-09-18 - Onboarding guiado de Nova Ocorrência, GPS no mapa e correção do ícone]] · devtrack · 2026-09-18
- [[devtrack/2026-09-18 - Fase 3 push via OneSignal, realinhamento de prioridades e incidente com o Antigravity]] · devtrack · 2026-09-18
- [[devtrack/2026-09-17 - Setup do SecondBrain e mapeamento de reaproveitamento]] · devtrack · 2026-09-17
- [[devtrack/2026-09-17 - Retrofit visual das telas de Fase 0 e 1 pro padrão SIGAU]] · devtrack · 2026-09-17
- … mais 10 notas em `devtrack/` (as mais recentes acima)

## Decisões (16)
`decisions/`

- [[decisions/001 - Nome provisório SIGESAN (superseded)]] — 001 — Nome provisório: SISAN · decisao · 2026-09-17 · provisório
- [[decisions/002 - Stack herdada do SIGAU]] — 002 — Stack herdada do SIGAU: Flutter + Supabase + Riverpod · decisao · 2026-09-17 · aprovado
- [[decisions/003 - Multi-tenancy por município com concessionária associada]] · decisao · 2026-09-17 · aprovado
- [[decisions/004 - Edge Functions de IA no padrão do polimata-concursos]] — 004 — Edge Functions de IA no padrão do polimata-concursos (não do SIGAU) · decisao · 2026-09-17 · aprovado
- [[decisions/005 - Checklist e evidências no encerramento da Ordem de Serviço]] — 005 — Checklist obrigatório + evidências para encerrar Ordem de Serviço · decisao · 2026-09-17 · aprovado
- [[decisions/006 - Sem coautoria do Claude em commits]] — 006 — Sem Claude como coautor em commits · decisao · 2026-09-17 · aprovado
- [[decisions/007 - Nome definitivo SISAN]] · decisao · 2026-09-17 · aprovado — substitui decisions/001
- [[decisions/008 - Identidade visual Água Viva]] — 008 — Identidade visual: "Água Viva" (azul/ciano + gota) · decisao · 2026-09-17 · aprovado
- [[decisions/009 - Município piloto Picos]] — 009 — Município piloto para o pitch: Picos (Águas do Piauí) · decisao · 2026-09-17 · aprovado
- [[decisions/010 - Escopo do protótipo os 3 perfis ponta a ponta]] — 010 — Escopo do protótipo: os 3 perfis funcionando ponta a ponta até 23/09 · decisao · 2026-09-17 · aprovado
- [[decisions/011 - Repositório público compartilhado e SecondBrain versionado]] — 011 — Repositório no GitHub, SecondBrain versionado (não gitignorado) · decisao · 2026-09-17 · aprovado
- [[decisions/012 - Credenciais Supabase e tratamento da service_role key]] — 012 — Credenciais do projeto Supabase e tratamento da service_role key · decisao · 2026-09-17 · aprovado
- [[decisions/013 - IA com provedor único Groq e rate limit por usuário]] — 013 — IA só com Groq por enquanto, e rate limit por usuário · decisao · 2026-09-19 · aprovado
- [[decisions/014 - PostGIS fora do schema public]] — 014 — Mover o PostGIS para o schema `extensions` · decisao · 2026-09-19 · aprovado e aplicado em 19/09/2026
- [[decisions/015 - Design system e componentização]] — 015 — Design system e componentização como base da UI · decisao · 2026-09-21 · aceita
- [[decisions/016 - SISAN como complemento ao sistema da concessionária, piloto antes da integração]] · decisao · 2026-10-14 · aceita

## Features (9)
`features/`

- [[features/001 - Ocorrências]] — 001 — Ocorrências (fork de `denuncias` do SIGAU) · feature · 2026-09-17 · planejada
- [[features/002 - Ordens de Serviço]] — 002 — Ordens de Serviço (fork de `resgates` do SIGAU + checklist do Confia) · feature · 2026-09-17 · planejada
- [[features/003 - Alertas Sanitários]] — 003 — Alertas Sanitários (fork de `zoonoses` do SIGAU) · feature · 2026-09-17 · planejada
- [[features/004 - Dashboard da Concessionária]] — 004 — Dashboard da Concessionária (fork de `dashboard` do SIGAU) · feature · 2026-09-17 · planejada
- [[features/005 - Campanhas Educativas]] — 005 — Campanhas Educativas (fork de `campanhas` do SIGAU) · feature · 2026-09-17 · planejada
- [[features/006 - Classificação por IA]] — 006 — Classificação por IA (`classify-ocorrencia`) · feature · 2026-09-17 · implementada (Groq; Gemini como fallback futuro)
- [[features/007 - Documento de Submissão do Edital]] · feature · 2026-09-17 · em andamento — rascunho v1 em submissao/
- [[features/008 - Resumo Executivo por IA no Dashboard]] — 006 — Resumo Executivo por IA no Dashboard (`insight-dashboard`) · feature · 2026-09-17 · implementada (Groq; Gemini como fallback futuro)
- [[features/009 - Meu município do gestor]] · feature · 2026-09-19 · implementada

## Prioridades (1)
`prioridade/atual.md`

- [[prioridade/atual]] — Prioridades — SISAN · prioridade

## referencia — Referências: checklists, contas de demo e dados de cenário (6)
`referencia/`

- [[referencia/checklist-apk-release-android]] — Checklist: APK release Android do SISAN · checklist · 2026-10-13
- [[referencia/contas-de-demo-teresina]] — Contas e dados de demonstração — Teresina · nota · 2026-09-19
- [[referencia/dados-teresina-cenario]] — Dados de Teresina usados no slide "Cenário" (e suas fontes) · nota · 2026-10-14
- [[referencia/erros-herdados-do-sigau]] — Erros já resolvidos no SIGAU — não repetir aqui · nota
- [[referencia/pedido-lai-dados-ocorrencias]] — Pedido de acesso à informação (LAI) — dados de ocorrências de saneamento · nota · 2026-10-09
- [[referencia/reaproveitamento-por-projeto]] — O que reaproveitar de cada projeto · nota

## submissao — Material de submissão: documento, roteiro de pitch e apresentação (2)
`submissao/`

- [[submissao/Documento de Submissão - SISAN]] — SISAN — Sistema Integrado de Saneamento · nota · 2026-09-18 · rascunho v1 — pendente revisão da equipe
- [[submissao/roteiro-pitch-2min]] — Roteiro do pitch — 2 minutos, 2 apresentadores · nota · 2026-10-13

## telas — Mapa de telas e rotas (1)
`telas/`

- [[telas/00 - Índice de telas]] — Índice de telas — SISAN · nota
