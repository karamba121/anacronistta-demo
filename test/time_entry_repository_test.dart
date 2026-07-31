import 'dart:io';

import 'package:anacronistta/data/local/app_database.dart';
import 'package:anacronistta/data/repositories/time_entry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _pointKeys = [
  'shift_0_start',
  'shift_0_end',
  'shift_1_start',
  'shift_1_end',
];

void main() {
  group('TimeEntryRepository', () {
    late AppDatabase database;
    late TimeEntryRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = TimeEntryRepository(database);
    });

    tearDown(() => database.close());

    test('registra os pontos na ordem informada', () async {
      final day = DateTime(2026, 7, 30, 8);

      for (var index = 0; index < _pointKeys.length; index++) {
        await repository.register(
          _pointKeys[index],
          day.add(Duration(hours: index * 2)),
        );
      }

      final entries = await repository.getForDay(day);
      expect(entries.map((entry) => entry.type), _pointKeys);
    });

    test('não permite o mesmo ponto duas vezes no dia', () async {
      final day = DateTime(2026, 7, 30, 8);
      await repository.register(_pointKeys.first, day);

      expect(
        () => repository.register(
          _pointKeys.first,
          day.add(const Duration(minutes: 1)),
        ),
        throwsA(isA<DuplicateTimeEntryException>()),
      );
    });

    test('separa registros de dias diferentes', () async {
      final firstDay = DateTime(2026, 7, 30, 8);
      final secondDay = DateTime(2026, 7, 31, 8);

      await repository.register(_pointKeys.first, firstDay);
      await repository.register(_pointKeys.first, secondDay);

      expect(await repository.getForDay(firstDay), hasLength(1));
      expect(await repository.getForDay(secondDay), hasLength(1));
    });

    test('consulta os pontos dentro de um período', () async {
      final monday = DateTime(2026, 7, 27, 8);
      final nextMonday = monday.add(const Duration(days: 7));
      await repository.register(_pointKeys.first, monday);
      await repository.register(
        _pointKeys.first,
        nextMonday.add(const Duration(hours: 1)),
      );

      final entries = await repository.getBetween(monday, nextMonday);

      expect(entries, hasLength(1));
      expect(entries.single.occurredAt, monday);
    });
  });

  test('mantém os pontos após fechar e reabrir o banco', () async {
    final directory = await Directory.systemTemp.createTemp(
      'anacronistta_drift_test',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}points.sqlite',
    );
    final day = DateTime(2026, 7, 30, 8);

    final firstDatabase = AppDatabase.forTesting(NativeDatabase(file));
    final firstRepository = TimeEntryRepository(firstDatabase);
    await firstRepository.register(_pointKeys.first, day);
    await firstDatabase.close();

    final reopenedDatabase = AppDatabase.forTesting(NativeDatabase(file));
    final reopenedRepository = TimeEntryRepository(reopenedDatabase);

    try {
      final entries = await reopenedRepository.getForDay(day);
      expect(entries, hasLength(1));
      expect(entries.single.type, _pointKeys.first);
    } finally {
      await reopenedDatabase.close();
      await directory.delete(recursive: true);
    }
  });
}
