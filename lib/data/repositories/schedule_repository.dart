import 'package:drift/drift.dart';

import '../local/app_database.dart';

class WorkShiftModel {
  const WorkShiftModel({
    required this.id,
    required this.startMinutes,
    required this.endMinutes,
    required this.position,
  });

  final int id;
  final int startMinutes;
  final int endMinutes;
  final int position;

  int get durationMinutes => endMinutes - startMinutes;
}

class DaySchedule {
  const DaySchedule({
    required this.weekday,
    required this.enabled,
    required this.shifts,
  });

  final int weekday;
  final bool enabled;
  final List<WorkShiftModel> shifts;

  int get totalMinutes {
    if (!enabled) return 0;
    return shifts.fold(0, (total, shift) => total + shift.durationMinutes);
  }
}

class InvalidShiftException implements Exception {
  const InvalidShiftException();
}

class ScheduleRepository {
  ScheduleRepository(this._database);

  final AppDatabase _database;

  Stream<List<DaySchedule>> watchAll() {
    return _joinedQuery().watch().map(_mapRows);
  }

  Future<List<DaySchedule>> getAll() async {
    return _mapRows(await _joinedQuery().get());
  }

  Future<void> setDayEnabled(int weekday, bool enabled) {
    return (_database.update(_database.workDaySchedules)
          ..where((day) => day.weekday.equals(weekday)))
        .write(WorkDaySchedulesCompanion(enabled: Value(enabled)));
  }

  Future<int> addShift({
    required int weekday,
    required int startMinutes,
    required int endMinutes,
  }) async {
    _validateShift(startMinutes, endMinutes);
    final currentShifts = await (_database.select(
      _database.workShifts,
    )..where((shift) => shift.weekday.equals(weekday))).get();
    final nextPosition = currentShifts.isEmpty
        ? 0
        : currentShifts
                  .map((shift) => shift.position)
                  .reduce((first, second) => first > second ? first : second) +
              1;

    return _database
        .into(_database.workShifts)
        .insert(
          WorkShiftsCompanion.insert(
            weekday: weekday,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            position: nextPosition,
          ),
        );
  }

  Future<void> updateShift({
    required int id,
    required int startMinutes,
    required int endMinutes,
  }) {
    _validateShift(startMinutes, endMinutes);
    return (_database.update(
      _database.workShifts,
    )..where((shift) => shift.id.equals(id))).write(
      WorkShiftsCompanion(
        startMinutes: Value(startMinutes),
        endMinutes: Value(endMinutes),
      ),
    );
  }

  Future<void> deleteShift(int id, int weekday) {
    return _database.transaction(() async {
      await (_database.delete(
        _database.workShifts,
      )..where((shift) => shift.id.equals(id))).go();

      final remaining =
          await (_database.select(_database.workShifts)
                ..where((shift) => shift.weekday.equals(weekday))
                ..orderBy([(shift) => OrderingTerm.asc(shift.position)]))
              .get();

      for (var index = 0; index < remaining.length; index++) {
        await (_database.update(_database.workShifts)
              ..where((shift) => shift.id.equals(remaining[index].id)))
            .write(WorkShiftsCompanion(position: Value(index)));
      }
    });
  }

  JoinedSelectStatement<HasResultSet, dynamic> _joinedQuery() {
    return _database.select(_database.workDaySchedules).join([
      leftOuterJoin(
        _database.workShifts,
        _database.workShifts.weekday.equalsExp(
          _database.workDaySchedules.weekday,
        ),
      ),
    ])..orderBy([
      OrderingTerm.asc(_database.workDaySchedules.weekday),
      OrderingTerm.asc(_database.workShifts.position),
    ]);
  }

  List<DaySchedule> _mapRows(List<TypedResult> rows) {
    final schedules = <int, DaySchedule>{};

    for (final row in rows) {
      final day = row.readTable(_database.workDaySchedules);
      final shift = row.readTableOrNull(_database.workShifts);
      final existing = schedules[day.weekday];
      final shifts = [...?existing?.shifts];

      if (shift != null) {
        shifts.add(
          WorkShiftModel(
            id: shift.id,
            startMinutes: shift.startMinutes,
            endMinutes: shift.endMinutes,
            position: shift.position,
          ),
        );
      }

      schedules[day.weekday] = DaySchedule(
        weekday: day.weekday,
        enabled: day.enabled,
        shifts: shifts,
      );
    }

    return [
      for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
        schedules[weekday] ??
            DaySchedule(weekday: weekday, enabled: false, shifts: const []),
    ];
  }

  void _validateShift(int startMinutes, int endMinutes) {
    if (startMinutes < 0 ||
        endMinutes > const Duration(days: 1).inMinutes ||
        startMinutes >= endMinutes) {
      throw const InvalidShiftException();
    }
  }
}
