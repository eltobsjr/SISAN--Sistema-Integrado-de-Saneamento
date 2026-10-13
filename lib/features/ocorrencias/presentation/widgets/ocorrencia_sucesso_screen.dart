import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sisan/shared/design/sisan_tokens.dart';

import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/features/ocorrencias/presentation/providers/ocorrencias_provider.dart' show kProtocoloOffline;

/// Tela de confirmação após enviar uma ocorrência — compartilhada entre o
/// modo padrão e o modo guiado de "Nova Ocorrência".
class OcorrenciaSucessoScreen extends StatelessWidget {
  const OcorrenciaSucessoScreen({super.key, required this.ocorrencia});
  final Ocorrencia ocorrencia;

  @override
  Widget build(BuildContext context) {
    final protocolo = ocorrencia.protocolo;
    final offline = protocolo == kProtocoloOffline;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (offline ? SisanCores.atencao : SisanCores.sucesso).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    offline ? Icons.cloud_off_rounded : Icons.water_drop_rounded,
                    size: 44,
                    color: offline ? SisanCores.atencao : SisanCores.sucesso,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  offline ? 'Ocorrência salva!' : 'Ocorrência registrada!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  offline
                      ? 'Sem conexão no momento — sua ocorrência foi salva neste aparelho e será enviada automaticamente assim que você tiver internet.'
                      : 'Sua ocorrência foi enviada. A concessionária do seu município vai analisar o caso.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                ),
                if (protocolo != null && !offline) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SisanCores.sucessoClara,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SisanCores.sucesso.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('Número de protocolo', style: TextStyle(fontSize: 12, color: SisanCores.sucesso)),
                        const SizedBox(height: 6),
                        Text(
                          protocolo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: SisanCores.sucesso,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: protocolo));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Protocolo copiado!'), duration: Duration(seconds: 2)),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copiar protocolo'),
                          style: TextButton.styleFrom(foregroundColor: SisanCores.sucesso),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/cidadao'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Voltar para o início'),
                  style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
