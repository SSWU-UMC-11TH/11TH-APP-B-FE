import 'package:flutter/material.dart';

abstract final class AppColors {
  // 기존 기본 색상
  static const violet = Color(0xFF6750A4);
  static const lightViolet = Color(0xFFE8DEF8);
  static const statCardBg = Color(0xFFF3EDF7);
  static const warmWhite = Color(0xFFFAF9F5);
  static const white = Color(0xFFFFFFFF);
  static const primary = Color(0xFF5B4996);
  static const black = Color(0xFF1C1B1F);
  static const gray = Color(0xFF79747E);

  // ⚠️ sign_up_screen.dart에서 요구하는데 누락되었던 색상 변수들 ⚠️
  static const disabledButton = Color(0xFFD3CBDD);
  static const fieldBackground = Color(0xFFF4F2EE);
  static const borderGrey = Color(0xFFDCD8D2);
  static const error = Color(0xFFD32F2F);
  static const errorBackground = Color(0xFFFDE8E8);
}
