# SISAN

Sistema Integrado de Saneamento: aplicativo Flutter para denúncias cidadãs,
ordens de serviço e priorização de problemas de saneamento.

## Desenvolvimento

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

O app usa Flutter com Supabase, Riverpod e GoRouter. As imagens em
`assets/images/` são compartilhadas pelo login, splash e ícones da aplicação.

## Entrada e autenticação

A tela de login usa campos preenchidos e CTA em formato de pílula, mantendo a
identidade visual Água Viva. A splash exibe a água-viva se formando com
`CustomPainter`, respeitando a configuração de acessibilidade para reduzir
animações.
