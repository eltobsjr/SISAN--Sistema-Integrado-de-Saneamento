import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incrementado pelo SyncService sempre que ao menos um item da fila é
/// sincronizado com sucesso. Outros providers (ex: OrdensServicoNotifier,
/// OcorrenciasNotifier) escutam este counter para recarregar dados sem
/// acoplamento direto ao SyncService.
final syncVersionProvider = StateProvider<int>((ref) => 0);
