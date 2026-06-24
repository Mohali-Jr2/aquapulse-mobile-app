import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepBlue, AppColors.blue, AppColors.sky],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(.25),
            blurRadius: 28,
            offset: const Offset(0, 16),
          )
        ],
      ),
      child: child,
    );
  }
}
