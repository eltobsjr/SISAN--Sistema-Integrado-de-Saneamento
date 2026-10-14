---
data: 2026-10-13
---

# Checklist: APK release Android do SISAN

Lições do teste do release num Galaxy A36 (Android 16, targetSdk 36), em
13/10/2026. Vale para qualquer Flutter com a mesma stack.

## Antes de mandar o APK para outras pessoas

1. **`INTERNET` no manifest principal.** `flutter create` só põe a permissão
   em `src/debug` e `src/profile`. Sem ela o release não tem rede e só parece
   funcionar com cabo. Conferir:
   `~/Android/Sdk/build-tools/<v>/aapt2 dump permissions app-release.apk`.
2. **Edge-to-edge (Android 15+, targetSdk 35 ou mais).** O app desenha sob a
   barra de navegação e botões ficam cortados. Solução global:
   `SafeArea(top: false)` na raiz, em `_OfflineWrapper` (`lib/app/sisan_app.dart`),
   com `ColoredBox` branco atrás. Não opte por sair do edge-to-edge: é
   ignorado no Android 16.
3. **Nome do app** em `android:label`.
4. **Abertura offline com sessão salva.** O perfil vem do banco; sem rede cai
   no login. Há cache do último perfil em `flutter_secure_storage`
   (`AuthNotifier`).
5. **Estado de erro não pode parecer vazio.** `valueOrNull ?? const []`
   mostra "Fila zerada" quando a rede falhou. Tratar `hasError` e `isLoading`.
6. **Dados vindos da lista via `extra`** ficam velhos (ex.: classificação da
   IA que chega 2 s depois). Rebuscar por id quando faltar campo.
7. **Build:** `JAVA_TOOL_OPTIONS` com o truststore (ver
   `reference_build_release_truststore` na memória), `gradlew --stop` antes.
8. **Assinatura:** o release usa a chave debug; serve para instalar por
   arquivo, não para Play Store.

## Testar pelo adb sem sujar o celular do dono

- O aparelho pode aparecer **duas vezes** (USB e Wi-Fi): usar `adb -s <serial>`.
- Instalar com `adb install -r` mantém sessão e dados.
- Ler a tela: `uiautomator dump` + parse dos `bounds`; Flutter expõe texto e
  `content-desc` por semântica. Coordenadas do dump são a fonte de verdade
  (os prints vêm reduzidos: multiplicar por 1,17).
- **Nunca mandar `KEYCODE_BACK` sem checar antes** se o teclado está aberto
  (`dumpsys input_method | grep mInputShown=true`). Na tela de login ele
  fecha o app e cai em qualquer app que estivesse por baixo.
- **Checar o foco antes de cada toque ou texto:**
  `dumpsys window | grep mCurrentFocus` deve conter `br.sisan.sisan`. Se o
  usuário usar o celular ao mesmo tempo, o foco muda.
- Campos de formulário Flutter: tocar no **campo**, não no rótulo (o dump
  lista o rótulo; o campo fica ~120 px abaixo). A página pode rolar sozinha
  quando o teclado abre: reler o dump entre um campo e outro.
- Desligar a rede: `svc wifi disable; svc data disable` (e `enable` no fim).
- Câmera: o intent abre; não bater foto sem o dono (a imagem sobe para o banco).

## Fluxos conferidos no aparelho em 13/10

Técnico, cidadão (nova ocorrência em 5 passos), gestor (painel, ordens,
alertas, correção de classificação) e cadastro de conta nova. Não conferidos:
foto + conclusão de OS, envio offline, push.

## Enviar o APK pelo WhatsApp

A ponte MCP tem timeout de 10 s; 74 MB estoura e não dá para confirmar a
entrega. Preferir `--split-per-abi` (arm64, ~25 MB) ou enviar manualmente.
