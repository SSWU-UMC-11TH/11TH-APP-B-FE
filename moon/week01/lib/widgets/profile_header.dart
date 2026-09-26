import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 0.7,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile/profile_movielog.jpg',
              width: 130,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          '무비러버',
          style: AppTextStyles.title,
        ),

        const SizedBox(height: 6),

        Text(
          '스릴러를 좋아해요.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
          )
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () {
            debugPrint('프로필 수정 버튼 클릭');
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 29,
              vertical: 11,
            ),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('프로필 수정'
          , style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
          ),
        ),
      ],
    );
  }
}