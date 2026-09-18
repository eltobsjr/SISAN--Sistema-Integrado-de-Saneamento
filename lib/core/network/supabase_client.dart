import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acesso direto ao client Supabase, para uso fora da árvore de widgets.
SupabaseClient get supabase => Supabase.instance.client;

/// Provider Riverpod equivalente, para uso dentro de providers/notifiers.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
