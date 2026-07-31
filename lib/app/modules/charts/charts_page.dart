import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../config/app_colors.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/time_entry_repository.dart';
import '../../widgets/neumorphic_card.dart';
import 'charts_controller.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  late final ChartsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChartsController(
      Modular.get<TimeEntryRepository>(),
      Modular.get<ScheduleRepository>(),
    );
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 700 ? 40.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Resumo da jornada',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Semana de ${_controller.periodLabel}.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (_controller.errorMessage case final message?) ...[
                        const SizedBox(height: 14),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.variant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.schedule_rounded,
                              value: _formatDuration(_controller.workedMinutes),
                              label: 'Trabalhadas',
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.bolt_rounded,
                              value: _formatBalance(_controller.balanceMinutes),
                              label: 'Saldo',
                              color: _controller.balanceMinutes >= 0
                                  ? AppColors.accent
                                  : AppColors.variant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      NeumorphicCard(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                'Horas por dia',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                'Metas conforme sua jornada configurada',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: 190,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (final day in _controller.days)
                                    Expanded(child: _DayBar(day: day)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _BalanceBanner(
                        completedDays: _controller.completedGoalDays,
                        evaluatedDays: _controller.evaluatedDays,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.day});

  final WeekDaySummary day;

  @override
  Widget build(BuildContext context) {
    final scaleMinutes = [
      day.workedMinutes,
      day.expectedMinutes,
      60,
    ].reduce((first, second) => first > second ? first : second);
    final heightFactor = (day.workedMinutes / scaleMinutes).clamp(0.0, 1.0);
    final targetFactor = day.expectedMinutes / scaleMinutes;
    final barColor = day.isFuture
        ? AppColors.shadow
        : day.meetsGoal
        ? AppColors.accent
        : AppColors.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(
            child: Text(
              _formatCompact(day.workedMinutes),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (day.hasExpectedWork)
                      Positioned(
                        bottom:
                            (constraints.maxHeight * targetFactor).clamp(
                              0,
                              constraints.maxHeight - 1,
                            ) -
                            1,
                        left: 1,
                        right: 1,
                        child: Container(
                          height: 2,
                          color: AppColors.accent.withValues(alpha: .45),
                        ),
                      ),
                    FractionallySizedBox(
                      heightFactor: heightFactor,
                      widthFactor: .62,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(_weekdayShort(day.date.weekday)),
        ],
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({
    required this.completedDays,
    required this.evaluatedDays,
  });

  final int completedDays;
  final int evaluatedDays;

  @override
  Widget build(BuildContext context) {
    final hasEvaluatedDays = evaluatedDays > 0;

    return NeumorphicCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEvaluatedDays ? 'Progresso da semana' : 'Semana iniciada',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEvaluatedDays
                      ? 'Meta cumprida em $completedDays de '
                            '$evaluatedDays ${evaluatedDays == 1 ? 'dia avaliado' : 'dias avaliados'}.'
                      : 'Ainda não há dias de trabalho para avaliar.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return '${hours}h${remainder.toString().padLeft(2, '0')}';
}

String _formatBalance(int minutes) {
  final prefix = minutes >= 0 ? '+' : '-';
  return '$prefix${_formatDuration(minutes.abs())}';
}

String _formatCompact(int minutes) {
  if (minutes == 0) return '0h';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) return '${hours}h';
  return '${hours}h${remainder.toString().padLeft(2, '0')}';
}

String _weekdayShort(int weekday) {
  return const {
        DateTime.monday: 'Seg',
        DateTime.tuesday: 'Ter',
        DateTime.wednesday: 'Qua',
        DateTime.thursday: 'Qui',
        DateTime.friday: 'Sex',
        DateTime.saturday: 'Sáb',
        DateTime.sunday: 'Dom',
      }[weekday] ??
      '';
}
