import 'package:anacronistta/app/widgets/process_timeline.dart';
import 'package:anacronistta/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('timeline apresenta os estados da jornada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: ProcessTimeline(
            points: [
              TimePoint(
                label: 'Entrada',
                time: '08:00',
                status: TimePointStatus.complete,
              ),
              TimePoint(
                label: 'Pausa',
                time: '--:--',
                status: TimePointStatus.current,
              ),
              TimePoint(
                label: 'Retorno',
                time: '--:--',
                status: TimePointStatus.pending,
              ),
              TimePoint(
                label: 'Saída',
                time: '--:--',
                status: TimePointStatus.pending,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Entrada'), findsOneWidget);
    expect(find.text('Pausa'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
  });
}
