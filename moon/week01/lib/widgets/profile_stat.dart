import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileStat extends StatelessWidget {
  const ProfileStat({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.statBackground,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.statValue,
          ),
        ],
      ),
    );
  }
}
