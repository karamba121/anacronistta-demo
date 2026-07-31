import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('TimeEntryRow')
class TimeEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();

  DateTimeColumn get occurredAt => dateTime()();
}

class WorkDaySchedules extends Table {
  IntColumn get weekday => integer()();

  BoolColumn get enabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {weekday};
}

class WorkShifts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get weekday => integer().references(WorkDaySchedules, #weekday)();

  IntColumn get startMinutes => integer()();

  IntColumn get endMinutes => integer()();

  IntColumn get position => integer()();
}

@DriftDatabase(tables: [TimeEntries, WorkDaySchedules, WorkShifts])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'anacronistta',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedDefaultSchedule();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(workDaySchedules);
        await migrator.createTable(workShifts);
        await _seedDefaultSchedule();
      }
    },
  );

  Future<void> _seedDefaultSchedule() async {
    await batch((batch) {
      batch.insertAll(workDaySchedules, [
        for (
          var weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        )
          WorkDaySchedulesCompanion.insert(
            weekday: Value(weekday),
            enabled: Value(weekday <= DateTime.friday),
          ),
      ]);

      batch.insertAll(workShifts, [
        for (
          var weekday = DateTime.monday;
          weekday <= DateTime.friday;
          weekday++
        ) ...[
          WorkShiftsCompanion.insert(
            weekday: weekday,
            startMinutes: 8 * 60,
            endMinutes: 11 * 60,
            position: 0,
          ),
          WorkShiftsCompanion.insert(
            weekday: weekday,
            startMinutes: 13 * 60,
            endMinutes: 17 * 60,
            position: 1,
          ),
        ],
      ]);
    });
  }
}
