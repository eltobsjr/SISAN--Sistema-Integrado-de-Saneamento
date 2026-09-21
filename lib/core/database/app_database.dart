// Run after mudar tabelas: dart run build_runner build --delete-conflicting-outputs
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisan/core/database/tables/sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SyncQueueTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // Sem `web:` o driftDatabase lança na abertura do app no Flutter web.
    // A fila offline é do mobile; no web os assets só são exigidos se o
    // banco for de fato usado.
    return driftDatabase(
      name: 'sisan_local',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
