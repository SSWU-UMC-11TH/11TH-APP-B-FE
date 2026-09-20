import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 82, 80, 84),
  );

  static const statValue = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );
}