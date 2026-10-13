---
data: 2026-10-13
---

# Apresentação do pitch (2 minutos)

Cópia de segurança do deck publicado como Artifact (link privado do Claude):
https://claude.ai/artifact/LDsDaXDDRChhshc9YHrMRw

- `deck.json`: índice do deck (ordem dos slides, seções e fontes).
- `slides/*.html`: um arquivo por slide. As imagens apontam para `/_blob/<id>`
  (assets do Artifact), então **não aparecem se o HTML for aberto fora dele**.
- `telas/*.jpg`: os prints reais usados nos slides, capturados em 13/10/2026 da
  versão web do app (Playwright, viewport 412×892 a 2x, contas de demonstração).
  Pra recriar o deck, suba essas imagens de novo como assets e troque os `/_blob/`.
- `gerar.py`: script que gerou os slides (paleta, tipografia e componentes num
  lugar só). Ele escreve em `project/slides/`, a estrutura do Artifact.
- Roteiro para duas pessoas: [`../roteiro-pitch-2min.md`](../roteiro-pitch-2min.md).
- `pdf/`: `SISAN-pitch.pdf` (só os 8 slides do pitch) e
  `SISAN-roteiro-pitch-2min.pdf` (uma página A4), mais os geradores `pdf.py` e
  `roteiro.html`. O PDF do deck é montado localmente com o Chrome, não pela
  exportação do Artifact.
- `captura/`: scripts Playwright que tiraram os prints. Eles leem a senha de demo
  de `SENHA_DEMO` (nunca no código) e esperam a build web servida em
  `localhost:8099`; a saída vai para `build/pw/shots/`.

## Visual (13/10/2026)

- Títulos e números em **Bricolage Grotesque**; texto em **DM Sans**.
- Azul-noite `#0B2235` e papel `#F4F2EC` alternando; âmbar `#F3A43F` como
  destaque de risco e prioridade (o slide "prioridade" é o slide de destaque).
- Telas em moldura de celular escura com sombra.

## Ordem

Pitch (8 slides): `cover`, `oficial`, `fluxo`, `telas`, `prioridade`, `mapa`,
`tecnologia`, `fim`.

Apêndice escondido (para perguntas): `perfis`, `cidadao`, `tecnico`, `gestor`,
`corrigir` ("E se a IA errar?"), `j1` a `j6` (jornada de uma ocorrência),
`dados`, `fontes`, `proximo`.

## Mapa de imagens

| Arquivo | Tela | Slides |
|---|---|---|
| `login.jpg`, `cadastro.jpg` | Login e criar conta | perfis |
| `cid_home.jpg` | Início do cidadão | cover, telas |
| `cid_tipo.jpg`, `cid_local.jpg` | Nova ocorrência: tipo e local | cidadao, j1 |
| `cid_proximas.jpg` | Aviso de relato parecido a 21 m (confirmar) | mapa, j2 |
| `cid_mapa.jpg` | Mapa de Teresina | mapa |
| `cid_avaliacao.jpg` | "O problema foi resolvido?" | fim, j6 |
| `tec_home.jpg`, `tec_ordens.jpg` | Técnico: início e fila por prioridade | telas, tecnico |
| `tec_os.jpg`, `tec_os_prioridade.jpg` | Ordem de serviço e sua prioridade | tecnico, j4 |
| `ges_home.jpg`, `ges_alertas.jpg` | Gestor: início e alertas sanitários | telas, gestor |
| `ges_painel.jpg` | Painel com "Prioridades de hoje" | cover, prioridade, j5 |
| `ges_classificacao.jpg`, `ges_corrigir.jpg` | Classificação da IA e correção | corrigir, j3 |

## Regra sobre os dados

Os registros simulados se chamam **"base de testes interna"** nos slides, nunca
"pesquisa". Os 8 casos de fonte pública citam veículo e data. Ver
`../../referencia/pedido-lai-dados-ocorrencias.md` e o seed
`supabase/seed/seed_teresina_fontes_publicas.sql`.
