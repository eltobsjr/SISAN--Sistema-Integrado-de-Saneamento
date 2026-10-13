---
data: 2026-10-09
---

# Apresentação do pitch (2 minutos)

Cópia de segurança do deck publicado como Artifact (link privado do Claude):
https://claude.ai/artifact/LDsDaXDDRChhshc9YHrMRw

- `deck.json` — índice do deck (ordem dos slides e seções).
- `slides/*.html` — um arquivo por slide. As imagens apontam para `/_blob/<id>`
  (assets do Artifact), então **não aparecem se o HTML for aberto fora dele**.
- `telas/*.jpg` — os prints reais usados nos slides (capturados da versão web
  do app em 09/10/2026, com as contas de demonstração). Para recriar o deck,
  suba essas imagens de novo como assets e troque os `/_blob/` pelos novos.
- Roteiro para duas pessoas: [`../roteiro-pitch-2min.md`](../roteiro-pitch-2min.md).

## Ordem

Pitch (7 slides): `cover`, `oficial`, `fluxo`, `telas`, `mapa`, `tecnologia`, `fim`.

Apêndice escondido (para perguntas): `perfis`, `cidadao`, `tecnico`, `gestor`,
`j1` a `j5` (jornada de uma ocorrência), `dados`, `fontes`, `proximo`.

## Mapa de imagens

| Arquivo | Tela |
|---|---|
| `login.jpg`, `cadastro.jpg` | Login e criar conta |
| `cid_home.jpg`, `cid_registrar.jpg`, `cid_mapa.jpg` | Cidadão: início, registrar, mapa |
| `tec_home.jpg`, `tec_ordens.jpg` | Técnico: início e ordens de serviço |
| `ges_home.jpg`, `ges_painel.jpg` | Gestor: início e painel |
| `j_detalhe.jpg`, `j_notif.jpg`, `j_os.jpg`, `j_alertas.jpg` | Jornada: detalhe, notificações, ordem de serviço, alertas |
| `j_minhas.jpg` | Minhas ocorrências do cidadão (capturada, não usada em nenhum slide) |

## Regra sobre os dados

Os registros simulados se chamam **"base de testes interna"** nos slides, nunca
"pesquisa". Os 8 casos de fonte pública citam veículo e data. Ver
`../../referencia/pedido-lai-dados-ocorrencias.md` e o seed
`supabase/seed/seed_teresina_fontes_publicas.sql`.
