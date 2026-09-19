---
data: 2026-09-18
status: rascunho v1 — pendente revisão da equipe
prazo: 2026-09-23
---

# SISAN — Sistema Integrado de Saneamento

**Hackathon "O Piauí que Queremos"** — desafio: abastecimento de água potável e esgotamento sanitário.

**Equipe:** estudantes de Análise e Desenvolvimento de Sistemas (ADS) do IFPI, campus Picos

- Elto Borges dos Santos Junior (líder designado)
- Kassio de Sousa Dias
- Evillyn Kelle Ibiapina Costa

---

## 1. Título do Projeto

**SISAN — Sistema Integrado de Saneamento: do chamado do cidadão à decisão do gestor, com risco sanitário no centro.**

---

## 2. Resumo Executivo

Grande parte dos problemas de água e esgoto chega à concessionária de forma dispersa: um telefonema, uma mensagem, um relato sem localização precisa. Quem repara não sabe o que é mais urgente para a saúde das pessoas, e quem gere não enxerga o padrão por trás dos chamados isolados.

O SISAN é um aplicativo (celular e web, um único código-fonte) com três perfis integrados. O **cidadão** denuncia vazamento, esgoto a céu aberto, falta d'água, água contaminada ou baixa pressão em poucos passos guiados, com foto e localização no mapa, e acompanha o protocolo até a solução. O **técnico** da concessionária recebe a ordem de serviço, registra a chegada e só conclui após checklist obrigatório e foto do "depois", mesmo sem sinal, pois o app funciona offline e sincroniza depois. O **gestor** vê os dados do mês, o mapa de calor por tipo de problema, recebe alertas sanitários quando ocorrências se acumulam e exporta relatório em PDF. Uma camada de inteligência artificial classifica a urgência e o risco à saúde e resume os padrões do mês em linguagem simples.

O protótipo já existe e funciona: três perfis, banco com isolamento por município, notificações push, relatório em PDF e as duas funções de inteligência artificial. O piloto proposto é Picos, atendida pela Águas do Piauí, replicável a qualquer município sem novo desenvolvimento.

O SISAN não constrói redes nem estações de tratamento. Faz com que cada denúncia vire uma ação comprovada e que a prioridade seja definida por risco à saúde, acelerando a meta do Marco Legal do Saneamento e devolvendo ao cidadão a certeza de ter sido ouvido.

---

## 3. Problema Identificado

**O contexto.** A Lei nº 14.026/2020 (Marco Legal do Saneamento) fixou a meta de que, até 2033, 99% da população brasileira tenha acesso a água tratada e 90% à coleta e tratamento de esgoto [1]. Em 2025, segundo o Instituto Água e Saneamento com base no SNIS/SINISA, 83,1% da população brasileira tinha acesso à rede de água e 59,7% ao esgotamento sanitário [2].

