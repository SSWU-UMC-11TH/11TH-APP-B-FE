import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 54,
              backgroundImage: AssetImage(
                'assets/images/profile/profile_movielog.jpg',
              ),
            ),
            const SizedBox(height: 16),

            const Text('무비러버', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),

            const Text(
              '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은\n영화들을 보고 기록하는 것을 좋아합니다.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.violet,
                side: const BorderSide(color: AppColors.violet),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text(
                '프로필 수정',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 28),

            const Row(
              children: [
                StatItem(label: '본 영화', value: '342'),
                SizedBox(width: 12),
                StatItem(label: '평점', value: '4.2'),
                SizedBox(width: 12),
                StatItem(label: '즐겨찾기', value: '58'),
              ],
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선호하는 장르', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildGenreChip('드라마'),
                      const SizedBox(width: 8),
                      _buildGenreChip('SF'),
                      const SizedBox(width: 8),
                      _buildGenreChip('애니메이션'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightViolet,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.violet,
        ),
      ),
    );
  }
}
