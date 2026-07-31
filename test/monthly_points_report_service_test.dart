import 'package:anacronistta/data/local/app_database.dart';
import 'package:anacronistta/data/repositories/schedule_repository.dart';
import 'package:anacronistta/data/repositories/time_entry_repository.dart';
import 'package:anacronistta/data/services/monthly_points_report_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late TimeEntryRepository timeEntryRepository;
  late ScheduleRepository scheduleRepository;
  late MonthlyPointsReportService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    timeEntryRepository = TimeEntryRepository(database);
    scheduleRepository = ScheduleRepository(database);
    service = MonthlyPointsReportService(
      timeEntryRepository,
      scheduleRepository,
    );
  });

  tearDown(() => database.close());

  test('gera relatório do mês anterior com pontos, horas e saldo', () async {
    final monday = DateTime(2026, 6, 1);
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

    final report = await service.loadPreviousMonth(
      referenceDate: DateTime(2026, 7, 30),
    );

    expect(report.start, DateTime(2026, 6));
    expect(report.endExclusive, DateTime(2026, 7));
    expect(report.pointCount, 4);
    expect(report.workedMinutes, 7 * 60);
    expect(report.expectedDayCount, 22);
    expect(report.expectedMinutes, 22 * 7 * 60);
    expect(report.balanceMinutes, -21 * 7 * 60);
    expect(report.days.first.isComplete, isTrue);
  });

  test('produz um arquivo PDF válido', () async {
    final monday = DateTime(2026, 6, 1);
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
    final report = await service.loadPreviousMonth(
      referenceDate: DateTime(2026, 7, 30),
    );

    final bytes = await service.buildPdf(report);

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
