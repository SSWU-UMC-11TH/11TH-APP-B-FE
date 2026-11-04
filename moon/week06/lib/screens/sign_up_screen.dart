import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';

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

  bool get _isNicknameValid => _nicknameController.text.trim().length >= 2;

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  bool get _isEmailValid => _isValidEmail(_emailController.text);

  bool get _isPasswordValid => _passwordController.text.length >= 8;

  bool _canSubmit(SignUpViewModel viewModel) {
    return _isNicknameValid &&
        _isEmailValid &&
        _isPasswordValid &&
        _agreedToTerms &&
        viewModel.nicknameCheckStatus == CheckStatus.available &&
        viewModel.emailCheckStatus == CheckStatus.available;
  }

  void _submit() {
    final viewModel = context.read<SignUpViewModel>();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || !_canSubmit(viewModel)) {
      return;
    }

    FocusScope.of(context).unfocus();

    // 6주차 v5에는 회원가입 POST API가 없음
    // 학습용 화면 이동만 수행
    context.go('/home');
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
    final viewModel = context.watch<SignUpViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const _SignUpHeader(),
                        const SizedBox(height: 36),

                        // 닉네임 + 중복 확인 버튼
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _SignUpTextField(
                                label: '닉네임',
                                hintText: '닉네임을 입력해주세요',
                                controller: _nicknameController,
                                focusNode: _nicknameFocusNode,
                                isValid: _isNicknameValid,
                                errorText: viewModel.nicknameErrorText,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final nickname = value?.trim() ?? '';

                                  if (nickname.isEmpty) {
                                    return '닉네임을 입력해주세요.';
                                  }

                                  if (nickname.length < 2) {
                                    return '닉네임은 2자 이상이어야 합니다.';
                                  }

                                  return null;
                                },
                                onChanged: (value) {
                                  viewModel.onNicknameChanged(value);
                                  setState(() {});
                                },
                                onFieldSubmitted: (_) {
                                  _emailFocusNode.requestFocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: MovieLogButton(
                                label: '중복 확인',
                                isLoading:
                                    viewModel.nicknameCheckStatus ==
                                    CheckStatus.checking,
                                onPressed:
                                    _isNicknameValid &&
                                        viewModel.canCheckNickname
                                    ? () => viewModel.checkNickname(
                                        _nicknameController.text,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        if (viewModel.nicknameCheckStatus ==
                            CheckStatus.available)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '사용 가능한 닉네임입니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),

                        // 이메일 + 중복 확인 버튼
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _SignUpTextField(
                                label: '이메일',
                                hintText: '이메일 주소를 입력해주세요',
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                isValid: _isEmailValid,
                                errorText: viewModel.emailErrorText,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final email = value?.trim() ?? '';

                                  if (email.isEmpty) {
                                    return '이메일을 입력해주세요.';
                                  }

                                  if (!_isValidEmail(email)) {
                                    return '올바른 이메일 형식이 아닙니다.';
                                  }

                                  return null;
                                },
                                onChanged: (value) {
                                  viewModel.onEmailChanged(value);
                                  setState(() {});
                                },
                                onFieldSubmitted: (_) {
                                  _passwordFocusNode.requestFocus();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 28),
                              child: MovieLogButton(
                                label: '중복 확인',
                                isLoading:
                                    viewModel.emailCheckStatus ==
                                    CheckStatus.checking,
                                onPressed:
                                    _isEmailValid && viewModel.canCheckEmail
                                    ? () => viewModel.checkEmail(
                                        _emailController.text,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        if (viewModel.emailCheckStatus == CheckStatus.checking)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '이메일 사용 가능 여부를 확인 중입니다.',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        if (viewModel.emailCheckStatus == CheckStatus.available)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '사용할 수 있는 이메일입니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),

                        // 비밀번호
                        _SignUpTextField(
                          label: '비밀번호',
                          hintText: '비밀번호를 입력해주세요',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          isValid: _isPasswordValid,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
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

                        // 약관 동의
                        _TermsAgreement(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // 공용 가입하기 버튼
                        MovieLogButton(
                          label: '가입하기',
                          width: double.infinity,
                          onPressed: _canSubmit(viewModel) ? _submit : null,
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

// 회원가입 상단 안내
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
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 1),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// 공통 회원가입 입력창
class _SignUpTextField extends StatelessWidget {
  const _SignUpTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.isValid,
    required this.validator,
    required this.onChanged,
    this.errorText,
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

  final String? errorText;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  bool get _hasInput => controller.text.trim().isNotEmpty;

  bool get _hasError => errorText != null || (_hasInput && !isValid);

  bool get _showValidIcon => _hasInput && isValid && errorText == null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            filled: true,
            fillColor: _hasError
                ? AppColors.errorBackground
                : AppColors.fieldBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),

            suffixIcon: !_hasInput
                ? null
                : Icon(
                    _showValidIcon ? Icons.check_circle : Icons.error_outline,
                    color: _showValidIcon ? AppColors.primary : AppColors.error,
                    size: 27,
                  ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : AppColors.fieldBorder,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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

// 필수 약관 동의
class _TermsAgreement extends StatelessWidget {
  const _TermsAgreement({required this.value, required this.onChanged});

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
              side: const BorderSide(color: AppColors.fieldBorder),
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

// 하단 로그인 안내
class _LoginGuide extends StatelessWidget {
  const _LoginGuide();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
