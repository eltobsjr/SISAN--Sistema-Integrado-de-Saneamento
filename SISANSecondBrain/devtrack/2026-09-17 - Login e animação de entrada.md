# 2026-09-17 — Login e animação de entrada

## Entrega

- Redesenhada a tela de login com campos preenchidos, botão pílula, hierarquia
  visual mais pessoal e ícone da identidade Água Viva.
- Criados `AppTextField` e `PrimaryPillButton` em `lib/shared/widgets/`.
- Criada a animação de entrada da água-viva com `CustomPainter`, caminhos
  vetoriais e sequência de formação da cabeça, rosto e tentáculos.
- Integrada a animação ao `SplashPage` e habilitados os assets de imagem no
  `pubspec.yaml`.

## Referências

- Linguagem visual inspirada no `auth_screen.dart` do Polymata.
- Mecânica de revelação inspirada no `IntroSplashScreen` do Confia.
- A implementação foi reescrita para o domínio e a identidade do SISAN.

## Validação

- `flutter analyze`: aprovado.
- `flutter test`: aprovado.
- `assets/images/app_icon_full.png` e `app_icon_fg.png`: presentes.
- Dispositivo Android conectado e autorizado: `SM A366E`, Android 16, serial
  `RQCY505KY4P`.

## Build e instalação

- APK compilado com sucesso em `build/app/outputs/flutter-apk/app-debug.apk`.
- Aplicação instalada com sucesso no dispositivo `SM A366E` via USB.
- Pacote Android: `br.sisan.sisan`.

## Versionamento

- Commit `b98f27f`: `feat(auth): polish login and animate splash`.
- Push concluído para `origin/main`.