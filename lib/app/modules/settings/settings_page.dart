import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../config/app_colors.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../widgets/neumorphic_card.dart';
import 'settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController(Modular.get<ScheduleRepository>());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Configurações de jornada',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Defina os dias esperados e os turnos de cada jornada.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (_controller.errorMessage case final message?) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(
                      message: message,
                      onClose: _controller.clearError,
                    ),
                  ],
                  const SizedBox(height: 22),
                  for (final day in _controller.schedules) ...[
                    _DayScheduleCard(
                      day: day,
                      disabled: _controller.isSaving,
                      onEnabledChanged: (enabled) {
                        _controller.setDayEnabled(day, enabled);
                      },
                      onAddShift: () => _controller.addShift(day),
                      onEditStart: (shift) =>
                          _pickTime(day, shift, editingStart: true),
                      onEditEnd: (shift) =>
                          _pickTime(day, shift, editingStart: false),
                      onDelete: (shift) {
                        _controller.deleteShift(day, shift);
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickTime(
    DaySchedule day,
    WorkShiftModel shift, {
    required bool editingStart,
  }) async {
    final currentMinutes = editingStart ? shift.startMinutes : shift.endMinutes;
    final selected = await showTimePicker(
      context: context,
      initialTime: _toTimeOfDay(currentMinutes),
      helpText: editingStart ? 'Início do turno' : 'Término do turno',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );
    if (selected == null) return;

    final minutes = selected.hour * 60 + selected.minute;
    await _controller.updateShift(
      day,
      shift,
      startMinutes: editingStart ? minutes : null,
      endMinutes: editingStart ? null : minutes,
    );
  }
}

class _DayScheduleCard extends StatelessWidget {
  const _DayScheduleCard({
    required this.day,
    required this.disabled,
    required this.onEnabledChanged,
    required this.onAddShift,
    required this.onEditStart,
    required this.onEditEnd,
    required this.onDelete,
  });

  final DaySchedule day;
  final bool disabled;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onAddShift;
  final ValueChanged<WorkShiftModel> onEditStart;
  final ValueChanged<WorkShiftModel> onEditEnd;
  final ValueChanged<WorkShiftModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final shifts = [...day.shifts]
      ..sort((first, second) => first.position.compareTo(second.position));

    return NeumorphicCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weekdayLabel(day.weekday),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      day.enabled
                          ? '${_formatDuration(day.totalMinutes)} previstas'
                          : 'Sem expediente',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: day.enabled,
                activeTrackColor: AppColors.accent,
                onChanged: disabled ? null : onEnabledChanged,
              ),
            ],
          ),
          if (day.enabled) ...[
            const SizedBox(height: 14),
            if (shifts.isEmpty)
              Text(
                'Adicione ao menos um turno.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.variant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            for (var index = 0; index < shifts.length; index++) ...[
              _ShiftRow(
                index: index,
                shift: shifts[index],
                disabled: disabled,
                onEditStart: () => onEditStart(shifts[index]),
                onEditEnd: () => onEditEnd(shifts[index]),
                onDelete: () => onDelete(shifts[index]),
              ),
              if (index < shifts.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: disabled ? null : onAddShift,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adicionar turno'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({
    required this.index,
    required this.shift,
    required this.disabled,
    required this.onEditStart,
    required this.onEditEnd,
    required this.onDelete,
  });

  final int index;
  final WorkShiftModel shift;
  final bool disabled;
  final VoidCallback onEditStart;
  final VoidCallback onEditEnd;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _TimeButton(
                value: _formatTime(shift.startMinutes),
                enabled: !disabled,
                onPressed: onEditStart,
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              _TimeButton(
                value: _formatTime(shift.endMinutes),
                enabled: !disabled,
                onPressed: onEditEnd,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: disabled ? null : onDelete,
          tooltip: 'Remover turno',
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.variant,
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.value,
    required this.enabled,
    required this.onPressed,
  });

  final String value;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.shadow),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.variant.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.variant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: AppColors.variant,
            ),
          ],
        ),
      ),
    );
  }
}

String _weekdayLabel(int weekday) {
  return const {
        DateTime.monday: 'Segunda-feira',
        DateTime.tuesday: 'Terça-feira',
        DateTime.wednesday: 'Quarta-feira',
        DateTime.thursday: 'Quinta-feira',
        DateTime.friday: 'Sexta-feira',
        DateTime.saturday: 'Sábado',
        DateTime.sunday: 'Domingo',
      }[weekday] ??
      '';
}

String _formatTime(int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder}min';
}

TimeOfDay _toTimeOfDay(int minutes) {
  return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
}
