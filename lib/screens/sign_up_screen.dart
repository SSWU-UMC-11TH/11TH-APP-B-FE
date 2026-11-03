import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Figma W2 회원가입 화면 기준 값
const _bg = Color(0xFFFAF9F5);
const _violet = Color(0xFF6750A4);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);
const _border = Color(0xFFCBC4D2);
const _fieldFill = Color(0xFFF5F3EF);
const _errorColor = Color(0xFFB3261E);
const _errorFill = Color(0xFFFFDAD6);
const _disabledButton = Color(0xFFCCC2DC);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreed = false;

  // 한 글자라도 입력한 뒤부터 에러/체크 상태를 보여준다
  bool _nicknameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  static final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool get _nicknameValid => _nicknameController.text.trim().length >= 2;
  bool get _emailValid => _emailRegExp.hasMatch(_emailController.text.trim());
  bool get _passwordValid => _passwordController.text.length >= 8;

  bool get _canSubmit =>
      _nicknameValid && _emailValid && _passwordValid && _agreed;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 24 / 16,
                                fontWeight: FontWeight.w500,
                                color: _textSub,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _LabeledField(
                            label: '닉네임',
                            controller: _nicknameController,
                            touched: _nicknameTouched,
                            valid: _nicknameValid,
                            errorText: '닉네임은 2자 이상이어야 합니다.',
                            onChanged: (_) => setState(() {
                              _nicknameTouched = true;
                            }),
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: '이메일',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            touched: _emailTouched,
                            valid: _emailValid,
                            errorText: '올바른 이메일 형식이 아닙니다.',
                            onChanged: (_) => setState(() {
                              _emailTouched = true;
                            }),
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: '비밀번호',
                            controller: _passwordController,
                            obscureText: true,
                            touched: _passwordTouched,
                            valid: _passwordValid,
                            errorText: '비밀번호는 8자 이상이어야 합니다.',
                            onChanged: (_) => setState(() {
                              _passwordTouched = true;
                            }),
                          ),
                          const Spacer(),
                          const SizedBox(height: 32),
                          _TermsCheckbox(
                            checked: _agreed,
                            onChanged: (v) => setState(() => _agreed = v),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _canSubmit ? _submit : null,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _violet,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _disabledButton,
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('가입하기'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _LoginRow(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: _textMain),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/start');
                }
              },
            ),
          ),
          const Text(
            '회원가입',
            style: TextStyle(
              fontSize: 22,
              height: 28 / 22,
              fontWeight: FontWeight.w500,
              color: _violet,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.touched,
    required this.valid,
    required this.errorText,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final bool touched;
  final bool valid;
  final String errorText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final showError = touched && !valid;
    final showCheck = touched && valid;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 1),
    );

    final borderColor = showError ? _errorColor : _border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            color: _textMain,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF211F26),
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: showError ? _errorFill : _fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            enabledBorder: border(borderColor),
            focusedBorder: border(showError ? _errorColor : _violet),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 20,
            ),
            suffixIcon: showError
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.error_outline,
                      size: 20,
                      color: _errorColor,
                    ),
                  )
                : showCheck
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.check_circle, size: 20, color: _violet),
                  )
                : null,
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: _errorColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!checked),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: checked ? _violet : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: checked ? _violet : _border),
            ),
            child: checked
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          const Text(
            '필수 약관에 동의합니다',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRow extends StatelessWidget {
  const _LoginRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있나요? ',
          style: TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            color: _textSub,
          ),
        ),
        GestureDetector(
          // 로그인 화면이 아직 없어서 일단 시작 화면으로 보냄
          onTap: () => context.go('/start'),
          child: const Text(
            '로그인',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: _violet,
            ),
          ),
        ),
      ],
    );
  }
}
