import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isNicknameValid(String val) => val.trim().length >= 2;
  bool _isEmailValid(String val) {
    final email = val.trim();
    return email.contains('@') &&
        email.contains('.') &&
        email.indexOf('@') < email.lastIndexOf('.');
  }

  bool _isPasswordValid(String val) => val.length >= 8;

  bool get _canSubmit {
    return _isNicknameValid(_nicknameController.text) &&
        _isEmailValid(_emailController.text) &&
        _isPasswordValid(_passwordController.text) &&
        _agreedToTerms;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('회원가입이 완료되었습니다!'),
        backgroundColor: AppColors.violet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxFormWidth = constraints.maxWidth >= 700
                ? 560.0
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction, // 실시간 유효성 검사
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TopNavigationHeaderWidget(),
                        const SizedBox(height: 32),

                        const SignUpHeaderWidget(),
                        const SizedBox(height: 32),

                        SignUpFormFieldsWidget(
                          nicknameController: _nicknameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          isNicknameValid: _isNicknameValid,
                          isEmailValid: _isEmailValid,
                          isPasswordValid: _isPasswordValid,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 28),

                        TermsCheckboxWidget(
                          value: _agreedToTerms,
                          onChanged: (val) =>
                              setState(() => _agreedToTerms = val ?? false),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _canSubmit ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.violet,
                              disabledBackgroundColor: AppColors.disabledButton,
                              foregroundColor: AppColors.white,
                              disabledForegroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '가입하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '이미 계정이 있나요? ',
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                '로그인',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.violet,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//상단헤더
class TopNavigationHeaderWidget extends StatelessWidget {
  const TopNavigationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const Text('회원가입', style: AppTextStyles.appBarTitle),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

//서브 안내 문구
class SignUpHeaderWidget extends StatelessWidget {
  const SignUpHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          '환영합니다!',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

//에러 완료 아이콘
class SignUpFormFieldsWidget extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  final bool Function(String) isNicknameValid;
  final bool Function(String) isEmailValid;
  final bool Function(String) isPasswordValid;

  final VoidCallback onChanged;

  const SignUpFormFieldsWidget({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isNicknameValid,
    required this.isEmailValid,
    required this.isPasswordValid,
    required this.onChanged,
  });

  InputDecoration _buildInputDecoration({
    required String hintText,
    required bool hasText,
    required bool isValid,
    required bool isError,
  }) {
    Widget? suffix;
    if (hasText) {
      if (isError) {
        // 에러 시 빨간 느낌표 아이콘
        suffix = const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(Icons.error_outline, color: AppColors.error, size: 22),
        );
      } else if (isValid) {
        // 성공 시 보라색 체크 아이콘
        suffix = const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(Icons.check_circle, color: AppColors.violet, size: 22),
        );
      }
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodySmall,
      filled: true,
      fillColor: isError
          ? AppColors.errorBackground
          : AppColors.fieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isError ? AppColors.error : AppColors.borderGrey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isError ? AppColors.error : AppColors.violet,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: AppTextStyles.labelMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nicknameText = nicknameController.text;
    final hasNicknameText = nicknameText.isNotEmpty;
    final nicknameValid = isNicknameValid(nicknameText);
    final nicknameError = hasNicknameText && !nicknameValid;

    final emailText = emailController.text;
    final hasEmailText = emailText.isNotEmpty;
    final emailValid = isEmailValid(emailText);
    final emailError = hasEmailText && !emailValid;

    final passwordText = passwordController.text;
    final hasPasswordText = passwordText.isNotEmpty;
    final passwordValid = isPasswordValid(passwordText);
    final passwordError = hasPasswordText && !passwordValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 닉네임
        _buildLabel('닉네임'),
        TextFormField(
          controller: nicknameController,
          style: AppTextStyles.bodyMedium,
          decoration: _buildInputDecoration(
            hintText: '닉네임을 입력해주세요',
            hasText: hasNicknameText,
            isValid: nicknameValid,
            isError: nicknameError,
          ),
          textInputAction: TextInputAction.next,
          validator: (v) {
            final val = v?.trim() ?? '';
            if (val.isNotEmpty && val.length < 2) {
              return '닉네임은 2자 이상이어야 합니다.';
            }
            return null;
          },
          onChanged: (_) => onChanged(),
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(emailFocusNode),
        ),
        const SizedBox(height: 20),

        // 이메일
        _buildLabel('이메일'),
        TextFormField(
          controller: emailController,
          focusNode: emailFocusNode,
          style: AppTextStyles.bodyMedium,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            hintText: '이메일 주소를 입력해주세요',
            hasText: hasEmailText,
            isValid: emailValid,
            isError: emailError,
          ),
          textInputAction: TextInputAction.next,
          validator: (v) {
            final val = v?.trim() ?? '';
            if (val.isNotEmpty && !isEmailValid(val)) {
              return '올바른 이메일 형식이 아닙니다.';
            }
            return null;
          },
          onChanged: (_) => onChanged(),
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passwordFocusNode),
        ),
        const SizedBox(height: 20),

        // 비밀번호
        _buildLabel('비밀번호'),
        TextFormField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          style: AppTextStyles.bodyMedium,
          obscureText: true,
          decoration: _buildInputDecoration(
            hintText: '비밀번호를 입력해주세요',
            hasText: hasPasswordText,
            isValid: passwordValid,
            isError: passwordError,
          ),
          textInputAction: TextInputAction.done,
          validator: (v) {
            final val = v ?? '';
            if (val.isNotEmpty && val.length < 8) {
              return '비밀번호는 8자 이상이어야 합니다.';
            }
            return null;
          },
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

//약관동의
class TermsCheckboxWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.violet : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? AppColors.violet : AppColors.gray,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('필수 약관에 동의합니다', style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
