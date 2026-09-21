---
data: 2026-09-19
---

# Contas e dados de demonstração — Teresina

Seed **fictício** em `supabase/seed/seed_demo_teresina.sql` (idempotente: se
Teresina já existir, não faz nada). Nomes, endereços e relatos são inventados;
as coordenadas são aproximadas por bairro só pra o mapa ficar plausível.

## Contas (município Teresina — Águas de Teresina)

| Perfil | E-mail | Nome |
|---|---|---|
| Gestor | `gestor1@sisan.com` | Marcos Vinícius Andrade |
| Gestor | `gestor2@sisan.com` | Renata Cavalcante Lima |
| Técnico | `tecnico1@sisan.com` | José Ribamar Sousa |
| Técnico | `tecnico2@sisan.com` | Antônio Carlos Nogueira |
| Técnico | `tecnico3@sisan.com` | Francisco das Chagas Pereira |
| Cidadão | `cidadao1@sisan.com` | Maria do Socorro Silva |
| Cidadão | `cidadao2@sisan.com` | Ana Beatriz Rocha |
| Cidadão | `cidadao3@sisan.com` | Carlos Eduardo Moura |
| Cidadão | `cidadao4@sisan.com` | Luciana Fontenele Araújo |

**A senha não está no repositório** (o repo é público). Ela foi
redefinida em 21/09 e está com o Elto. O arquivo `.sql` usa o placeholder
`__SENHA_DEMO__`, que deve ser substituído na hora de rodar. O código de ativação de equipe de Teresina
é aleatório: o gestor o vê em "Meu município".

## O que o seed cria

- 65 ocorrências entre abril e setembro de 2026 (6, 8, 10, 12, 15, 14 por
  mês), em 9 bairros; Dirceu Arcoverde, Santa Maria da Codipi e Mocambinho
  concentram esgoto e água contaminada perto de escola (alimenta o insight).
- Urgência e risco à saúde **pré-preenchidos** (no app real vêm da IA).
- Ordens de serviço em todos os estados (`pendente`, `aceita`, `a_caminho`,
  `concluida`), com checklist dos itens de `checklist_encerramento.dart`;
  quanto mais antiga a ocorrência, maior a chance de estar concluída.
- 6 alertas sanitários (4 ativos, 2 encerrados), 29 notificações.
- **Sem fotos** (não há imagens no storage): ocorrências e evidências do
  "depois" aparecem sem foto.

## Como aplicar de novo

O seed desliga temporariamente os triggers de IA, push e notificação (senão
dispararia dezenas de chamadas) e os religa no fim; se abortar, o rollback
devolve tudo. Para recomeçar, apague o município Teresina e seus dados
(destrutivo — confirmar antes) e rode o arquivo de novo.
