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

## Distribuição (WhatsApp)

- Material de apresentação enviado a **Jorge** (+55 89 9974-2675) e a
  **Évillyn** (+55 89 9981-4406): texto explicando o sistema (perfis, IA,
  priorização, diferenciais, avisos), `SISAN-pitch.pdf`, `SISAN-roteiro-pitch-2min.pdf`
  e 4 prints (`cid_home`, `tec_os_prioridade`, `ges_painel`, `cid_mapa`).
  Os dois números têm 8 dígitos após o DDD, como informados; a ponte
  respondeu sucesso.
- **APK (`SISAN.apk`, 74 MB, sha256 `4c95e5c0…f93df`) a ambos: timeout de 10 s**
  da ponte do WhatsApp nos dois envios. Entrega **não confirmada**, e a
  consulta de histórico da ferramenta volta vazia, então não dá para checar.
  Não reenviei às cegas para não duplicar. Pendente: o Elton conferir no
  WhatsApp; se não chegou, reenviar ou mandar o arquivo manualmente.
  Alternativa mais leve: `flutter build apk --release --split-per-abi`
  (arm64 ~25 MB).
- Texto com instruções de instalação (permitir fontes desconhecidas, contas
  de demo) fica para depois da confirmação de que o APK chegou.

## Incidentes da sessão

- **Instagram:** o teste mandou `KEYCODE_BACK` com o app na tela de login, o
  que fechou o SISAN e abriu o Instagram que estava por baixo. Dois toques e um
  texto caíram numa story. Nada foi enviado nem curtido (caixa de mensagem
  vazia), mas um toque pode ter registrado visualização. Corrigido o método:
  checar o foco da janela antes de cada toque (ver
  `referencia/checklist-apk-release-android.md`).
- **Conversas pessoais:** uma chamada de `list_chats` para verificar a entrega
  devolveu conversas pessoais do Elton. Nada foi lido além do necessário nem
  usado.
- Notificações pessoais (banco, WhatsApp) apareceram nos prints do celular;
  não foram usadas.

## Decisões

- Manter a senha das contas de demo e a confirmação de e-mail desligada
  (decisão do Elton, 13/10).
- SafeArea inferior global em vez de remendo por tela.
- Dados de teste ficam no banco até o Elton autorizar a remoção.

## Pendências abertas

1. Confirmar entrega do APK a Jorge e Évillyn.
2. Decidir se remove `OCR-202610-00102` e `qa.instalacao@sisan.dev`.
3. Testar foto + conclusão de OS, e envio offline, no aparelho.
4. Revisar o texto do resumo de IA antes da gravação de 14/10.
5. Configurar o OneSignal se push for prometido na demo.

## Observações

- A senha das contas de demo continua a mesma e está no histórico do git
  (decisão do Elton: manter, é conta de demonstração).
- Contas usadas nos testes: `cidadao1@`, `tecnico1@`, `gestor1@sisan.com`.
- O resumo do mês por IA gerou "mantenha a taxa de resolução em 0 horas":
  frase fraca para a demo, vem do modelo e não do código.
- A conta `cidadao.teste@sisan.dev` não usa a senha de demo padrão.
