# Erros já resolvidos no SIGAU — não repetir aqui

Catálogo condensado de `SIGAU/roles/ERRORS_LOG.md` (44 entradas) e
`SIGAU/roles/AGENT_RULES.md`, filtrado para o que se aplica ao SISAN (mesma
stack: Flutter + Supabase + Riverpod + drift + OneSignal + flutter_map +
pacote `pdf`). Consultar o arquivo original no SIGAU para o diagnóstico
completo de qualquer item aqui.

## Banco / RLS
- Toda tabela nova precisa de **todas** as 4 policies (SELECT/INSERT/UPDATE/DELETE)
  revisadas explicitamente — RLS sem policy de UPDATE ou DELETE falha
  **silenciosamente** (retorna sucesso, zero linhas afetadas, sem erro nenhum).
- FK sem `ON DELETE CASCADE` bloqueia exclusão de qualquer linha com
  histórico dependente (erro `23503`) — mapear todas as FKs que apontam pra
  uma tabela antes de implementar "excluir X".
- "Desfazer" uma ação que criou uma linha com `UNIQUE` precisa reabrir a
  mesma linha (UPDATE), nunca só marcar como encerrada — senão bloqueia
  reincidência pra sempre.
- Campos geoespaciais sempre `geography(Point, 4326)`, nunca `geometry` —
  `ST_DWithin` em geometry calcula em graus, não metros.
- Funções `SECURITY DEFINER` não herdam RLS — filtrar `municipio_id`
  manualmente dentro delas.
- Nunca usar `service_role_key` no cliente Flutter.

## Flutter / Riverpod
- `AsyncNotifier.build()` pode rodar mais de uma vez — nunca declarar campos
  como `late final` se são inicializados lá dentro (usar `late` sem `final`).
- Para **inicializar** estado a partir de um provider, usar
  `ref.watch(...).valueOrNull` no `build()` — `ref.listen` só dispara em
  mudanças futuras, não emite o valor já em cache.
- Todo `AsyncNotifier` que depende de sessão deve escutar o stream de auth
  do Supabase e se invalidar em `signedIn`/`signedOut`.
- `GoRouter` precisa de `refreshListenable` conectado ao stream de auth,
  senão sessão expirada não redireciona.
- `GridView` com `childAspectRatio` fixo estoura com texto de tamanho
  variável — usar `Row + Expanded` em vez disso.
- Nunca renderizar `e.toString()`/`'Erro: $e'` na UI — centralizar num
  `ErrorHandler.parse(e)`.
- Providers Riverpod só em `features/<feature>/presentation/providers/`,
  nunca globais.

## Offline / conectividade
- Checar `ConnectivityService` antes de toda escrita no mobile; se offline,
  enfileirar (nunca lançar erro pro usuário).
- Todo acesso ao banco local (drift) precisa de guard `if (kIsWeb) return`.
- **Nunca implementar auto-logout por inatividade que chame `signOut()`** —
  apaga o token do disco e quebra o modo offline por completo (usuário fica
  travado em `/login` sem rede pra autenticar de novo). Se precisar proteger
  device desacompanhado, usar bloqueio local (PIN/biometria), nunca logout.

## Mapas (flutter_map)
- `FlutterMap` absorve eventos de ponteiro mesmo com `InteractiveFlag.none`
  — usar `GestureDetector(child: AbsorbPointer(child: FlutterMap(...)))` pra
  detectar tap num mini-mapa não-interativo.
- Esse padrão **não funciona** dentro de `SliverAppBar.flexibleSpace.background`
  — nesse caso, mover o mapa pra um card normal no corpo da tela.
- Sempre solicitar (`requestPermission()`), nunca só checar
  (`checkPermission()`) — em instalação nova, checar sozinho nunca abre o
  diálogo do sistema.
- Declarar `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` explicitamente no
  `AndroidManifest.xml` — o plugin geolocator não injeta isso sozinho.
- Usar `LocationAccuracy.high`, não `bestForNavigation` (falha em Android 12+
  com permissão "aproximada").

## OneSignal
- Toda notificação precisa da chave `en` em `headings`/`contents`, mesmo em
  app 100% português — OneSignal rejeita sem isso.
- Segmentar por `include_aliases: { external_id: [...] }`, nunca por filtro
  de tags (tags são frágeis, dependem de setup correto no device).
- `OneSignal.login()` retorna `Future<void>` — sempre `await` antes de
  chamar `addTagWithKey`.
- `proguard-rules.pro` precisa de `-keep class com.onesignal.**` explícito no
  build release, senão R8 remove as classes silenciosamente e push some sem
  erro nenhum.

## PDF (pacote `pdf`, não Flutter Material)
- `PdfColor` com alpha < 1.0 renderiza como cor sólida escura, não
  transparente — usar variantes "light" sólidas pré-definidas
  (`PdfColor.fromInt(0xFFRRGGBB)`).
- Não existe `pw.FractionallySizedBox` — usar `pw.Expanded(flex: n)`.
- Prefixar tudo com `pw.` — a API do pacote `pdf` é isolada do Flutter
  Material.

## Realtime
- Preferir `.stream()` do Supabase a `onPostgresChanges` (mais estável).
- Requer `REPLICA IDENTITY FULL` + tabela na publication de Realtime.
