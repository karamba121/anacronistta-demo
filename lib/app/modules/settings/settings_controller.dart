import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/schedule_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository) {
    _subscription = _repository.watchAll().listen(
      (schedules) {
        _schedules = schedules;
        _loading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        _errorMessage = 'Não foi possível carregar a escala.';
        notifyListeners();
      },
    );
  }

  final ScheduleRepository _repository;

  late final StreamSubscription<List<DaySchedule>> _subscription;
  List<DaySchedule> _schedules = const [];
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  List<DaySchedule> get schedules => _schedules;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get errorMessage => _errorMessage;

  Future<void> setDayEnabled(DaySchedule day, bool enabled) async {
    await _run(() async {
      if (enabled && day.shifts.isEmpty) {
        await _repository.addShift(
          weekday: day.weekday,
          startMinutes: 8 * 60,
          endMinutes: 12 * 60,
        );
      }
      await _repository.setDayEnabled(day.weekday, enabled);
    });
  }

  Future<void> addShift(DaySchedule day) async {
    final sorted = [...day.shifts]
      ..sort((first, second) => first.position.compareTo(second.position));
    final start = sorted.isEmpty ? 8 * 60 : sorted.last.endMinutes + 60;
    final end = (start + 4 * 60).clamp(0, 24 * 60);

    if (start >= end) {
      _setError('Não há espaço disponível para outro turno neste dia.');
      return;
    }

    await _run(
      () => _repository.addShift(
        weekday: day.weekday,
        startMinutes: start,
        endMinutes: end,
      ),
    );
  }

  Future<void> updateShift(
    DaySchedule day,
    WorkShiftModel shift, {
    int? startMinutes,
    int? endMinutes,
  }) async {
    final newStart = startMinutes ?? shift.startMinutes;
    final newEnd = endMinutes ?? shift.endMinutes;
    final overlaps = day.shifts.any(
      (other) =>
          other.id != shift.id &&
          newStart < other.endMinutes &&
          newEnd > other.startMinutes,
    );

    if (newStart >= newEnd) {
      _setError('O início do turno deve ser anterior ao término.');
      return;
    }
    if (overlaps) {
      _setError('Este turno se sobrepõe a outro horário do mesmo dia.');
      return;
    }

    await _run(
      () => _repository.updateShift(
        id: shift.id,
        startMinutes: newStart,
        endMinutes: newEnd,
      ),
    );
  }

  Future<void> deleteShift(DaySchedule day, WorkShiftModel shift) {
    return _run(() => _repository.deleteShift(shift.id, day.weekday));
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_saving) return;
    _saving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (_) {
      _errorMessage = 'Não foi possível salvar a alteração.';
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
