import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthViewModel>().member;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          Text(
            member?.nickname ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 6),
          Text(
            member?.email ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: member == null
                ? null
                : () => context.push('/mypage/profile/edit'),
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
