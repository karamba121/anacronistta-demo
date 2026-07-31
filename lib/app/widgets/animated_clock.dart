import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import 'connection_indicator.dart';

class AnimatedClock extends StatelessWidget {
  const AnimatedClock({
    required this.hourText,
    required this.percentage,
    super.key,
  });

  final String hourText;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 224,
          height: 224,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: Offset(10, 10),
                      blurRadius: 22,
                    ),
                    BoxShadow(
                      color: AppColors.highlight,
                      offset: Offset(-10, -10),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: SizedBox.expand(),
              ),
              CustomPaint(
                size: const Size.square(196),
                painter: _ClockProgressPainter(progress: value),
              ),
              Container(
                width: 144,
                height: 144,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: Offset(5, 5),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: AppColors.highlight,
                      offset: Offset(-5, -5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  hourText,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              const Positioned(
                top: 15,
                child: ConnectionIndicator(neumorphicContrast: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClockProgressPainter extends CustomPainter {
  const _ClockProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 13;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    final track = Paint()
      ..color = AppColors.shadow.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + math.pi * 2,
        colors: [Color(0x552BB3C5), AppColors.accent],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ClockProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
