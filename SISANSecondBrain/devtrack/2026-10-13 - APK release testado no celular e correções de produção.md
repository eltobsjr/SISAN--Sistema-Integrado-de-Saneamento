---
data: 2026-10-13
---

# 13/10 (noite): APK release testado no celular e correções de produção

Build release instalado por adb num Galaxy A36 (Android 16) e percorrido nos
três perfis, antes de mandar o APK para Jorge e Évillyn.

## Problemas encontrados e corrigidos (commit `d17c6b9`)

1. **Release sem internet.** `INTERNET` só estava em `android/app/src/debug` e
   `profile`; o manifest principal não tinha. O app só funcionava com cabo.
   Agora está no manifest principal (conferido com `aapt2 dump permissions`).
2. **Botões sob a barra do sistema.** Android 15+ (targetSdk 36) desenha o app
   por baixo da barra de navegação: "Continuar" e "Enviar Ocorrência" ficavam
   cortados e o fim das listas também. SafeArea inferior na raiz
   (`_OfflineWrapper` em `lib/app/sisan_app.dart`) resolve todas as telas.
3. **Abertura offline com sessão salva** jogava o usuário no login (o perfil
   não carregava). O último perfil fica em `flutter_secure_storage` e é usado
   quando a busca falha; só vale para o mesmo usuário e é limpo no logout.
4. **Falso "Fila zerada"** na home do técnico (e "nenhuma ocorrência" na do
   cidadão) quando o carregamento falhava. Agora mostra aviso de conexão.
5. **Detalhe da ocorrência** ficava em "Aguardando classificação automática"
   porque o objeto vinha da lista, sem a classificação. Rebusca por id.
6. Nome do app: `sisan` → `SISAN`.

## Testado no aparelho (release)

- Técnico: abas, detalhe da OS com IA e prioridade, voltar, abertura offline.
- Cidadão: login, nova ocorrência (5 passos, sem foto), protocolo, lista,
  detalhe; câmera abre pelo app.
- Gestor: painel com resumo por IA, ordens, alertas, meu município, correção
  da classificação (grava `classificacao_manual`, prioridade recalculada).
- Cadastro de cidadão novo: cai direto na home (Confirm email desligado no
  Supabase).

## Não testado

Foto tirada e enviada, aceitar/concluir OS com checklist e foto, push (OneSignal
ainda sem configuração), fila offline com envio de ocorrência sem rede.

## Dados de teste criados no banco de produção

- Ocorrência `OCR-202610-00102` ("TESTE QA do app…", Angelim), do `cidadao1`,
  reclassificada pelo gestor para atenção/médio.
- Usuário `qa.instalacao@sisan.dev` (cidadão, Teresina).

Remover antes da gravação, se atrapalharem a demo.

## Observações

- A senha das contas de demo continua a mesma e está no histórico do git
  (decisão do Elton: manter, é conta de demonstração).
- O resumo do mês por IA gerou "mantenha a taxa de resolução em 0 horas":
  frase fraca para a demo, vem do modelo e não do código.
- A conta `cidadao.teste@sisan.dev` não usa a senha de demo padrão.
