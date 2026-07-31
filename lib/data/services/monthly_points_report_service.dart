import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../local/app_database.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/time_entry_repository.dart';
import 'report_file_saver.dart';

class ReportPoint {
  const ReportPoint({required this.label, required this.occurredAt});

  final String label;
  final DateTime occurredAt;
}

class ReportDay {
  const ReportDay({
    required this.date,
    required this.points,
    required this.workedMinutes,
    required this.expectedMinutes,
    required this.isComplete,
  });

  final DateTime date;
  final List<ReportPoint> points;
  final int workedMinutes;
  final int expectedMinutes;
  final bool isComplete;

  int get balanceMinutes => workedMinutes - expectedMinutes;
}

class MonthlyPointsReport {
  const MonthlyPointsReport({
    required this.start,
    required this.endExclusive,
    required this.days,
  });

  final DateTime start;
  final DateTime endExclusive;
  final List<ReportDay> days;

  int get workedMinutes =>
      days.fold(0, (total, day) => total + day.workedMinutes);

  int get expectedMinutes =>
      days.fold(0, (total, day) => total + day.expectedMinutes);

  int get balanceMinutes => workedMinutes - expectedMinutes;

  int get pointCount => days.fold(0, (total, day) => total + day.points.length);

  int get expectedDayCount =>
      days.where((day) => day.expectedMinutes > 0).length;
}

class MonthlyPointsReportService {
  MonthlyPointsReportService(
    this._timeEntryRepository,
    this._scheduleRepository,
  );

  final TimeEntryRepository _timeEntryRepository;
  final ScheduleRepository _scheduleRepository;

  Future<MonthlyPointsReport> loadPreviousMonth({
    DateTime? referenceDate,
  }) async {
    final reference = referenceDate ?? DateTime.now();
    final end = DateTime(reference.year, reference.month);
    final start = DateTime(end.year, end.month - 1);
    final results = await Future.wait([
      _timeEntryRepository.getBetween(start, end),
      _scheduleRepository.getAll(),
    ]);
    final entries = results[0] as List<TimeEntryRow>;
    final schedules = results[1] as List<DaySchedule>;

    return MonthlyPointsReport(
      start: start,
      endExclusive: end,
      days: [
        for (
          var date = start;
          date.isBefore(end);
          date = date.add(const Duration(days: 1))
        )
          if (_shouldIncludeDay(date, entries, schedules))
            _buildDay(date, entries, schedules),
      ],
    );
  }

  Future<Uint8List> buildPreviousMonthPdf({DateTime? referenceDate}) async {
    final report = await loadPreviousMonth(referenceDate: referenceDate);
    return buildPdf(report);
  }

  Future<String?> exportPreviousMonth({DateTime? referenceDate}) async {
    final report = await loadPreviousMonth(referenceDate: referenceDate);
    final bytes = await buildPdf(report);
    final fileName =
        'relatorio_pontos_${report.start.year}-'
        '${report.start.month.toString().padLeft(2, '0')}';

    return savePdfFile(fileName, bytes);
  }

