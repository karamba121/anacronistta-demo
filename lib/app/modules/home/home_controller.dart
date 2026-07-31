import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/local/app_database.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/time_entry_repository.dart';
import '../../widgets/process_timeline.dart';

class HomeController extends ChangeNotifier {
  HomeController(
    this._timeEntryRepository,
    this._scheduleRepository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _now = _clock();
    _watchCurrentDay();
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
  late DateTime _watchedDay;
  bool _entriesLoaded = false;
  bool _scheduleLoaded = false;
  bool _saving = false;
  String? _errorMessage;

  bool get isLoading => !_entriesLoaded || !_scheduleLoaded;
  bool get isSaving => _saving;
  String? get errorMessage => _errorMessage;

  DaySchedule? get todaySchedule {
    return _schedules
        .where((schedule) => schedule.weekday == _now.weekday)
        .firstOrNull;
  }

  bool get hasExpectedWork {
    final schedule = todaySchedule;
    return schedule != null && schedule.enabled && schedule.shifts.isNotEmpty;
  }

  bool get canRegister => hasExpectedWork && _nextDefinition != null;

  bool get isJourneyComplete =>
      hasExpectedWork && _definitions.isNotEmpty && _nextDefinition == null;

  String get elapsedText {
    final duration = _elapsedDuration;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  double get percentage {
    final expectedMinutes = todaySchedule?.totalMinutes ?? 0;
    if (expectedMinutes <= 0) return 0;
    return (_elapsedDuration.inMinutes / expectedMinutes).clamp(0, 1);
  }

  String get expectedDurationText {
    final minutes = todaySchedule?.totalMinutes ?? 0;
    if (minutes <= 0) return 'dia sem expediente';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) {
      return '$hours ${hours == 1 ? 'hora prevista' : 'horas previstas'}';
    }
    return '${hours}h ${remainder}min previstos';
  }

  List<TimePoint> get points {
    final definitions = _definitions;
    final next = _nextDefinition;

    return [
      for (final definition in definitions)
        TimePoint(
          label: definition.label,
          time: _displayTimeFor(definition),
          status: _entryFor(definition) != null
              ? TimePointStatus.complete
              : definition.storageKey == next?.storageKey
              ? TimePointStatus.current
              : TimePointStatus.pending,
        ),
    ];
  }

  Future<String?> registerPoint() async {
    final definition = _nextDefinition;
    if (_saving || definition == null || !hasExpectedWork) return null;

    _saving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _timeEntryRepository.register(definition.storageKey, _clock());
      return definition.label;
    } on DuplicateTimeEntryException {
      _errorMessage = 'Este ponto já foi registrado.';
      return null;
    } catch (_) {
      _errorMessage = 'Não foi possível registrar o ponto.';
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  List<_PointDefinition> get _definitions {
    final schedule = todaySchedule;
    if (schedule == null || !schedule.enabled) return const [];
    final shifts = [...schedule.shifts]
      ..sort((first, second) => first.position.compareTo(second.position));

    return [
      for (var index = 0; index < shifts.length; index++) ...[
        _PointDefinition(
          storageKey: 'shift_${index}_start',
          aliases: [if (index == 0) 'entry', if (index == 1) 'break_end'],
          label: index == 0
              ? 'Entrada'
              : index == 1
              ? 'Retorno'
              : 'Retorno ${index + 1}',
        ),
        _PointDefinition(
          storageKey: 'shift_${index}_end',
          aliases: [
            if (index == 0 && shifts.length > 1) 'break_start',
            if (index == shifts.length - 1) 'exit',
          ],
          label: index == shifts.length - 1
              ? 'Saída'
              : index == 0
              ? 'Pausa'
              : 'Pausa ${index + 1}',
        ),
      ],
    ];
  }

  _PointDefinition? get _nextDefinition {
    return _definitions
        .where((definition) => _entryFor(definition) == null)
        .firstOrNull;
  }

  TimeEntryRow? _entryFor(_PointDefinition definition) {
    return _entries
        .where(
          (entry) =>
              entry.type == definition.storageKey ||
              definition.aliases.contains(entry.type),
        )
        .firstOrNull;
  }

  String _displayTimeFor(_PointDefinition definition) {
    final entry = _entryFor(definition);
    return entry == null ? '--:--' : _formatTime(entry.occurredAt);
  }

  Duration get _elapsedDuration {
    final definitions = _definitions;
    var elapsed = Duration.zero;

    for (var index = 0; index + 1 < definitions.length; index += 2) {
      final start = _entryFor(definitions[index]);
      if (start == null) continue;
      final end = _entryFor(definitions[index + 1]);
      final periodEnd = end?.occurredAt ?? _now;
      if (periodEnd.isAfter(start.occurredAt)) {
        elapsed += periodEnd.difference(start.occurredAt);
      }
    }

    return elapsed;
  }

  void _watchCurrentDay() {
    _watchedDay = _clock();
    _entrySubscription?.cancel();
    _entrySubscription = _timeEntryRepository
        .watchForDay(_watchedDay)
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
    _now = _clock();
    if (!_isSameDay(_now, _watchedDay)) {
      _entries = const [];
      _entriesLoaded = false;
      _watchCurrentDay();
    }
    notifyListeners();
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _entrySubscription?.cancel();
    _scheduleSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

class _PointDefinition {
  const _PointDefinition({
    required this.storageKey,
    required this.aliases,
    required this.label,
  });

  final String storageKey;
  final List<String> aliases;
  final String label;
}
