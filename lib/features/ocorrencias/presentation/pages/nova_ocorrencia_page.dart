import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/widgets/nova_ocorrencia_guiada_view.dart';
import 'package:sisan/features/ocorrencias/presentation/widgets/ocorrencia_sucesso_screen.dart';

/// Ponto de entrada de "Nova Ocorrência" — modo guiado (uma pergunta por
/// tela) é o único caminho ativo, por ser mais acessível (pedido do
/// usuário). O modo padrão (formulário único) fica arquivado em
/// `nova_ocorrencia_padrao_view.dart`, pronto pra ser reconectado se um dia
/// fizer sentido oferecer os dois de novo.
class NovaOcorrenciaPage extends ConsumerStatefulWidget {
  const NovaOcorrenciaPage({super.key});

  @override
  ConsumerState<NovaOcorrenciaPage> createState() => _NovaOcorrenciaPageState();
}

class _NovaOcorrenciaPageState extends ConsumerState<NovaOcorrenciaPage> {
  Ocorrencia? _ocorrenciaEnviada;

  @override
  Widget build(BuildContext context) {
    if (_ocorrenciaEnviada != null) {
      return OcorrenciaSucessoScreen(ocorrencia: _ocorrenciaEnviada!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ocorrência'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Minhas ocorrências',
            onPressed: () => context.push('/ocorrencias'),
          ),
        ],
      ),
      body: NovaOcorrenciaGuiadaView(onConcluido: (o) => setState(() => _ocorrenciaEnviada = o)),
    );
  }
}
