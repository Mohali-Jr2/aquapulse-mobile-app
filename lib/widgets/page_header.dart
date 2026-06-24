import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.dark)),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.notifications_active_rounded),
        ),
      ],
    );
  }
}
