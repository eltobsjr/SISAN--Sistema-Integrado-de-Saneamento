---
data: 2026-10-09
---

# Pedido de acesso à informação (LAI) — dados de ocorrências de saneamento

Objetivo: obter dados **reais** de reclamações/solicitações de água e esgoto de
Teresina para alimentar o SISAN (hoje: base de testes interna + 8 casos de
fontes públicas). Não existe base pública com ocorrências individuais
(pesquisa de 09/10/2026, ver `devtrack`).

## Base legal (resumo)

- **Lei 12.527/2011 (LAI):** qualquer pessoa pode pedir, sem justificar o
  motivo (art. 10, §3º). O órgão tem **20 dias** para responder, prorrogáveis
  por mais **10** com justificativa (art. 11, §§1º e 2º). Negativa ou silêncio:
  **recurso em 10 dias** à autoridade superior (art. 15).
- Pedir em **formato aberto** e legível por máquina (art. 8º, §3º): CSV.
- Dados pessoais ficam de fora: pedir já anonimizados (LGPD).
- Confirme as leis em vigor antes de citar no pedido; este arquivo não é
  parecer jurídico.

## Onde protocolar

A LAI vale para órgãos públicos. A **Águas de Teresina** é empresa privada
(subconcessionária), então o caminho é pedir a quem **regula e fiscaliza** e a
quem recebe as reclamações do cidadão:

1. **ARSETE** (agência reguladora de Teresina) — texto A.
2. **Prefeitura de Teresina** (Ouvidoria / canal 156) — texto B.

O canal é o de LAI de cada órgão (e-SIC ou Fala.BR). **Confirme o link no
portal oficial** antes de usar: não verifiquei o endereço atual. Guarde o
número do protocolo e a data (o slide "Próximo passo" só pode dizer que foi
protocolado depois disso).

## Texto A — ARSETE

> **Assunto:** Acesso a dados de reclamações e fiscalização — água e esgoto, Teresina
>
> Com base na Lei nº 12.527/2011, solicito, em formato aberto (CSV ou planilha):
>
> 1. A base de **reclamações/solicitações de usuários** sobre abastecimento de
>    água e esgotamento sanitário recebidas pela ARSETE ou repassadas pela
>    concessionária Águas de Teresina, de **01/01/2023 a 30/09/2026**, com, para
>    cada registro: data de abertura, tipo de problema (ex.: falta d'água,
>    vazamento, esgoto extravasado, qualidade da água), **bairro e logradouro**
>    (ou coordenadas, se existirem), situação (aberta/resolvida), data de
>    resolução e canal de origem.
> 2. Os **indicadores de desempenho do contrato** (incluindo atendimento de
>    esgoto, IN024, e continuidade do abastecimento) por ano, desde 2021.
> 3. Os **relatórios de fiscalização, termos de infração e penalidades**
>    aplicados à concessionária desde 2021, com data e motivo.
>
> Peço que os dados pessoais dos usuários (nome, CPF, telefone, e-mail) sejam
> omitidos ou anonimizados. Os dados serão usados em um projeto cívico de
> monitoramento de saneamento (hackathon "O Piauí que Queremos"), sem fins
> lucrativos. Caso algum item não exista ou não possa ser fornecido, peço que
> informe o motivo e indique o órgão competente.

## Texto B — Prefeitura de Teresina (Ouvidoria/156)

> **Assunto:** Acesso a dados de solicitações sobre água e esgoto
>
> Com base na Lei nº 12.527/2011, solicito, em formato aberto (CSV ou planilha):
>
> 1. As **manifestações e solicitações de serviço** registradas na Ouvidoria/Central
>    156 sobre **água, esgoto e vazamentos**, de **01/01/2023 a 30/09/2026**, com:
>    data, tipo/assunto, **bairro e logradouro**, situação, data de conclusão e
>    órgão ou empresa encaminhado.
> 2. O **total mensal** dessas manifestações por bairro, caso a base individual
>    não possa ser fornecida.
> 3. A indicação de **onde esses dados são publicados** (portal de dados abertos
>    ou transparência), se houver.
>
> Peço a omissão de dados pessoais. Uso: projeto cívico sem fins lucrativos.

## Depois do protocolo

- Anotar protocolo, data e prazo (20 dias + 10) no devtrack.
- Prazo real: a apresentação gravada é em 14/10 e o resultado em 19/10, então a
  resposta **não chega a tempo** da gravação. Usar o pedido como "próximo
  passo", nunca como dado já obtido.
- Se vier CSV: importar com a fonte e a data em cada registro (mesmo padrão do
  `supabase/seed/seed_teresina_fontes_publicas.sql`), sem dados pessoais.