  Future<Uint8List> buildPdf(MonthlyPointsReport report) async {
    final fontData = await rootBundle.load('assets/fonts/Raleway.ttf');
    final regularFont = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(fontData);
    final document = pw.Document(
      title: 'Relatório mensal de pontos',
      author: 'Anacronistta',
      subject: _monthLabel(report.start),
    );
    final theme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 38),
          theme: theme,
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _background),
          ),
        ),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox(height: 30)
            : _buildHeader(report),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildHeader(report),
          pw.SizedBox(height: 14),
          _buildTitle(report),
          pw.SizedBox(height: 18),
          _buildSummary(report),
          pw.SizedBox(height: 22),
          pw.Text(
            'Detalhamento das jornadas',
            style: pw.TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'A jornada prevista considera a configuração atual do aplicativo.',
            style: const pw.TextStyle(color: _textMuted, fontSize: 8.5),
          ),
          pw.SizedBox(height: 12),
          if (report.days.isEmpty)
            _buildEmptyState()
          else
            for (var index = 0; index < report.days.length; index++) ...[
              if (index == 5 || index == 13) pw.NewPage(),
              _buildDayCard(report.days[index]),
              pw.SizedBox(height: 9),
            ],
        ],
      ),
    );

    return document.save();
  }

  bool _shouldIncludeDay(
    DateTime date,
    List<TimeEntryRow> entries,
    List<DaySchedule> schedules,
  ) {
    final schedule = _scheduleFor(date.weekday, schedules);
    return (schedule?.totalMinutes ?? 0) > 0 ||
        entries.any((entry) => _isSameDay(entry.occurredAt, date));
  }

  ReportDay _buildDay(
    DateTime date,
    List<TimeEntryRow> allEntries,
    List<DaySchedule> schedules,
  ) {
    final schedule = _scheduleFor(date.weekday, schedules);
    final entries =
        allEntries.where((entry) => _isSameDay(entry.occurredAt, date)).toList()
          ..sort(
            (first, second) => first.occurredAt.compareTo(second.occurredAt),
          );
    final shiftCount = _shiftCount(schedule, entries);
    final calculation = _calculateWorked(entries, shiftCount);

    return ReportDay(
      date: date,
      points: [
        for (final entry in entries)
          ReportPoint(
            label: _pointLabel(entry.type, shiftCount),
            occurredAt: entry.occurredAt,
          ),
      ],
      workedMinutes: calculation.$1,
      expectedMinutes: schedule?.totalMinutes ?? 0,
      isComplete: calculation.$2,
    );
  }

  (int, bool) _calculateWorked(List<TimeEntryRow> entries, int shiftCount) {
    var worked = Duration.zero;
    var complete = shiftCount > 0;

    for (var index = 0; index < shiftCount; index++) {
      final start = _findEntry(entries, 'shift_${index}_start', [
        if (index == 0) 'entry',
        if (index == 1) 'break_end',
      ]);
      final end = _findEntry(entries, 'shift_${index}_end', [
        if (index == 0 && shiftCount > 1) 'break_start',
        if (index == shiftCount - 1) 'exit',
      ]);

      if (start == null || end == null) {
        complete = false;
        continue;
      }
      if (end.occurredAt.isAfter(start.occurredAt)) {
        worked += end.occurredAt.difference(start.occurredAt);
      } else {
        complete = false;
      }
    }

    return (worked.inMinutes, complete);
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

  int _shiftCount(DaySchedule? schedule, List<TimeEntryRow> entries) {
    var count = schedule?.shifts.length ?? 0;
    for (final entry in entries) {
      final match = RegExp(
        r'^shift_(\d+)_(?:start|end)$',
      ).firstMatch(entry.type);
      if (match != null) {
        final entryCount = int.parse(match.group(1)!) + 1;
        if (entryCount > count) count = entryCount;
      }
    }
    if (entries.any(
      (entry) => const {
        'entry',
        'break_start',
        'break_end',
        'exit',
      }.contains(entry.type),
    )) {
      if (count < 2) count = 2;
    }
    return count;
  }

  DaySchedule? _scheduleFor(int weekday, List<DaySchedule> schedules) {
    for (final schedule in schedules) {
      if (schedule.weekday == weekday) return schedule;
    }
    return null;
  }

  String _pointLabel(String type, int shiftCount) {
    return switch (type) {
      'entry' || 'shift_0_start' => 'Entrada',
      'break_start' => 'Pausa',
      'break_end' => 'Retorno',
      'exit' => 'Saída',
      _ => _dynamicPointLabel(type, shiftCount),
    };
  }

  String _dynamicPointLabel(String type, int shiftCount) {
    final match = RegExp(r'^shift_(\d+)_(start|end)$').firstMatch(type);
    if (match == null) return 'Ponto';
    final index = int.parse(match.group(1)!);
    final isStart = match.group(2) == 'start';
    if (isStart) {
      if (index == 0) return 'Entrada';
      return index == 1 ? 'Retorno' : 'Retorno ${index + 1}';
    }
    if (index == shiftCount - 1) return 'Saída';
    return index == 0 ? 'Pausa' : 'Pausa ${index + 1}';
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

pw.Widget _buildHeader(MonthlyPointsReport report) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Row(
        children: [
          pw.Container(
            width: 30,
            height: 30,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
              color: _accent,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Text(
              'A',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 9),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ANACRONISTTA',
                style: pw.TextStyle(
                  color: _text,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              pw.Text(
                'Relatório de jornada',
                style: const pw.TextStyle(color: _textMuted, fontSize: 7.5),
              ),
            ],
          ),
        ],
      ),
      pw.Text(
        _monthLabel(report.start).toUpperCase(),
        style: pw.TextStyle(
          color: _accent,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    ],
  );
}

pw.Widget _buildTitle(MonthlyPointsReport report) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Relatório mensal de pontos',
        style: pw.TextStyle(
          color: _text,
          fontSize: 23,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        'demo@anacronistta.com  |  ${_monthLabel(report.start)}',
        style: const pw.TextStyle(color: _textMuted, fontSize: 9.5),
      ),
    ],
  );
}