**O Piauí.** A Águas do Piauí, que passou a operar em municípios do estado a partir de 2025, informa que a coleta e o tratamento de esgoto no estado estão hoje em cerca de 17%, e assumiu o compromisso de chegar a 99% de água até 2033 e a 90% de esgoto até 2040 [3]. É uma trajetória de anos de obras. Até lá, os problemas do dia a dia (vazamentos, extravasamentos de esgoto, falta d'água, água turva) continuam acontecendo, e a população convive com eles.

**A consequência para a saúde.** A falta de água segura e de saneamento adequado está associada, segundo a ONU, a cerca de 1,4 milhão de mortes por ano no mundo por infecções ligadas a água contaminada e saneamento inadequado [4]. Esgoto a céu aberto e água contaminada são o caminho direto para diarreias e outras doenças de veiculação hídrica.

**O problema que o SISAN ataca.** Enquanto a infraestrutura definitiva não chega, o que separa "um problema" de "um risco sanitário" é informação: onde, com que frequência, perto de quê (escola, posto de saúde, criança pequena). Nossa leitura, como usuários e desenvolvedores, é que:

1. o cidadão não tem um canal que devolva protocolo, status e prova de que o reparo foi feito;
2. o técnico precisa de uma fila georreferenciada, que funcione em área de sinal ruim, e de um registro que comprove o atendimento;
3. o gestor precisa enxergar padrões (reincidência por bairro, tipo e urgência) para priorizar o que protege a saúde primeiro, e não apenas o que foi reclamado por último ou com mais insistência.

Esse é um problema de gestão da informação, que software resolve bem e a baixo custo.

**Recorte piloto: Picos-PI.** Escolhemos Picos, município atendido pela Águas do Piauí, onde já temos experiência com outro sistema de denúncia cidadã georreferenciada (o SIGAU, de animais urbanos, com beta em uso real). A arquitetura do SISAN parte do que esse projeto já validou: fluxo cidadão → operador em campo → gestor, mapas, push e operação offline.

**Fora do escopo, conforme o edital:** limpeza urbana, resíduos sólidos e drenagem pluvial.

---

## 4. Solução Proposta

O SISAN é um sistema único com três perfis, com acesso por papel e dados isolados por município.

### 4.1 Cidadão — denunciar e acompanhar
- **Nova Ocorrência guiada, uma pergunta por vez** (tipo → local → relato → fotos → revisão), com barra de progresso e botão de voltar. Pensada para acessibilidade e para quem nunca usou app de serviço público.
- **Cinco tipos de problema:** vazamento, esgoto a céu aberto, falta d'água, água contaminada/suja e baixa pressão.
- **Local pelo mapa, com GPS primeiro:** o pino começa onde a pessoa está; se o GPS falhar, cai para o centro do município e o endereço digitado continua possível.
- **Foto com metadados removidos (EXIF)** antes do envio, protegendo a privacidade de quem denuncia.
- **Protocolo automático** e acompanhamento do status (pendente → em análise → resolvida → arquivada), com notificação quando a ordem é concluída.
- **Funciona sem sinal:** a denúncia entra numa fila local (SQLite) e é enviada quando a conexão volta.

### 4.2 Técnico — atender com prova
- Fila de ordens de serviço do município, com mapa. O técnico aceita, registra a **chegada** com GPS e executa.
- **Checklist obrigatório por tipo de problema** e **foto do "depois"** antes de poder concluir a ordem. Sem evidência, não fecha (padrão de verificação que adaptamos do nosso projeto Confia).
- **Offline-first:** as ações do técnico entram numa fila de sincronização, importante em bairros com sinal ruim.

### 4.3 Gestor — priorizar por risco
- **Painel do mês corrente:** ocorrências abertas, ordens concluídas, tempo médio de resolução e tendência.
- **Mapa e grade de calor por tipo de problema.**
- **Alertas sanitários:** quando ocorrências do mesmo tipo se acumulam numa área, o sistema gera um alerta, visível apenas à equipe (gestor e técnico), com push segmentado por município. É a ponte com a saúde pública.
- **Relatório em PDF** do período, pronto para prestação de contas.

### 4.4 Inteligência artificial
Duas funções isoladas do fluxo principal, de modo que uma falha da IA nunca impede a denúncia nem o atendimento:
- **Classificação de cada ocorrência:** tipo sugerido, urgência e risco à saúde (saída estruturada, com dois provedores em cascata para garantir disponibilidade e cota diária contra abuso).
- **Resumo executivo do mês para o gestor:** 2 a 3 frases de insight acionável sobre os dados agregados (ex.: "esgoto a céu aberto reincidente em 3 bairros perto de escola, priorize aqui"). Nenhum dado pessoal do cidadão entra no prompt; só agregados anônimos.

### 4.5 Decisões que tornam a solução viável para o Piauí
- **Multi-tenancy por município** com concessionária associada (Águas do Piauí, Águas de Teresina, Águas de Timon): a mesma denúncia chega à empresa certa. Novo município é cadastro, não código.
- **Mapas abertos (OpenStreetMap)**, sem cobrança por uso de mapa.
- **Segurança:** isolamento de dados por município no banco (Row Level Security em todas as tabelas de negócio).

---

## 5. Público Beneficiado

| Público | Como se beneficia |
|---|---|
| **Moradores dos municípios atendidos**, em especial de bairros periféricos e de áreas com sinal de internet ruim | Canal simples e acessível, com protocolo, status e resposta; a denúncia funciona mesmo offline |
| **Técnicos de campo** das concessionárias | Fila priorizada e georreferenciada, checklist claro, registro que valida o trabalho feito |
| **Gestores das concessionárias** (Águas do Piauí, Águas de Teresina, Águas de Timon) | Dados estruturados de demanda real, prioridade por risco, relatório para prestação de contas |
| **Prefeituras e vigilância em saúde** | Alertas sanitários e mapa de calor para direcionar ações preventivas |
| **Escolas e comunidades** | Campanhas educativas do município (previstas na fase seguinte) |

---

## 6. Plano Mínimo de Implementação

### 6.1 Onde estamos (setembro/2026)
Protótipo funcional, desenvolvido pela equipe:
- perfis de cidadão, técnico e gestor com autenticação e navegação por papel;
- ocorrências ponta a ponta (wizard, foto sem EXIF, GPS, protocolo, mapa);
- ordens de serviço com aceite, chegada, checklist e evidência;
- fila offline com sincronização;
- notificações no app e push segmentado por usuário;
- painel do gestor, alertas sanitários e relatório em PDF;
- inteligência artificial em produção: classificação automática de cada ocorrência (tipo, urgência e risco à saúde) e resumo executivo mensal para o gestor;
- banco com isolamento por município e código aberto em repositório público [5].

### 6.2 Próximas etapas
| Etapa | Prazo (a partir da seleção) | Entrega |
|---|---|---|
| **1. Consolidação** | 2 semanas | Campanhas educativas e teste dos três perfis em aparelhos reais com usuários |
| **2. Validação com a concessionária** | 4 semanas | Reunião com a Águas do Piauí em Picos; ajuste dos tipos de ocorrência e dos checklists ao procedimento real da operação |
| **3. Piloto** | 90 dias | Bairros selecionados de Picos, com técnicos e gestores treinados; divulgação do app junto à comunidade |
| **4. Avaliação e expansão** | ao fim do piloto | Relatório de resultados; cadastro de novos municípios (Teresina e Timon incluídos) sem novo desenvolvimento |

### 6.3 Como vamos medir o piloto
Indicadores definidos desde o início, com linha de base coletada na primeira semana:
- tempo entre a denúncia e a conclusão da ordem de serviço;
- proporção de ordens concluídas com evidência completa;
- reincidência do mesmo problema no mesmo local;
- número de alertas sanitários gerados e tratados;
- satisfação do cidadão que abriu a ocorrência.

### 6.4 Custo e sustentabilidade
A stack foi escolhida para custo baixo: mapas abertos (sem billing de mapa), backend gerenciado com camada gratuita para o piloto e um único código-fonte para celular e web. Custos de operação em escala serão levantados com base no volume real do piloto, sem estimativa antecipada.

### 6.5 Riscos e mitigação
| Risco | Mitigação |
|---|---|
| Baixa adesão do cidadão | Fluxo guiado e acessível, campanhas e divulgação local |
| Conectividade ruim em campo | Arquitetura offline-first com fila de sincronização |
| Privacidade dos dados | Remoção de EXIF, acesso restrito por papel e município, nenhum dado pessoal enviado à IA |
| Concessionária não integrar o fluxo | Etapa 2 dedicada a alinhar o app ao procedimento operacional real; o gestor pode usar o sistema mesmo em modo de acompanhamento |
| Equipe pequena | Reaproveitamento de arquitetura já validada em projetos anteriores da equipe |

---

## 7. Transformação Pretendida

**O Piauí que queremos no saneamento** é um estado em que ninguém precisa esperar a obra definitiva para ser ouvido, e em que o reparo é priorizado pelo que protege a saúde de quem mora ali. O SISAN transforma o relato solto em dado, o dado em prioridade e a prioridade em ação comprovada. Não substitui o investimento em infraestrutura previsto pelas concessões; faz com que ele e a operação do dia a dia tenham um retrato fiel do território.

| Pilar | Transformação pretendida |
|---|---|
| **Saúde** | Alertas sanitários e classificação de risco à saúde priorizam esgoto a céu aberto e água contaminada perto de escolas e áreas vulneráveis, reduzindo o tempo de exposição. Dados abertos para a vigilância em saúde |
| **Social** | O cidadão ganha voz, protocolo e prova de resolução; o acesso vale também para quem tem sinal ruim e pouca familiaridade com tecnologia. Transparência entre população e concessionária |
| **Educação** | Campanhas educativas no app (uso consciente da água, cuidado com o esgoto), com potencial de levar o tema às escolas na fase seguinte |
| **Sustentabilidade** | Reparo mais rápido de vazamentos reduz desperdício de água tratada; relatórios por período apoiam o planejamento de investimentos; solução replicável de baixo custo para todos os municípios |

Nossos objetivos para o piloto são verificáveis pelos indicadores da seção 6.3. Não projetamos resultados antes de medir; o piloto existe para produzir esse número com honestidade.

---

## 8. Referências

[1] BRASIL. **Lei nº 14.026, de 15 de julho de 2020** (Marco Legal do Saneamento Básico). Ministério das Cidades — Marco Legal do Saneamento. Metas de 99% de água e 90% de coleta e tratamento de esgoto até 2033. Disponível em: https://www.gov.br/cidades/pt-br/assuntos/saneamento/marco-legal-do-saneamento

[2] INSTITUTO ÁGUA E SANEAMENTO. **Saneamento em transformação: os 5 anos da lei que redesenhou o setor**, 14 jul. 2025 (dados SNIS/SINISA). Disponível em: https://www.aguaesaneamento.org.br/en/news/saneamento-em-transformacao-os-5-anos-da-lei-que-redesenhou-o-setor/

[3] ÁGUAS DO PIAUÍ. **Águas do Piauí assume operação em mais 64 municípios e já atende 2 milhões de pessoas**, 23 jun. 2025. Disponível em: https://www.aguasdopiaui.com.br/aguas-do-piaui-assume-operacao-em-mais-64-municipios-e-ja-atende-2-milhoes-de-pessoas/

[4] ONU NEWS. **ONU lembra que acesso a saneamento e água é questão de vida ou morte**, jun. 2025. Disponível em: https://news.un.org/pt/story/2025/06/1850041

[5] EQUIPE SISAN. **SISAN — Sistema Integrado de Saneamento** (código-fonte). Disponível em: https://github.com/eltobsjr/SISAN--Sistema-Integrado-de-Saneamento

*Nota:* as referências [1] a [4] foram consultadas em 18/09/2026. Números de terceiros aparecem exatamente como publicados, com fonte e ano.
