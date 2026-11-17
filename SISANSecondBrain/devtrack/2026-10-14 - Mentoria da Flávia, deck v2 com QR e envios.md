---
tipo: devtrack
data: 2026-10-14
---

# 14/10 (madrugada): orientações da Flávia, deck v2 com QR code e envios

Continuação do devtrack `2026-10-13 - APK release testado no celular…`.
Decisão registrada em `decisions/016`; dados em `referencia/dados-teresina-cenario.md`.

## Orientações da mentora Flávia Miranda (13/10, 22h50 a 23h42)

Conversa completa recebida em `Flávia Miranda.zip` (Downloads). Primeiro li só
um trecho colado, sem o começo, e **perdi a correção de dados**; ela só apareceu
quando o Elto reenviou o zip.

1. **Dados:** cobertura de água 100% na área urbana, esgoto 59%, 33 ETEs em
   operação (as maiores, Leste e Pirajá).
2. **Integração** com o sistema field da concessionária (status pela baixa da
   OS; flags de prioridade para a programação); piloto antes; previsão no
   cronograma de implantação.
3. **Benefício ao usuário**: canal simples, na palma da mão, mais próximo da
   concessionária; trazer os benefícios dos outros atores.
4. **Lâmina de implantação** resumida (baixo custo, riscos mapeados, simples,
   rápida, offline, dados protegidos, escalável).
5. **Slide de impacto** no fim: "você não está vendendo um app, está mudando a
   relação do cidadão com o saneamento".

## O que mudou no deck (de 8 para 11 slides no pitch, nenhum escondido)

| Antes | Agora |
|---|---|
| cover, oficial, fluxo, telas, prioridade, mapa, tecnologia, fim | cover, oficial, fluxo, telas, prioridade, mapa, **beneficios, implantacao, integracao, impacto**, fim |
| `tecnologia` no pitch | `tecnologia` no apêndice (escondido) |
| `oficial`: 94,8% / 55,5% / 19,6% / 3 estações | 100% / 59% / 19,6% / 33 ETEs, **fonte abaixo de cada número** |
| `fim`: Obrigado + próximo passo = Lei de Acesso à Informação | Obrigado + **QR code do APK e contas de teste** + próximo passo = piloto e integração (LAI virou frente paralela no slide `proximo`) |

O Elto pediu explicitamente que os slides da Flávia fiquem **visíveis**; por isso
`integracao` também entrou no pitch.

## QR code e contas

- APK `SISAN-v1.0.0.apk` (74.220.026 bytes) no Drive do Elto, "qualquer pessoa com
  o link"; o QR aponta para ele. O QR foi **decodificado do PDF final** para
  conferir.
- Contas no slide final: `cidadao1@`, `tecnico1@`, `gestor1@sisan.com` e a senha
  de demo. **Decisão do Elto**: pode mostrar a senha. Mesmo assim ela não entra
  no repositório (público): `gerar.py` lê `SENHA_DEMO` do ambiente. O PDF com
  senha (`SISAN-pitch-com-contas.pdf`) está no `.gitignore`.
- O Drive não aceita upload de 74 MB pela ferramenta; o Elto subiu o arquivo.

## Roteiro refeito

254 palavras, cerca de 117 s, 11 slides, A e B alternando, com a ideia central
da Flávia. A primeira versão tinha 295 palavras (135 s) e estourava os 2 min;
foi enxugada. Nas notas do slide da capa também.

## Pesquisa de fontes (13/10)

Perdas confirmadas (19,55%, Trata Brasil 2026); água (Aegea, 2020) e esgoto
(MPF-PI, Governo do Piauí) com ressalvas de ano; **33 ETEs sem fonte pública**.

## Publicação e envios

- Deck online (Artifact, privado, só o Elto abre): versões 15, 16 e 17. O formato
  do deck é restrito (ver memória `reference_deck_pipeline`).
- WhatsApp a Jorge e Évillyn: texto de justificativa, PDF do deck com contas e
  roteiro novo. **Feito.** O APK do dia 13 chegou (confirmado pelo Elto).
- **E-mail para `portal@cidadeverde.com`:** montado no Gmail (assunto, corpo
  explicando a mudança e o PDF com contas anexado), **não enviado**: aguarda OK.
- **Flávia:** o Elto quer que ela receba o deck e o roteiro, mas não achei o
  contato dela; falta o número.

## Problemas encontrados

- **Claude in Chrome:** a primeira tentativa falhou em todas as chamadas ("aba
  não está no grupo da sessão"); funcionou numa nova tentativa, com outro ID de
  grupo. `file_upload` recusou arquivos de `~/Downloads` e aceitou o mesmo
  arquivo dentro da pasta do projeto.
- O `dart format` e ferramentas semelhantes reformatam arquivos inteiros: evitar
  em arquivos versionados (visto no código Flutter ontem).

## Pendências

1. Enviar o e-mail à Cidade Verde (aguardando "pode enviar").
2. Número da Flávia para mandar o deck e o roteiro.
3. Commit e push destas mudanças (pasta do deck, roteiro, documento de
   submissão, README, `.gitignore`, decisão 016, referência e devtrack).
4. Regenerar o PDF do documento de submissão (não achei o script; foi feito
   com Chrome headless). Só o `.md` foi atualizado.
5. Conferir como o deck online renderiza o último slide (QR em SVG) no navegador.
6. Confirmar com a Flávia a fonte das 33 ETEs.
7. Remover os dados de teste do banco (ocorrência `OCR-202610-00102` e usuário
   `qa.instalacao@sisan.dev`) com o OK do Elto.
8. Texto do resumo por IA ("taxa de resolução em 0 horas") antes da gravação.
