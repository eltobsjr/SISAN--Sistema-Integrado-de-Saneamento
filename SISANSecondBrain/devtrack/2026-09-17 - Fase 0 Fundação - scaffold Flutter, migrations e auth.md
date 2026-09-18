# 2026-09-17 — Fase 0 Fundação: scaffold Flutter, migrations e auth

## Contexto

Primeira sessão de código do SISAN. Documentação de base já estava pronta
(ver devtrack anterior, `2026-09-17 - Setup do SecondBrain...`). Objetivo:
sair do zero pra critério de saída da Fase 0 do `Roadmap.md` — "o app abre,
cada perfil consegue logar e cai na home certa", sem conteúdo nas homes
ainda.

## O que foi feito

**Flutter**: `flutter create --org br.sisan --platforms=android,ios,web .`
na raiz do projeto. `pubspec.yaml` reescrito com o inventário técnico
completo do Roadmap (todas as dependências das Fases 0-6 já declaradas,
mesmo as ainda não usadas — supabase_flutter, riverpod, go_router,
flutter_map, onesignal_flutter, drift, geolocator, fl_chart, pdf/printing
etc.), `.env` declarado como asset pra `flutter_dotenv`.

**Banco (via MCP `supabase-sisan`, confirmado apontando pro projeto
`gzoosgugbgbtcrjhfoot` antes de aplicar qualquer coisa)**:
- `001_enable_postgis` — extensões `postgis` + `uuid-ossp`.
- `002_create_municipios` — tabela `municipios` (decisions/003: `nome`,
  `estado`, `concessionaria` enum `aguas_piaui|aguas_teresina|aguas_timon`,
  `centro geography(Point,4326)`), leitura pública. Tabela separada
  `codigos_ativacao_staff` (município → código) **sem nenhuma policy** de
  SELECT pra anon/authenticated — decidido não colocar o código como coluna
  de `municipios` porque a policy `municipios_select USING (true)` exporia
  o código em qualquer `select *` (é exatamente esse o desenho que o SIGAU
  usou em `025_operador_code.sql`, mas lá o código fica na própria tabela
  pública — corrigido aqui desde o início). Acesso só via RPC
  `validar_codigo_ativacao_staff(municipio_id, codigo)`, SECURITY DEFINER.
- `003_create_usuarios` — tabela `usuarios` (perfis `cidadao|tecnico|gestor`),
  funções `auth_municipio_id()`/`auth_perfil()` (SECURITY DEFINER, STABLE)
  criadas **desde o início** — o SIGAU só migrou pra esse padrão depois,
  na migration 026, corrigindo recursão de RLS que existia até lá. Trigger
  `handle_new_user` lê `perfil`/`municipio_id`/`codigo_ativacao` dos
  metadata do signup; se pedir `tecnico`/`gestor` e o código não bater,
  cai silenciosamente pra `cidadao` (mesmo padrão SGAU-009/025 do SIGAU).
- Seed: município **Picos-PI** (`aguas_piaui`, decisions/009) inserido, com
  código de ativação de staff gerado: **`b6a0d780`** — usar esse código pra
  testar cadastro de técnico/gestor manualmente.
- Duas migrations de hardening depois de rodar `get_advisors`:
  `restrict_security_definer_grants` (revoga EXECUTE de `handle_new_user`
  de todo mundo — só roda via trigger — e de `auth_municipio_id`/
  `auth_perfil` do `anon`) e `usuarios_rls_performance` (índice em
  `usuarios.municipio_id`, unifica as duas policies de SELECT em uma só e
  envolve `auth.uid()` em `(select auth.uid())` — advisories de
  `auth_rls_initplan` e `multiple_permissive_policies` resolvidos).
- Advisory restante, não corrigível: `spatial_ref_sys` (tabela de sistema
  do PostGIS, dados estáticos de referência de SRID) está sem RLS, mas
  `ALTER TABLE` falha com "must be owner of table" — limitação do
  Supabase+PostGIS, não específica deste projeto. Risco baixo (não é dado
  de usuário, só a extensão escreve nela).

**Flutter — estrutura Clean Architecture por feature**:
- `lib/core/`: `constants/perfil_usuario.dart`, `constants/concessionaria.dart`,
  `network/supabase_client.dart`, `theme/app_theme.dart` (paleta "Água Viva"
  — decisions/008, `#0288D1`/`#01579B`), `errors/error_handler.dart`
  (traduz `AuthException` do Supabase pra mensagens em pt-BR, nunca
  `e.toString()` cru — ver erro herdado ERR-011).
- `lib/features/auth/`: entidades `Usuario` (freezed) e `Municipio`,
  `IAuthRepository`/`AuthRepositoryImpl` (login, cadastro, validação de
  código, logout), `authProvider` (`AsyncNotifier<Usuario?>`, escuta
  `onAuthStateChange`), `municipiosProvider` (lista pro dropdown do
  cadastro), páginas `SplashPage`/`LoginPage`/`CadastroPage`.
- `lib/features/home/`: 3 páginas placeholder (`CidadaoHomePage`,
  `TecnicoHomePage`, `GestorHomePage`) — só saudação + botão de logout,
  conforme o critério de saída da fase (sem conteúdo ainda).
- `lib/app/router.dart`: `GoRouter` com guard por perfil — rotas `/cidadao`,
  `/tecnico`, `/gestor` só acessíveis pelo perfil dono; `refreshListenable`
  escuta tanto o stream de auth do Supabase quanto o `authProvider`
  (necessário porque o perfil resolve de forma assíncrona depois do login —
  sem o segundo listener o redirect rodava com `AsyncLoading` e travava na
  splash).

**Cadastro**: seletor Cidadão/Concessionária (`SegmentedButton`). Se
"Concessionária": dropdown de perfil (Técnico/Gestor) + campo de código de
ativação, validado via RPC *antes* do `signUp` (feedback imediato de "código
inválido" em vez de deixar o backend derrubar silenciosamente pra cidadão,
que confundiria a demo).

**Validação**: `flutter analyze` limpo (0 issues, 3 lints corrigidos:
`unnecessary_underscores`, `use_null_aware_elements`, `anonKey` deprecated
→ `publishableKey`), `flutter test` passando (1 teste — `AppTheme.light()`
usa a cor primária certa), `flutter build web --release` compila sem erros.

## Pendências

- [ ] **Não testado visualmente no navegador** — a extensão Claude in Chrome
  não estava conectada nesta sessão, então o fluxo de cadastro/login/guard
  de rota não foi validado rodando de verdade, só por análise estática +
  compilação. Testar manualmente: cadastro cidadão → cai em `/cidadao`;
  cadastro técnico/gestor com o código `b6a0d780` do município Picos → cai
  na home certa; tentar acessar a home de outro perfil → redireciona de
  volta.
- [ ] Rodar em emulador Android/iOS real (só validado build web nesta sessão).
- [ ] Nenhuma tela de "meu município" ainda pra gestor visualizar/regenerar
  o código de ativação — hoje só dá pra consultar via MCP/SQL direto. Trivial
  de adicionar quando a Fase de perfil/config chegar.

## Próximos passos

1. Testar o fluxo de auth de verdade (browser ou emulador) antes de seguir
   pra Fase 1.
2. Fase 1 — Ocorrências: migration `004_create_ocorrencias` (fork de
   `028/029_denuncias` do SIGAU) + feature completa (wizard com foto+GPS,
   protocolo `OCR-AAAAMM-NNNNN`).
