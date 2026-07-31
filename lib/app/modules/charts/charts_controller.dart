import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/local/app_database.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/time_entry_repository.dart';

class WeekDaySummary {
  const WeekDaySummary({
    required this.date,
    required this.workedMinutes,
    required this.expectedMinutes,
    required this.isFuture,
  });

  final DateTime date;
  final int workedMinutes;
  final int expectedMinutes;
  final bool isFuture;

  bool get hasExpectedWork => expectedMinutes > 0;
  bool get meetsGoal =>
      !isFuture && hasExpectedWork && workedMinutes >= expectedMinutes;
}

class ChartsController extends ChangeNotifier {
  ChartsController(
    this._timeEntryRepository,
    this._scheduleRepository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _now = _clock();
    _watchWeek();
    _scheduleSubscription = _scheduleRepository.watchAll().listen(
      (schedules) {
        _schedules = schedules;
        _scheduleLoaded = true;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _scheduleLoaded = true;
        _errorMessage = 'Não foi possível carregar a escala.';
        notifyListeners();
      },
    );
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _onMinute());
  }

  final TimeEntryRepository _timeEntryRepository;
  final ScheduleRepository _scheduleRepository;
  final DateTime Function() _clock;

  StreamSubscription<List<TimeEntryRow>>? _entrySubscription;
  late final StreamSubscription<List<DaySchedule>> _scheduleSubscription;
  Timer? _timer;
  List<TimeEntryRow> _entries = const [];
  List<DaySchedule> _schedules = const [];
  late DateTime _now;
  late DateTime _weekStart;
  bool _entriesLoaded = false;
  bool _scheduleLoaded = false;
  String? _errorMessage;

  bool get isLoading => !_entriesLoaded || !_scheduleLoaded;
  String? get errorMessage => _errorMessage;

  List<WeekDaySummary> get days {
    return [
      for (var offset = 0; offset < DateTime.daysPerWeek; offset++)
        _summaryFor(_weekStart.add(Duration(days: offset))),
    ];
  }

  int get workedMinutes {
    return days.fold(0, (total, day) => total + day.workedMinutes);
  }

  int get expectedMinutes {
    return days
        .where((day) => !day.isFuture)
        .fold(0, (total, day) => total + day.expectedMinutes);
  }

  int get balanceMinutes => workedMinutes - expectedMinutes;

  int get evaluatedDays {
    return days.where((day) => !day.isFuture && day.hasExpectedWork).length;
  }

  int get completedGoalDays => days.where((day) => day.meetsGoal).length;

  String get periodLabel {
    final end = _weekStart.add(const Duration(days: 6));
    return '${_formatDate(_weekStart)} a ${_formatDate(end)}';
  }

  WeekDaySummary _summaryFor(DateTime date) {
    final schedule = _scheduleFor(date.weekday);
    final expected = schedule?.totalMinutes ?? 0;
    final dateEntries = _entries.where(
      (entry) => _isSameDay(entry.occurredAt, date),
    );

    return WeekDaySummary(
      date: date,
      workedMinutes: _workedMinutesFor(
        date,
        dateEntries.toList(growable: false),
        schedule,
      ),
      expectedMinutes: expected,
      isFuture: _dateOnly(date).isAfter(_dateOnly(_now)),
    );
  }

  int _workedMinutesFor(
    DateTime date,
    List<TimeEntryRow> entries,
    DaySchedule? schedule,
  ) {
    if (schedule == null || !schedule.enabled) return 0;
    final shifts = [...schedule.shifts]
      ..sort((first, second) => first.position.compareTo(second.position));
    var total = Duration.zero;

    for (var index = 0; index < shifts.length; index++) {
      final start = _findEntry(entries, 'shift_${index}_start', [
        if (index == 0) 'entry',
        if (index == 1) 'break_end',
      ]);
      if (start == null) continue;

      final end = _findEntry(entries, 'shift_${index}_end', [
        if (index == 0 && shifts.length > 1) 'break_start',
        if (index == shifts.length - 1) 'exit',
      ]);
      final isToday = _isSameDay(date, _now);
      final periodEnd = end?.occurredAt ?? (isToday ? _now : null);

      if (periodEnd != null && periodEnd.isAfter(start.occurredAt)) {
        total += periodEnd.difference(start.occurredAt);
      }
    }

    return total.inMinutes;
  }

  TimeEntryRow? _findEntry(
    List<TimeEntryRow> entries,
    String storageKey,
    List<String> aliases,
  ) {
    for (final entry in entries) {
      if (entry.type == storageKey || aliases.contains(entry.type)) {
        return entry;
      }
    }
    return null;
  }

  DaySchedule? _scheduleFor(int weekday) {
    for (final schedule in _schedules) {
      if (schedule.weekday == weekday) return schedule;
    }
    return null;
  }

  void _watchWeek() {
    _weekStart = _startOfWeek(_now);
    _entrySubscription?.cancel();
    _entrySubscription = _timeEntryRepository
        .watchBetween(
          _weekStart,
          _weekStart.add(const Duration(days: DateTime.daysPerWeek)),
        )
        .listen(
          (entries) {
            _entries = entries;
            _entriesLoaded = true;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _entriesLoaded = true;
            _errorMessage = 'Não foi possível carregar os pontos.';
            notifyListeners();
          },
        );
  }

  void _onMinute() {
    final previousWeek = _weekStart;
    _now = _clock();
    if (!_isSameDay(previousWeek, _startOfWeek(_now))) {
      _entries = const [];
      _entriesLoaded = false;
      _watchWeek();
    }
    notifyListeners();
  }

  DateTime _startOfWeek(DateTime date) {
    final day = _dateOnly(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _entrySubscription?.cancel();
    _scheduleSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
