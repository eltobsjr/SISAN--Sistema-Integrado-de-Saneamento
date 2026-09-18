import 'package:drift/drift.dart';

@DataClassName('SyncQueueEntry')
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();

  // 'INSERT' | 'ACEITAR' | 'CHEGADA' | 'CONCLUIR'
  TextColumn get operation => text()();

  // Nome da tabela Supabase alvo (ex: 'ocorrencias', 'ordens_servico')
  TextColumn get entityTable => text().named('entity_table')();

  // Payload JSON da operação
  TextColumn get payload => text()();

  // 'pending' | 'failed'
  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get errorMessage => text().nullable().named('error_message')();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}
