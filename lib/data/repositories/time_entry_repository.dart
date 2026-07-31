import 'package:drift/drift.dart';

import '../local/app_database.dart';

class DuplicateTimeEntryException implements Exception {
  const DuplicateTimeEntryException();
}

class TimeEntryRepository {
  TimeEntryRepository(this._database);

  final AppDatabase _database;

  Stream<List<TimeEntryRow>> watchForDay(DateTime date) {
    return _queryForDay(date).watch();
  }

  Future<List<TimeEntryRow>> getForDay(DateTime date) {
    return _queryForDay(date).get();
  }

  Stream<List<TimeEntryRow>> watchBetween(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    return _queryBetween(startInclusive, endExclusive).watch();
  }

  Future<List<TimeEntryRow>> getBetween(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    return _queryBetween(startInclusive, endExclusive).get();
  }

  Future<void> register(String type, DateTime occurredAt) {
    return _database.transaction(() async {
      final entries = await getForDay(occurredAt);
      if (entries.any((entry) => entry.type == type)) {
        throw const DuplicateTimeEntryException();
      }

      await _database
          .into(_database.timeEntries)
          .insert(
            TimeEntriesCompanion.insert(type: type, occurredAt: occurredAt),
          );
    });
  }

  SimpleSelectStatement<$TimeEntriesTable, TimeEntryRow> _queryForDay(
    DateTime date,
  ) {
    final (start, end) = _dayRange(date);
    return _queryBetween(start, end);
  }

  SimpleSelectStatement<$TimeEntriesTable, TimeEntryRow> _queryBetween(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    return _database.select(_database.timeEntries)
      ..where(
        (entry) =>
            entry.occurredAt.isBiggerOrEqualValue(startInclusive) &
            entry.occurredAt.isSmallerThanValue(endExclusive),
      )
      ..orderBy([(entry) => OrderingTerm.asc(entry.occurredAt)]);
  }

  (DateTime, DateTime) _dayRange(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    return (start, start.add(const Duration(days: 1)));
  }
}
