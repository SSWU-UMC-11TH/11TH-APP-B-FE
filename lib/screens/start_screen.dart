import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

const _bg = Color(0xFFFAF9F5);
const _violet = Color(0xFF6750A4);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(flex: 3),
              SvgPicture.asset('assets/images/logo.svg', width: 96, height: 96),
              const SizedBox(height: 24),
              const Text(
                'MovieLog',
                style: TextStyle(
                  fontSize: 32,
                  height: 40 / 32,
                  fontWeight: FontWeight.w500,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '나만의 영화 기록을 관리해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: _textSub,
                ),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
