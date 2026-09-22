import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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

  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  bool get _isNicknameValid =>
      _nicknameController.text.trim().length >= 2;

  bool get _isEmailValid {
    final email = _emailController.text.trim();

    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  bool get _isPasswordValid =>
      _passwordController.text.length >= 8;

  bool get _canSubmit =>
      _isNicknameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _agreedToTerms;

  void _submit() {
    final isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid || !_agreedToTerms) {
      return;
    }

    FocusScope.of(context).unfocus();

    debugPrint('회원가입 입력 완료');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        const _SignUpHeader(),

                        const SizedBox(height: 36),

                        _SignUpTextField(
                          label: '닉네임',
                          hintText: '닉네임을 입력해주세요',
                          controller: _nicknameController,
                          focusNode: _nicknameFocusNode,
                          isValid: _isNicknameValid,
                          textInputAction:
                              TextInputAction.next,
                          validator: (value) {
                            final nickname =
                                value?.trim() ?? '';

                            if (nickname.isEmpty) {
                              return '닉네임을 입력해주세요.';
                            }

                            if (nickname.length < 2) {
                              return '닉네임은 2자 이상이어야 합니다.';
                            }

                            return null;
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            _emailFocusNode.requestFocus();
                          },
                        ),

                        const SizedBox(height: 14),

                        _SignUpTextField(
                          label: '이메일',
                          hintText: '이메일 주소를 입력해주세요',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          isValid: _isEmailValid,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return '이메일을 입력해주세요.';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                              return '올바른 이메일 형식이 아닙니다.';
                            }

                            return null;
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),

                        const SizedBox(height: 14),

                        _SignUpTextField(
                          label: '비밀번호',
                          hintText: '비밀번호를 입력해주세요',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          isValid: _isPasswordValid,
                          obscureText: true,
                          textInputAction:
                              TextInputAction.done,
                          validator: (value) {
                            final password = value ?? '';

                            if (password.isEmpty) {
                              return '비밀번호를 입력해주세요.';
                            }

                            if (password.length < 8) {
                              return '비밀번호는 8자 이상이어야 합니다.';
                            }

                            return null;
                          },
                          onChanged: (_) {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                        ),

                        const Spacer(),

                        const SizedBox(height: 32),

                        _TermsAgreement(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _SignUpButton(
                          enabled: _canSubmit,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 28),

                        const _LoginGuide(),

                        const SizedBox(height: 28),
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

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          '환영합니다!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SignUpTextField extends StatelessWidget {
  const _SignUpTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.isValid,
    required this.validator,
    required this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
  });

  final String label;
  final String hintText;

  final TextEditingController controller;
  final FocusNode focusNode;

  final bool isValid;
  final bool obscureText;

  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  bool get _hasInput =>
      controller.text.trim().isNotEmpty;

  bool get _hasError =>
      _hasInput && !isValid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autovalidateMode:
              AutovalidateMode.onUserInteraction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),

            filled: true,

            fillColor: _hasError
                ? AppColors.errorBackground
                : AppColors.fieldBackground,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),

            suffixIcon: !_hasInput
                ? null
                : Icon(
                    isValid
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: isValid
                        ? AppColors.primary
                        : AppColors.error,
                    size: 27,
                  ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError
                    ? AppColors.error
                    : AppColors.fieldBorder,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError
                    ? AppColors.error
                    : AppColors.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),

            focusedErrorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),

            errorStyle: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsAgreement extends StatelessWidget {
  const _TermsAgreement({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Transform.scale(
            scale: 1.35,
            child: Checkbox(
              value: value,
              activeColor: AppColors.primary,
              checkColor: AppColors.white,
              side: const BorderSide(
                color: AppColors.fieldBorder,
              ),
              onChanged: (newValue) {
                onChanged(newValue ?? false);
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          '필수 약관에 동의합니다',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed:
            enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          disabledBackgroundColor:
              AppColors.disabledButton,
          foregroundColor:
              AppColors.white,
          disabledForegroundColor:
              AppColors.white.withValues(
            alpha: 0.8,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          '가입하기',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LoginGuide extends StatelessWidget {
  const _LoginGuide();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있나요? ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        TextButton(
          onPressed: () {
            debugPrint('로그인 선택');
          },
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '로그인',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}