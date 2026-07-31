import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../config/app_colors.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/time_entry_repository.dart';
import '../../widgets/animated_clock.dart';
import '../../widgets/process_timeline.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
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
                        'Olá, viajante do tempo',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Acompanhe sua jornada de hoje.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: AnimatedClock(
                          hourText: _controller.elapsedText,
                          percentage: _controller.percentage,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          _controller.hasExpectedWork
                              ? 'de ${_controller.expectedDurationText}'
                              : 'Dia sem expediente configurado',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      if (_controller.points.isEmpty)
                        const _RestDayCard()
                      else
                        ProcessTimeline(points: _controller.points),
                      const SizedBox(height: 34),
                      Center(
                        child: _ClockActionButton(
                          isSaving: _controller.isSaving,
                          isComplete: _controller.isJourneyComplete,
                          isRestDay: !_controller.hasExpectedWork,
                          onPressed:
                              _controller.isLoading ||
                                  _controller.isSaving ||
                                  !_controller.canRegister
                              ? null
                              : _registerPoint,
                        ),
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

  Future<void> _registerPoint() async {
    final recordedLabel = await _controller.registerPoint();
    if (!mounted) return;

    final message = recordedLabel != null
        ? '$recordedLabel registrado com sucesso.'
        : _controller.errorMessage;
    if (message == null) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
    _controller.clearError();
  }
}

class _ClockActionButton extends StatelessWidget {
  const _ClockActionButton({
    required this.onPressed,
    required this.isSaving,
    required this.isComplete,
    required this.isRestDay,
  });

  final VoidCallback? onPressed;
  final bool isSaving;
  final bool isComplete;
  final bool isRestDay;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Column(
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: _label,
          child: AnimatedOpacity(
            opacity: enabled ? 1 : .58,
            duration: const Duration(milliseconds: 180),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF64D2D2),
                    AppColors.accent,
                    Color(0xFF21A9BC),
                  ],
                  stops: [0, .55, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: Offset(10, 10),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: AppColors.highlight,
                    offset: Offset(-9, -9),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: Color(0x3821A9BC),
                    offset: Offset(5, 7),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onPressed,
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                  child: SizedBox.square(
                    dimension: 70,
                    child: Center(
                      child: isSaving
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.6,
                              ),
                            )
                          : Icon(
                              isComplete
                                  ? Icons.check_rounded
                                  : Icons.power_settings_new_rounded,
                              color: Colors.white,
                              size: 27,
                              shadows: const [
                                Shadow(
                                  color: Color(0x55006473),
                                  offset: Offset(1, 2),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String get _label {
    if (isRestDay) return 'Dia sem expediente';
    if (isComplete) return 'Jornada concluída';
    return 'Registrar ponto';
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(7, 7),
            blurRadius: 16,
          ),
          BoxShadow(
            color: AppColors.highlight,
            offset: Offset(-7, -7),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.weekend_rounded, color: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Nenhuma jornada é esperada para hoje.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
