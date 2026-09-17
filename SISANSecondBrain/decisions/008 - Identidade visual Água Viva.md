---
data: 2026-09-17
status: aprovado
---

# 008 — Identidade visual: "Água Viva" (azul/ciano + gota)

**Contexto:** precisávamos de uma direção visual antes de desenhar qualquer
tela ou ícone de app, entre 3 estilos apresentados (água/limpo, ligado à
marca "Saneamento Salva", ou "radar de risco" mais tech).

**Decisão:** paleta em tons de azul/ciano remetendo a água limpa, com a gota
como elemento gráfico central (ícone do app, splash, marcadores do mapa).

**Cores propostas** (ponto de partida, ajustável ao implementar):
- Primária: `#0288D1` (azul água)
- Secundária/escura: `#01579B` (azul profundo, headers/AppBar)
- Fundo claro: `#E1F5FE`
- **Cores semânticas de urgência continuam separadas da marca** (herdadas do
  padrão `DenunciaUrgencia` do SIGAU): verde = normal, laranja = atenção,
  vermelho = risco à saúde — nunca substituir por tons de azul, senão perde
  a leitura rápida no mapa.

**Motivo:** visual limpo e institucional, fácil de reconhecer num ícone
pequeno, e não compete com as cores semânticas de urgência que já são
vermelho/laranja/verde — manter azul como identidade de marca evita conflito
de leitura no mapa (que é a peça central da demo).

**Impacto:** `lib/core/theme/app_theme.dart` (quando o projeto Flutter for
criado), ícone do app, splash.

**Pendente:** tagline/slogan para o pitch ainda não escolhido — sugestão a
validar: algo em torno de "a água tem voz" ou "cada gota conta", mas não
decidido ainda.
