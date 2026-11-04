import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/profile_header.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 내 프로필
              const Text(
                '내 프로필',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 36),

              // 기존 프로필 위젯 재사용
              const ProfileHeader(),

              const SizedBox(height: 28),

              // 통계
              const Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: '본 영화',
                      value: '342',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: '평점',
                      value: '4.2',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: '즐겨찾기',
                      value: '58',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 선호하는 장르
              const Text(
                '선호하는 장르',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 14),

              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GenreChip(label: '드라마'),
                  _GenreChip(label: 'SF'),
                  _GenreChip(label: '애니메이션'),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================
// 통계 카드
// ================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.statBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightviolet,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================
// 장르 Chip
// ================================

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightviolet,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}