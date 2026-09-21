import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Form 상태 접근을 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

  // 2. 입력 값을 제어할 Controllers (State 내부에 선언)
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 3. 포커스 이동 및 제어를 위한 FocusNodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // 4. 필수 약관 동의 체크박스 상태
  bool _agreedToTerms = false;

  // 5. 메모리 누수 방지를 위한 dispose 처리
  @override
  void dispose() {
    // 모든 Controller 정리
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    // 모든 FocusNode 정리
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(), // 다음 스텝에서 UI 연결
        ),
      ),
    );
  }
}

// 위젯 분리, 헤더 섹션
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          '환영합니다!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
