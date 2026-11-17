---
schema: 2
versionado: true
sensibilidade: normal   # normal | alta (alta = startup/institucional: nunca vai para o git)
backup: true            # false = fora do backup para HD externo
hooks: false
diataxis: false
modulos: [devtrack, decisoes, features, prioridade, estado]
papeis:
  devtrack: devtrack/
  decisoes: decisions/
  features: features/
  prioridade: prioridade/atual.md
  estado: ESTADO.md
  indice: INDEX.md
extras:
  - { path: referencia/, descricao: "Referências: checklists, contas de demo e dados de cenário" }
  - { path: submissao/, descricao: "Material de submissão: documento, roteiro de pitch e apresentação" }
  - { path: telas/, descricao: "Mapa de telas e rotas" }
nomes:
  devtrack: "AAAA-MM-DD - Título"
  decisoes: "NNN - Título"
  features: "NNN - Título"
criado: 2026-11-16
migrado-de: legado
---

# SISAN — Manifesto do vault

Mapa humano do vault. Edite livremente; as skills leem o frontmatter acima.
