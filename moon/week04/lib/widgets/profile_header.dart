import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 이미지
          Container(
            width: 110,
            height: 110,
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile/profile_movielog.jpg',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 닉네임
          const Text(
            '무비러버',
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 6),

          // 소개
          Text(
            '스릴러를 좋아해요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          // 프로필 수정 버튼
          OutlinedButton(
            onPressed: () {
              debugPrint('프로필 수정 버튼 클릭');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 11,
              ),
              side: const BorderSide(
                color: AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '프로필 수정',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}