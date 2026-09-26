import 'package:flutter/material.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 프로필 통계 데이터
  static const stats = [
    {'label': '본 영화', 'value': '342'},
    {'label': '평점', 'value': '4.2'},
    {'label': '즐겨찾기', 'value': '58'},
  ];

  // 선호 장르
  static const genres = [
    '스릴러',
    '공포',
    '코미디',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내 프로필',
        
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진, 닉네임, 소개, 프로필 수정 버튼
              const Center(
                child: ProfileHeader(),
              ),

              const SizedBox(height: 24),

              // 통계 영역
              Row(
                children: [
                  for (int i = 0; i < stats.length; i++) ...[
                    Expanded(
                      child: ProfileStat(
                        label: stats[i]['label']!,
                        value: stats[i]['value']!,
                      ),
                    ),

                    if (i != stats.length - 1)
                      const SizedBox(width: 8),
                  ],
                ],
              ),

              const SizedBox(height: 28),

              // 선호 장르 제목
              Text(
                '선호하는 장르',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 12),

              // 선호 장르 Chip
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres
                    .map(
                      (genre) => Chip(
                        label: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 13,
                             fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        backgroundColor: AppColors.lightviolet,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}