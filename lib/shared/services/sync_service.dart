import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sisan/core/database/app_database.dart';
import 'package:sisan/core/network/supabase_client.dart';
import 'package:sisan/core/security/exif_remover.dart';
import 'package:sisan/shared/providers/sync_version_provider.dart';
import 'package:sisan/shared/services/connectivity_service.dart';

class SyncService {
  SyncService(this._db, this._connectivity, this._ref);

  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final Ref _ref;
  StreamSubscription<bool>? _sub;
  bool _processing = false;

  /// Inicia escuta de conectividade e processa a fila pendente ao reconectar.
  void startListening() {
    _connectivity.isOnline().then((online) {
      if (online) processQueue();
    });
    _sub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) processQueue();
    });
  }

  void dispose() => _sub?.cancel();

  /// Processa todos os itens `pending` da fila em ordem de criação. Para
  /// imediatamente se perder a conexão durante o processamento. Incrementa
  /// [syncVersionProvider] se ao menos 1 item for sincronizado, sinalizando a
  /// outros providers (ex: OrdensServicoNotifier) para recarregar.
  Future<void> processQueue() async {
    if (kIsWeb || _processing) return;
    _processing = true;
    int synced = 0;
    try {
      final entries = await (_db.select(_db.syncQueueTable)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      for (final entry in entries) {
        if (!await _connectivity.isOnline()) break;
        if (await _processEntry(entry)) synced++;
      }

      if (synced > 0) {
        _ref.read(syncVersionProvider.notifier).state++;
      }
    } finally {
      _processing = false;
    }
  }

  /// Retorna true se o item foi processado com sucesso.
  Future<bool> _processEntry(SyncQueueEntry entry) async {
    try {
      final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
      final key = '${entry.operation}:${entry.entityTable}';

      switch (key) {
        case 'INSERT:ocorrencias':
          await _syncOcorrenciaInsert(payload);
        case 'ACEITAR:ordens_servico':
          await _syncOrdemServicoUpdate(payload);
        case 'CHEGADA:ordens_servico':
          await _syncOrdemServicoUpdate(payload);
        case 'CONCLUIR:ordens_servico':
          await _syncOrdemServicoConcluir(payload);
      }

      await (_db.delete(_db.syncQueueTable)..where((t) => t.id.equals(entry.id))).go();
      return true;
    } catch (e) {
      final newAttempts = entry.attempts + 1;
      // Após 3 tentativas marca como 'failed' — não tenta mais automaticamente.
      await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(entry.id))).write(
        SyncQueueTableCompanion(
          attempts: Value(newAttempts),
          status: newAttempts >= 3 ? const Value('failed') : const Value('pending'),
          errorMessage: Value(e.toString()),
        ),
      );
      return false;
    }
  }

  Future<void> _syncOcorrenciaInsert(Map<String, dynamic> payload) async {
    final localPaths = (payload.remove('_local_photo_paths') as List? ?? []).cast<String>();
    final municipioId = payload['municipio_id'] as String;

    final fotosUrls = <String>[];
    for (var i = 0; i < localPaths.length; i++) {
      final file = File(localPaths[i]);
      if (!await file.exists()) continue;
      final raw = await file.readAsBytes();
      final bytes = await ExifRemover.strip(raw);
      final path = '$municipioId/offline_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      await supabase.storage.from('ocorrencias-fotos').uploadBinary(path, bytes);
      fotosUrls.add(supabase.storage.from('ocorrencias-fotos').getPublicUrl(path));
      await file.delete();
    }

    payload['fotos'] = fotosUrls;
    await supabase.from('ocorrencias').insert(payload);
  }

  Future<void> _syncOrdemServicoUpdate(Map<String, dynamic> payload) async {
    final id = payload.remove('_id') as String;
    await supabase.from('ordens_servico').update(payload).eq('id', id);
  }

  Future<void> _syncOrdemServicoConcluir(Map<String, dynamic> payload) async {
    final id = payload.remove('_id') as String;
    final localPaths = (payload.remove('_local_photo_paths') as List? ?? []).cast<String>();

    final fotosUrls = <String>[];
    for (var i = 0; i < localPaths.length; i++) {
      final file = File(localPaths[i]);
      if (!await file.exists()) continue;
      final raw = await file.readAsBytes();
      final bytes = await ExifRemover.strip(raw);
      final path = 'depois/${id}_offline_$i.jpg';
      await supabase.storage.from('ocorrencias-fotos').uploadBinary(path, bytes);
      fotosUrls.add(supabase.storage.from('ocorrencias-fotos').getPublicUrl(path));
      await file.delete();
    }

    payload['fotos_depois'] = fotosUrls;
    await supabase.from('ordens_servico').update(payload).eq('id', id);
  }

  /// Adiciona uma operação à fila local para sincronização posterior.
  Future<void> enqueue({
    required String operation,
    required String table,
    required Map<String, dynamic> payload,
  }) async {
    if (kIsWeb) return;
    await _db.into(_db.syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            operation: operation,
            entityTable: table,
            payload: jsonEncode(payload),
          ),
        );
  }

  /// Número de operações pendentes — usado em badges de UI.
  Future<int> pendingCount() async {
    if (kIsWeb) return 0;
    final rows = await (_db.select(_db.syncQueueTable)..where((t) => t.status.equals('pending'))).get();
    return rows.length;
  }

  /// Copia fotos pra um diretório permanente do app antes de enfileirar —
  /// o path original (cache do picker/câmera) não é garantido sobreviver
  /// até a próxima reconexão.
  static Future<List<String>> savePhotosLocally(List<File> fotos, String subfolder) async {
    final dir = await getApplicationDocumentsDirectory();
    final localDir = Directory('${dir.path}/offline_photos/$subfolder');
    if (!await localDir.exists()) {
      await localDir.create(recursive: true);
    }
    final paths = <String>[];
    for (final foto in fotos) {
      final name = '${DateTime.now().millisecondsSinceEpoch}_${paths.length}.jpg';
      final dest = File('${localDir.path}/$name');
      await dest.writeAsBytes(await foto.readAsBytes());
      paths.add(dest.path);
    }
    return paths;
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final svc = SyncService(db, connectivity, ref);
  svc.startListening();
  ref.onDispose(svc.dispose);
  return svc;
});

/// Contagem de itens pendentes na fila — recalculada sempre que uma
/// operação é enfileirada ou sincronizada (via [syncVersionProvider]).
final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(syncVersionProvider);
  return ref.watch(syncServiceProvider).pendingCount();
});
