import 'package:anacronistta/data/local/app_database.dart';
import 'package:anacronistta/data/repositories/schedule_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ScheduleRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ScheduleRepository(database);
  });

  tearDown(() => database.close());

  test('cria escala comercial de segunda a sexta com sete horas', () async {
    final schedules = await repository.getAll();

    expect(schedules, hasLength(7));
    for (final day in schedules.take(5)) {
      expect(day.enabled, isTrue);
      expect(day.shifts, hasLength(2));
      expect(day.shifts[0].startMinutes, 8 * 60);
      expect(day.shifts[0].endMinutes, 11 * 60);
      expect(day.shifts[1].startMinutes, 13 * 60);
      expect(day.shifts[1].endMinutes, 17 * 60);
      expect(day.totalMinutes, 7 * 60);
    }

    expect(schedules[5].enabled, isFalse);
    expect(schedules[6].enabled, isFalse);
  });

  test('salva alterações de dias e turnos', () async {
    await repository.setDayEnabled(DateTime.saturday, true);
    await repository.addShift(
      weekday: DateTime.saturday,
      startMinutes: 9 * 60,
      endMinutes: 13 * 60,
    );

    final saturday = (await repository.getAll())[5];
    expect(saturday.enabled, isTrue);
    expect(saturday.shifts, hasLength(1));
    expect(saturday.totalMinutes, 4 * 60);
  });
}
