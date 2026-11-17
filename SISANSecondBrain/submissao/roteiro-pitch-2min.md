---
tipo: nota
data: 2026-10-13
---

# Roteiro do pitch — 2 minutos, 2 apresentadores

Deck: ver [`apresentacao/README.md`](apresentacao/README.md). Gravação em 14/10.
Reorganizado em 13/10 à noite com as orientações da mentora Flávia Miranda
(benefícios, implantação, integração com a concessionária e impacto).
Ritmo de 130 a 135 palavras por minuto: **254 palavras, cerca de 117 segundos**, com folga para respirar e trocar de apresentador.
Se passar de 2 minutos, corte o slide 6 (Mapa) e encurte o 8 (Implantação).

**Ideia central (mentora Flávia Miranda):** não estamos vendendo um aplicativo, estamos
mudando a relação do cidadão com o saneamento. Cada slide responde a uma pergunta:
qual o problema, o que fazemos, como decide, quem ganha, como implanta, como convive
com o sistema da concessionária e qual o impacto.

| Slide | Quem | Tempo |
|---|---|---|
| 1 Capa | A | 8s |
| 2 Cenário | A | 16s |
| 3 Solução | A | 14s |
| 4 App | B | 4s |
| 5 Prioridade | B | 15s |
| 6 Mapa | B | 13s |
| 7 Benefícios | A | 12s |
| 8 Implantação | A | 10s |
| 9 Integração | B | 13s |
| 10 Impacto | B | 8s |
| 11 Fim | A e B | 4s |


## Pessoa A

1. **Capa (8s):** "Somos o SISAN: o aplicativo que liga quem sofre com falta d'água e esgoto a quem resolve."
2. **Cenário (16s):** "Em Teresina, 4 em cada 10 moradores ainda não têm esgoto atendido, e quase 20% da água se perde. Falta um canal simples para o cidadão avisar, e dado para a concessionária saber onde agir."
3. **Solução (14s):** "O cidadão registra com foto e GPS, mesmo sem internet. O técnico atende pela fila de prioridade e só conclui com checklist e foto. Quem relatou confirma se foi resolvido." *(passa para B)*

## Pessoa B

4. **App (4s):** "Um só aplicativo, três perfis. Telas reais."
5. **Prioridade (15s):** "A fila não é por ordem de chegada. A pontuação soma urgência, risco à saúde classificado pela IA, confirmações de moradores e dias em aberto. Se a IA errar, o gestor corrige."
6. **Mapa (13s):** "Cada relato vai ao mapa, por urgência. Quem vê o mesmo problema a até 80 metros confirma, em vez de duplicar. Dados da nossa base de testes interna." *(passa para A)*

## Pessoa A

7. **Benefícios (12s):** "Para o cidadão, um canal simples, na palma da mão, que o aproxima da concessionária. Para ela, a prefeitura e a saúde, dado localizado e priorizado."
8. **Implantação (10s):** "Implantação em etapas, simples, rápida e de baixo custo: consolidação, validação e piloto de 90 dias. Funciona offline, protege os dados e escala." *(passa para B)*

## Pessoa B

9. **Integração (13s):** "O SISAN complementa o sistema da concessionária, não cria um segundo. Depois do piloto, a baixa da ordem atualiza o status do cidadão, e a prioridade chega à programação."
10. **Impacto (8s):** "Não vendemos um aplicativo. Mudamos a relação do cidadão com o saneamento: mais voz, mais saúde, mais transparência."

## Fechamento

- **A e B:** "Obrigado! Escaneiem o QR code e testem o app."

## Perguntas prováveis (slides escondidos)

- **"E se a IA errar?"** → slide `corrigir`: o gestor corrige, a fila reordena e a IA não sobrescreve a correção. Se a IA falhar, o caso segue com urgência normal.
- **"De onde vêm os dados?"** → slides `dados` e `fontes`: "66 registros da base de testes interna e 8 casos documentados, cada um com fonte e data".
- **"Como funciona na prática?"** → jornada `j1` a `j6`, do registro à avaliação do cidadão.
- **"Que tecnologia vocês usaram?"** → slide `tecnologia`: base única e segura, multiplataforma, rápida de entregar.
- **"O que acontece com o sistema que a concessionária já tem?"** → slide `integracao` (já no pitch): o SISAN é complementar, a integração vem depois do piloto e ainda não existe API pronta.

## Orientações da mentora (Flávia Miranda, 13/10/2026)

- Prever integração com o sistema de campo (field) da concessionária: ela tem sistema próprio de ordens de serviço, e não faz sentido gerir dois. O status do relato deve ser atualizado pela baixa da OS, e as flags de prioridade devem chegar à programação.
- Rodar um piloto para validar a solução e, validada, seguir com a integração. O cronograma de implantação precisa conter essa previsão.
- Destacar o benefício ao usuário: canal simples e acessível, na palma da mão, mais próximo da concessionária. Trazer também os benefícios para os outros atores.
- Incluir lâmina com as etapas de implantação, destacando baixo custo e os riscos mapeados com solução. Reforçar: simples, rápida, baixo custo, offline, dados protegidos, escalável.
- Finalizar com slide de impacto: "Você não está vendendo um app, está mudando a relação do cidadão com o saneamento, em todas as esferas."
- Sobre os dados de Teresina (corrigidos no slide Cenário): 100% de cobertura de água na área urbana, 59% de cobertura de esgoto e 33 ETEs em operação, as maiores a Leste e a Pirajá.

## Regras de ouro

- **Nunca** chamar a base simulada de "pesquisa" ou dizer que são relatos reais de moradores. É "base de testes interna".
- Só dizer que o pedido de acesso à informação foi **protocolado** depois de protocolar (data e número de protocolo no devtrack). Até lá é "próximo passo paralelo".
- A integração com o sistema da concessionária é **previsão**: não existe API pronta. Dizer "prevista" e "depois do piloto".
- Números do cenário: cobertura de água (100% na área urbana), de esgoto (59%) e as 33 ETEs vêm da concessionária (informação repassada pela mentora em 13/10/2026). As perdas de 19,6% (19,55%, ano-base 2024) vêm do Estudo de Perdas de Água 2026 do Instituto Trata Brasil; citar a fonte e o ano-base.
- Push: os avisos aparecem dentro do app; o push no celular depende do OneSignal, ainda não configurado. Não prometer notificação push na demo.
- O QR code baixa o APK (Android). Quem tem iPhone não consegue instalar: mostrar a demo em vídeo.

## Combinar antes

- Quem é A e quem é B (Elto e Évillyn).
- Quem avança os slides.
- Quem responde perguntas de produto e quem responde de tecnologia.
- Conferir no slide final os nomes da equipe (sem contatos por enquanto).
