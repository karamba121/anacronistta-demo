import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({this.neumorphicContrast = false, super.key});

  static const double size = 10;
  static const double contrastSize = 24;

  final bool neumorphicContrast;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x662BB3C5), blurRadius: 8, spreadRadius: 3),
        ],
      ),
    );

    if (!neumorphicContrast) return dot;

    return Container(
      width: contrastSize,
      height: contrastSize,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(3, 3),
            blurRadius: 7,
          ),
          BoxShadow(
            color: AppColors.highlight,
            offset: Offset(-3, -3),
            blurRadius: 7,
          ),
        ],
      ),
      child: Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
