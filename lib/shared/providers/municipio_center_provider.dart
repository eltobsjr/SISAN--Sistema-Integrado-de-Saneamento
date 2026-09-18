import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';

/// Centroide do município do usuário logado (colunas geradas
/// `centro_latitude`/`centro_longitude` a partir de `municipios.centro`).
/// Usado como `initialCenter` em todo `FlutterMap` — substitui o fallback
/// genérico quando o GPS do dispositivo ainda não respondeu.
final municipioCenterProvider = FutureProvider.autoDispose<LatLng?>((ref) async {
  final usuario = ref.watch(authProvider).valueOrNull;
  final municipioId = usuario?.municipioId ?? '';
  if (municipioId.isEmpty) return null;

  final data = await supabase
      .from('municipios')
      .select('centro_latitude, centro_longitude')
      .eq('id', municipioId)
      .maybeSingle();

  if (data == null) return null;
  final lat = (data['centro_latitude'] as num?)?.toDouble();
  final lng = (data['centro_longitude'] as num?)?.toDouble();
  if (lat == null || lng == null) return null;
  return LatLng(lat, lng);
});
