import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sisan/core/constants/concessionaria.dart';
import 'package:sisan/features/municipio/domain/entities/meu_municipio.dart';
import 'package:sisan/features/municipio/presentation/providers/meu_municipio_provider.dart';
import 'package:sisan/shared/widgets/sisan_error_state.dart';
import 'package:sisan/shared/widgets/sisan_loading.dart';

/// "Meu município" do gestor: dados do município, equipe cadastrada e o
/// código que técnicos/gestores digitam no cadastro pra ativar o perfil.
class MeuMunicipioPage extends ConsumerWidget {
  const MeuMunicipioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meuMunicipioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu município')),
      body: state.when(
        loading: () => const Center(child: SisanLoading.compact()),
        error: (_, _) => SisanErrorState(onRetry: () => ref.invalidate(meuMunicipioProvider)),
        data: (m) => _Conteudo(municipio: m),
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.municipio});
  final MeuMunicipio municipio;

  static const _azul = Color(0xFF0288D1);

  String get _concessionaria {
    try {
      return Concessionaria.fromDb(municipio.concessionaria).toLabel();
    } catch (_) {
      return municipio.concessionaria;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codigo = municipio.codigoAtivacao;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_city_outlined, size: 36, color: _azul),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${municipio.nome} — ${municipio.estado}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(_concessionaria, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _Contagem(icone: Icons.admin_panel_settings_outlined, valor: municipio.gestores, rotulo: 'Gestores')),
            const SizedBox(width: 12),
            Expanded(child: _Contagem(icone: Icons.engineering_outlined, valor: municipio.tecnicos, rotulo: 'Técnicos')),
            const SizedBox(width: 12),
            Expanded(child: _Contagem(icone: Icons.people_outline, valor: municipio.cidadaos, rotulo: 'Cidadãos')),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Código de ativação da equipe', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Quem se cadastrar como técnico ou gestor precisa informar este código. '
                  'Compartilhe só com a equipe do município.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    codigo ?? '—',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 4, color: _azul),
                  ),
                ),
                if (municipio.codigoAtualizadoEm != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Atualizado em ${DateFormat('dd/MM/yyyy HH:mm').format(municipio.codigoAtualizadoEm!)}',
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: codigo == null ? null : () => _copiar(context, codigo),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copiar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _regenerar(context, ref),
                        icon: const Icon(Icons.autorenew_rounded, size: 18),
                        label: const Text('Gerar novo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copiar(BuildContext context, String codigo) async {
    await Clipboard.setData(ClipboardData(text: codigo));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado.')));
    }
  }

  Future<void> _regenerar(BuildContext context, WidgetRef ref) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gerar novo código?'),
        content: const Text(
          'O código atual deixa de valer. Quem já está cadastrado não é afetado, '
          'mas novos cadastros da equipe vão precisar do código novo.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Gerar novo')),
        ],
      ),
    );
    if (confirmou != true) return;

    try {
      await ref.read(meuMunicipioProvider.notifier).regenerarCodigo();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Novo código gerado.')));
      }
    } on PostgrestException catch (e) {
      if (context.mounted) {
        // 54000 = limite de trocas por hora (rate limit da RPC).
        final msg = e.code == '54000' ? e.message : 'Não foi possível gerar o código. Tente novamente.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Não foi possível gerar o código. Tente novamente.')));
      }
    }
  }
}

class _Contagem extends StatelessWidget {
  const _Contagem({required this.icone, required this.valor, required this.rotulo});
  final IconData icone;
  final int valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icone, color: const Color(0xFF0288D1)),
            const SizedBox(height: 6),
            Text('$valor', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(rotulo, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
