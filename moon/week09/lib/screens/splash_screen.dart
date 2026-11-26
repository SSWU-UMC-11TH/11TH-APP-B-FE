import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/movielog_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'FLUTTER 8주차',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/logos/movielog_logo.svg',
                          width: 84,
                          height: 84,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '영화의 순간을\n기록하세요',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: onRetry == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [
                          Text(
                            message ?? '로그인 상태를 확인하지 못했어요.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          MovieLogButton(
                            label: '다시 시도',
                            onPressed: onRetry,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