pw.Widget _buildSummary(MonthlyPointsReport report) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: _summaryCard(
          'Trabalhadas',
          _formatDuration(report.workedMinutes),
          _accent,
        ),
      ),
      pw.SizedBox(width: 9),
      pw.Expanded(
        child: _summaryCard(
          'Previstas',
          _formatDuration(report.expectedMinutes),
          _text,
        ),
      ),
      pw.SizedBox(width: 9),
      pw.Expanded(
        child: _summaryCard(
          'Saldo',
          _formatBalance(report.balanceMinutes),
          report.balanceMinutes >= 0 ? _accent : _variant,
        ),
      ),
      pw.SizedBox(width: 9),
      pw.Expanded(child: _summaryCard('Pontos', '${report.pointCount}', _text)),
    ],
  );
}

pw.Widget _summaryCard(String label, String value, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(10),
      boxShadow: const [
        pw.BoxShadow(
          color: PdfColor.fromInt(0x1FD1D9E6),
          offset: PdfPoint(3, -3),
          blurRadius: 7,
        ),
      ],
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          label,
          style: const pw.TextStyle(color: _textMuted, fontSize: 7.5),
        ),
      ],
    ),
  );
}

pw.Widget _buildDayCard(ReportDay day) {
  final status = _statusFor(day);
  final statusColor = _statusColor(day);

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(9),
      border: pw.Border.all(color: _accent, width: .7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${_weekdayLabel(day.date.weekday)}, ${_formatDate(day.date)}',
                  style: pw.TextStyle(
                    color: _text,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Previstas ${_formatDuration(day.expectedMinutes)}  |  '
                  'Trabalhadas ${_formatDuration(day.workedMinutes)}  |  '
                  'Saldo ${_formatBalance(day.balanceMinutes)}',
                  style: const pw.TextStyle(color: _textMuted, fontSize: 7.5),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: statusColor.shade(.12),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                status,
                style: pw.TextStyle(
                  color: statusColor,
                  fontSize: 6.8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        if (day.points.isEmpty)
          pw.Text(
            'Nenhum ponto registrado.',
            style: const pw.TextStyle(color: _variant, fontSize: 8),
          )
        else
          pw.Wrap(
            spacing: 6,
            runSpacing: 5,
            children: [
              for (final point in day.points)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _background,
                    borderRadius: pw.BorderRadius.circular(9),
                  ),
                  child: pw.Text(
                    '${point.label} ${_formatTime(point.occurredAt)}',
                    style: const pw.TextStyle(color: _text, fontSize: 7.5),
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}

pw.Widget _buildEmptyState() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Text(
      'Nenhuma jornada prevista ou ponto registrado no período.',
      style: const pw.TextStyle(color: _textMuted, fontSize: 9),
    ),
  );
}

pw.Widget _buildFooter(pw.Context context) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'Gerado pelo Anacronistta',
        style: const pw.TextStyle(color: _textMuted, fontSize: 7),
      ),
      pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: const pw.TextStyle(color: _textMuted, fontSize: 7),
      ),
    ],
  );
}

String _statusFor(ReportDay day) {
  if (day.expectedMinutes == 0) return 'Jornada extraordinária';
  if (day.points.isEmpty) return 'Sem registros';
  if (!day.isComplete) return 'Jornada incompleta';
  if (day.balanceMinutes >= 0) return 'Meta cumprida';
  return 'Saldo negativo';
}

PdfColor _statusColor(ReportDay day) {
  if (day.expectedMinutes == 0 || day.balanceMinutes >= 0) return _accent;
  return _variant;
}

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return '${hours}h${remainder.toString().padLeft(2, '0')}';
}

String _formatBalance(int minutes) {
  return '${minutes >= 0 ? '+' : '-'}${_formatDuration(minutes.abs())}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _monthLabel(DateTime date) {
  final month = const [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ][date.month - 1];
  return '$month de ${date.year}';
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

const _background = PdfColor.fromInt(0xFFECF0F3);
const _text = PdfColor.fromInt(0xFF303E57);
const _textMuted = PdfColor.fromInt(0xFF758096);
const _accent = PdfColor.fromInt(0xFF2BB3C5);
const _variant = PdfColor.fromInt(0xFFFF5182);
