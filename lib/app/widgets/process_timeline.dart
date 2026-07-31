import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../config/app_colors.dart';

enum TimePointStatus { complete, current, pending }

class TimePoint {
  const TimePoint({
    required this.label,
    required this.time,
    required this.status,
  });

  final String label;
  final String time;
  final TimePointStatus status;
}

class ProcessTimeline extends StatelessWidget {
  const ProcessTimeline({required this.points, super.key});

  final List<TimePoint> points;

  int get currentIndex {
    final index = points.indexWhere(
      (point) => point.status == TimePointStatus.current,
    );
    return index < 0 ? points.length : index;
  }

  Color colorFor(TimePoint point) {
    return switch (point.status) {
      TimePointStatus.complete => AppColors.accent,
      TimePointStatus.current => AppColors.text,
      TimePointStatus.pending => AppColors.shadow,
    };
  }

  Color colorForIndex(int index) => colorFor(points[index]);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 118,
          child: Timeline.tileBuilder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            theme: TimelineThemeData(
              direction: Axis.horizontal,
              connectorTheme: ConnectorThemeData(space: 30, thickness: 5),
            ),
            builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.before,
              itemCount: points.length,
              itemExtentBuilder: (_, _) => constraints.maxWidth / points.length,
              oppositeContentsBuilder: (context, index) {
                final point = points[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Text(
                    point.time,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: point.status == TimePointStatus.pending
                          ? AppColors.textMuted
                          : AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
              contentsBuilder: (context, index) {
                final point = points[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      point.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorFor(point),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
              indicatorBuilder: (_, index) {
                final point = points[index];
                final color = colorFor(point);
                Widget? child;

                if (point.status == TimePointStatus.current) {
                  child = const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  );
                } else if (point.status == TimePointStatus.complete) {
                  child = const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 15,
                  );
                }

                if (index <= currentIndex) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: const Size(30, 30),
                        painter: _BezierPainter(
                          color: color,
                          drawStart: index > 0,
                          drawEnd: index < currentIndex,
                        ),
                      ),
                      DotIndicator(size: 30, color: color, child: child),
                    ],
                  );
                }

                return Stack(
                  children: [
                    CustomPaint(
                      size: const Size(15, 15),
                      painter: _BezierPainter(
                        color: color,
                        drawEnd: index < points.length - 1,
                      ),
                    ),
                    OutlinedDotIndicator(borderWidth: 4, color: color),
                  ],
                );
              },
              connectorBuilder: (_, index, type) {
                if (index <= 0) return null;

                if (index == currentIndex) {
                  final previousColor = colorForIndex(index - 1);
                  final color = colorForIndex(index);
                  final gradientColors = type == ConnectorType.start
                      ? [Color.lerp(previousColor, color, .5)!, color]
                      : [previousColor, Color.lerp(previousColor, color, .5)!];

                  return DecoratedLineConnector(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                    ),
                  );
                }

                return SolidLineConnector(color: colorForIndex(index));
              },
            ),
          ),
        );
      },
    );
  }
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(radius * cos(angle) + radius, radius * sin(angle) + radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final radius = size.width / 2;

    if (drawStart) {
      const angle = 3 * pi / 4;
      final offset1 = _offset(radius, angle);
      final offset2 = _offset(radius, -angle);
      final path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0, size.height / 2, -radius, radius)
        ..quadraticBezierTo(0, size.height / 2, offset2.dx, offset2.dy)
        ..close();
      canvas.drawPath(path, paint);
    }

    if (drawEnd) {
      const angle = -pi / 4;
      final offset1 = _offset(radius, angle);
      final offset2 = _offset(radius, -angle);
      final path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(
          size.width,
          size.height / 2,
          size.width + radius,
          radius,
        )
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
