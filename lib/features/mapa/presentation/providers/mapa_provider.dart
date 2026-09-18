import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisan/core/constants/ocorrencia_tipo.dart';
import 'package:sisan/core/errors/error_handler.dart';
import 'package:sisan/features/auth/presentation/providers/auth_provider.dart';
import 'package:sisan/features/ocorrencias/data/datasources/ocorrencia_supabase_datasource.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';
import 'package:sisan/shared/providers/realtime_version_provider.dart';

class MapaState {
  const MapaState({
    this.ocorrencias = const [],
    this.filtroTipo,
    this.isLoading = false,
    this.erro,
  });

  final List<Ocorrencia> ocorrencias;
  final OcorrenciaTipo? filtroTipo; // null = todos
  final bool isLoading;
  final String? erro;

  List<Ocorrencia> get ocorrenciasFiltradas {
    if (filtroTipo == null) return ocorrencias;
    return ocorrencias.where((o) => o.tipo == filtroTipo).toList();
  }

  MapaState copyWith({
    List<Ocorrencia>? ocorrencias,
    Object? filtroTipo = _sentinel,
    bool? isLoading,
    Object? erro = _sentinel,
  }) {
    return MapaState(
      ocorrencias: ocorrencias ?? this.ocorrencias,
      filtroTipo: filtroTipo == _sentinel ? this.filtroTipo : filtroTipo as OcorrenciaTipo?,
      isLoading: isLoading ?? this.isLoading,
      erro: erro == _sentinel ? this.erro : erro as String?,
    );
  }
}

const _sentinel = Object();

class MapaNotifier extends Notifier<MapaState> {
  final _datasource = OcorrenciaSupabaseDatasource();

  @override
  MapaState build() {
    // Recarrega quando qualquer ocorrência do município muda (Realtime).
    ref.listen<int>(realtimeVersionProvider('ocorrencias'), (_, _) => recarregar());
    _carregarOcorrencias();
    return const MapaState(isLoading: true);
  }

  Future<void> _carregarOcorrencias() async {
    try {
      final usuario = ref.read(authProvider).valueOrNull;
      final municipioId = usuario?.municipioId ?? '';
      if (municipioId.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final ocorrencias = await _datasource.listarDoMunicipio(municipioId);
      state = state.copyWith(ocorrencias: ocorrencias, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, erro: ErrorHandler.parse(e));
    }
  }

  Future<void> recarregar() async {
    state = state.copyWith(isLoading: true, erro: null);
    await _carregarOcorrencias();
  }

  void setFiltroTipo(OcorrenciaTipo? tipo) => state = state.copyWith(filtroTipo: tipo);
}

final mapaProvider = NotifierProvider<MapaNotifier, MapaState>(MapaNotifier.new);
