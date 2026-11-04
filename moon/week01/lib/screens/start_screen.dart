import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: Column(
            children: [
              // 상단 주차 표시
              const Text(
                'FLUTTER 1주차',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // MovieLog 로고
              SvgPicture.asset(
  'assets/icons/movie.svg',
  width: 64,
  height: 64,
  colorFilter: const ColorFilter.mode(
    AppColors.primary,
    BlendMode.srcIn,
  ),
),

              const SizedBox(height: 40),

              // 메인 문구
              Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  fontSize: 26,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              // 설명
              const Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),

              const Spacer(flex: 5),

              // 시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 1주차에서는 화면 이동 기능을 구현하지 않음
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}