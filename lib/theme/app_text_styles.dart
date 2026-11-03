import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // 상단 네비게이션 '회원가입' 전용 보라색 스타일
  static const appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.violet,
  );

  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  // 입력 필드 상단 라벨 (닉네임, 이메일, 비밀번호)
  static const labelMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.violet,
  );

  static const statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.4,
  );

  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );
}
