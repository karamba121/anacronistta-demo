import 'package:anacronistta/app/modules/charts/charts_controller.dart';
import 'package:anacronistta/data/local/app_database.dart';
import 'package:anacronistta/data/repositories/schedule_repository.dart';
import 'package:anacronistta/data/repositories/time_entry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late TimeEntryRepository timeEntryRepository;
  late ScheduleRepository scheduleRepository;
  late ChartsController controller;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    timeEntryRepository = TimeEntryRepository(database);
    scheduleRepository = ScheduleRepository(database);
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test('resume pontos e saldo da semana usando a escala configurada', () async {
    final now = DateTime(2026, 7, 30, 18);
    final monday = DateTime(2026, 7, 27);

    await timeEntryRepository.register(
      'shift_0_start',
      monday.add(const Duration(hours: 8)),
    );
    await timeEntryRepository.register(
      'shift_0_end',
      monday.add(const Duration(hours: 11)),
    );
    await timeEntryRepository.register(
      'shift_1_start',
      monday.add(const Duration(hours: 13)),
    );
    await timeEntryRepository.register(
      'shift_1_end',
      monday.add(const Duration(hours: 17)),
    );

    controller = ChartsController(
      timeEntryRepository,
      scheduleRepository,
      clock: () => now,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(controller.days, hasLength(7));
    expect(controller.days.first.workedMinutes, 7 * 60);
    expect(controller.workedMinutes, 7 * 60);
    expect(controller.expectedMinutes, 4 * 7 * 60);
    expect(controller.balanceMinutes, -21 * 60);
    expect(controller.completedGoalDays, 1);
    expect(controller.evaluatedDays, 4);
  });
}
