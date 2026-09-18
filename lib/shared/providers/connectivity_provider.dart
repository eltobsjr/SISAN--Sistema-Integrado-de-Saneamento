import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/shared/services/connectivity_service.dart';

/// Emite `true` quando há conexão, `false` quando offline. Consumido pelo
/// banner global de "sem conexão" e pelos notifiers com suporte offline.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});
