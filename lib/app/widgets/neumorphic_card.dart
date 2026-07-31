import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(9, 9),
            blurRadius: 20,
          ),
          BoxShadow(
            color: AppColors.highlight,
            offset: Offset(-9, -9),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
