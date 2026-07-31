import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../config/app_colors.dart';
import '../../data/services/monthly_points_report_service.dart';
import 'connection_indicator.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 20,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'demo@anacronistta.com',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConnectionIndicator(),
              SizedBox(width: 9),
              Text(
                'Conectado',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showMenuDialog(context),
          tooltip: 'Mais opções',
          icon: const Icon(Icons.more_vert_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showMenuDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _ExportDialog(
        reportService: Modular.get<MonthlyPointsReportService>(),
      ),
    );
  }
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.reportService});

  final MonthlyPointsReportService reportService;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  bool _exporting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      icon: const Icon(
        Icons.history_toggle_off_rounded,
        color: AppColors.accent,
        size: 34,
      ),
      title: const Text(
        'Anacronistta',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Acompanhe sua jornada e mantenha seus registros organizados.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'O relatório reúne os pontos e o saldo de horas do mês anterior. '
              'Na Web e no Windows, ele será enviado para Downloads; no Android, '
              'você poderá escolher o destino.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            if (_errorMessage case final message?) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.variant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: _exporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        FilledButton.icon(
          onPressed: _exporting ? null : _export,
          icon: _exporting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_rounded),
          label: Text(_exporting ? 'Gerando...' : 'Exportar pontos'),
        ),
      ],
    );
  }

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _errorMessage = null;
    });

    try {
      final path = await widget.reportService.exportPreviousMonth();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              path == null
                  ? 'Exportação cancelada.'
                  : 'Relatório de pontos salvo com sucesso.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _errorMessage = 'Não foi possível gerar ou salvar o relatório.';
      });
    }
  }
}
