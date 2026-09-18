# 2026-09-17 — Auditoria pós-trava e mapeamento para Fase 2

> Sessão de análise e planejamento. Sem implementação de código.

## O que foi feito

O PC travou durante a sessão anterior de código. Esta sessão serviu pra
auditar o que sobreviveu antes de continuar desenvolvendo.

O devtrack mais recente na trava (`Fase 0 Fundação — scaffold Flutter,
migrations e auth`) documentava só até auth/home, mas o código em disco ia
além disso: a Fase 1 inteira (`ocorrencias`) já estava implementada e nunca
tinha sido documentada nem commitada — foi nesse ponto que a trava aconteceu.

Verificação de integridade, tudo saudável:
- `flutter analyze` → 0 issues
- `flutter test` → passa
- Migrations no banco (via MCP `supabase-sisan`, projeto `gzoosgugbgbtcrjhfoot`
  confirmado): `create_ocorrencias` e `fix_ocorrencias_function_search_path`
  aplicadas, tabela `ocorrencias` com RLS habilitada
- Feature `ocorrencias` completa (2562 linhas): entidade, repositório,
  datasource, provider, 3 páginas reais — wizard `nova_ocorrencia_page.dart`
  com GPS (`Geolocator`) e fotos (`ImagePicker`), `minhas_ocorrencias_page.dart`,
  `ocorrencia_detalhe_page.dart` — sem `TODO`/`UnimplementedError`
- Rotas já plugadas no `GoRouter` (`/ocorrencias`, `/ocorrencias/nova`,
  `/ocorrencias/:id`)
- Protocolo `OCR-AAAAMM-NNNNN` implementado e exibido na UI

Conclusão: nenhum trabalho foi perdido na trava. O código está num estado
consistente e compilável, só não estava documentado nem commitado.

Levantamento de telas/funcionalidades desenvolvidas até agora e comparação
com o `Roadmap.md` pra definir a próxima leva de desenvolvimento (Fase 2 —
Ordens de Serviço).

---

## Inventário — telas e funcionalidades desenvolvidas

### Fase 0 — Fundação (auth + navegação)

| Tela | Funcionalidade |
|---|---|
| `SplashPage` | Verifica sessão e redireciona por perfil |
| `LoginPage` | E-mail/senha, erros traduzidos pt-BR |
| `CadastroPage` | Seletor Cidadão/Concessionária; se staff, dropdown Técnico/Gestor + validação de código de ativação via RPC antes do signup |
| `CidadaoHomePage` / `TecnicoHomePage` / `GestorHomePage` | Placeholders (saudação + logout) — guard de rota por perfil no `GoRouter` |

### Fase 1 — Ocorrências (completa)

| Tela | Funcionalidade |
|---|---|
| `NovaOcorrenciaPage` | Wizard: tipo, descrição, fotos (multi-pick + EXIF strip), GPS via `Geolocator`, gera protocolo `OCR-AAAAMM-NNNNN` |
| `MinhasOcorrenciasPage` | Lista das ocorrências do cidadão |
| `OcorrenciaDetalhePage` | Detalhe com protocolo e status |

### Backend (Supabase, aplicado via MCP)

- Tabelas `municipios`, `codigos_ativacao_staff` (sem policy pública),
  `usuarios`, `ocorrencias` — todas com RLS
- Funções `auth_municipio_id()`/`auth_perfil()` (SECURITY DEFINER), RPC
  `validar_codigo_ativacao_staff`
- Município seed: Picos-PI
- Advisories corrigidos (`auth_rls_initplan`, `multiple_permissive_policies`,
  `search_path`)

### Não desenvolvido ainda

Mapa, notificações push, dashboard, alertas sanitários, IA, campanhas,
Ordens de Serviço. Bucket de Storage pra fotos de ocorrências não confirmado
como criado — checar antes de assumir que o upload de fotos funciona
ponta a ponta.

---

## Arquivos modificados

Nenhum arquivo modificado nesta sessão (só leitura/análise via MCP e
filesystem).

## Próximos passos

Próxima sessão: **Fase 2 — Ordens de Serviço** (`features/002`, fork de
`resgates` do SIGAU + checklist do Confia). Antes de começar, fechar a
pendência herdada: testar Fase 0+1 de ponta a ponta no navegador (nunca
validado rodando de verdade, só por análise estática).

Escopo da Fase 2:

1. **Migration `005_create_ordens_servico`** — `ocorrencia_id, tecnico_id,
   status enum('pendente','aceita','a_caminho','concluida'), checklist
   jsonb, fotos_depois text[]`, RLS por município/técnico
2. **`lib/features/ordens_de_servico/`** completo (data/domain/presentation)
3. **Fila do técnico** — lista de OS pendentes do município (`TecnicoHomePage`
   deixa de ser placeholder)
4. **Aceitar OS** — muda status `pendente → aceita`
5. **Registrar chegada** — captura GPS, muda status `→ a_caminho`
6. **Checklist obrigatório** por tipo de ocorrência, bloqueia conclusão até
   preenchido (`decisions/005`)
7. **Foto do "depois"** — mínimo 1, EXIF removido, geotag/horário
8. **Concluir OS** — atualização otimista + fila offline (drift), dispara
   notificação pro cidadão
9. **Edge Functions**: `notify-nova-os` (técnico), `notify-ocorrencia-resolvida`
   (cidadão)

## Status

- [x] Auditoria de integridade pós-trava (analyze, test, migrations, código)
- [x] Inventário de telas/funcionalidades desenvolvidas
- [x] Escopo da Fase 2 mapeado a partir do Roadmap
- [ ] Testar Fase 0+1 de ponta a ponta no navegador
- [ ] Confirmar se o bucket de Storage `ocorrencias-fotos` existe
- [ ] Commitar Fase 0 + Fase 1 (nada foi commitado ainda desde `44ce47f`)
- [ ] Gerar devtrack da própria sessão de implementação da Fase 1 (esta
      sessão só documentou o resultado, não o processo — se for importante
      recuperar decisões tomadas durante a implementação, não há registro)
