import 'package:flutter/material.dart';
import 'package:flutter_application_1/view_models/sign_up_view_model.dart';
import 'package:flutter_application_1/widgets/movielog_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  bool get _canSubmit {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return _nicknameController.text.trim().length >= 2 &&
        emailRegex.hasMatch(_emailController.text.trim()) &&
        _passwordController.text.length >= 8 &&
        _agreedToTerms;
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_agreedToTerms) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입이 완료되었습니다!')),
    );

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Color(0xFF6B4EFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeaderSection(),
                const SizedBox(height: 32),
                _FormInputFields(
                  nicknameController: _nicknameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocusNode: _emailFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                  onChanged: () => setState(() {}),
                  onSubmit: _submitForm,
                ),
                const SizedBox(height: 24),
                _TermsAndSubmitSection(
                  agreedToTerms: _agreedToTerms,
                  onTermsChanged: (value) =>
                      setState(() => _agreedToTerms = value ?? false),
                  canSubmit: _canSubmit,
                  onSubmit: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 위젯 1번 헤더
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          '환영합니다!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

// 사용 가능 문구
class _SuccessText extends StatelessWidget {
  const _SuccessText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E7D32),
      ),
    );
  }
}

// 통 커스텀 위젯 구현
class _CustomInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final VoidCallback onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  // 6주차 추가
  final String? errorText; // ViewModel의 중복 확인 에러 문구
  final Widget? trailing; // 입력창 오른쪽 버튼
  final Widget? footer; // 입력창 아래 안내 문구

  const _CustomInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    required this.textInputAction,
    required this.validator,
    required this.onChanged,
    this.onFieldSubmitted,
    this.errorText,
    this.trailing,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                decoration: InputDecoration(
                  hintText: hintText,
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF6B4EFF),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: validator,
                onChanged: (_) => onChanged(),
                onFieldSubmitted: onFieldSubmitted,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              // 입력창 높이와 맞추기 위한 미세 조정
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: trailing!,
              ),
            ],
          ],
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: footer!,
          ),
      ],
    );
  }
}

// 위젯 2 입력 필드 모음
class _FormInputFields extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _FormInputFields({
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();

    return Column(
      children: [
        _CustomInputField(
          label: '닉네임',
          hintText: '닉네임을 입력해주세요',
          controller: nicknameController,
          textInputAction: TextInputAction.next,
          errorText: vm.nicknameErrorText,
          trailing: MovieLogButton(
            label: '중복 확인',
            isLoading: vm.nicknameCheckStatus == CheckStatus.checking,
            onPressed: vm.canCheckNickname
                ? () => vm.checkNickname(nicknameController.text)
                : null,
          ),
          footer: vm.nicknameCheckStatus == CheckStatus.available
              ? const _SuccessText('사용할 수 있는 닉네임입니다.')
              : null,
          validator: (v) {
            final val = v?.trim() ?? '';
            if (val.isEmpty) return '닉네임을 입력해주세요.';
            if (val.length < 2) return '닉네임은 2자 이상이어야 합니다.';
            return null;
          },
          onChanged: () {
            vm.onNicknameChanged(nicknameController.text);
            onChanged();
          },
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(emailFocusNode),
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          label: '이메일',
          hintText: '이메일 주소를 입력해주세요',
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: vm.emailErrorText,
          trailing: MovieLogButton(
            label: '중복 확인',
            isLoading: vm.emailCheckStatus == CheckStatus.checking,
            onPressed: vm.canCheckEmail
                ? () => vm.checkEmail(emailController.text)
                : null,
          ),
          footer: vm.emailCheckStatus == CheckStatus.available
              ? const _SuccessText('사용할 수 있는 이메일입니다.')
              : null,
          validator: (v) {
            final val = v?.trim() ?? '';
            if (val.isEmpty) return '이메일을 입력해주세요.';

            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(val)) return '올바른 이메일 형식이 아닙니다.';

            return null;
          },
          onChanged: () {
            vm.onEmailChanged(emailController.text);
            onChanged();
          },
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passwordFocusNode),
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          label: '비밀번호',
          hintText: '비밀번호를 입력해주세요',
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (v) {
            final val = v ?? '';
            if (val.isEmpty) return '비밀번호를 입력해주세요.';
            if (val.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
            return null;
          },
          onChanged: onChanged,
          onFieldSubmitted: (_) => onSubmit(),
        ),
      ],
    );
  }
}

// 위젯 3 약관 동의 및 버튼
class _TermsAndSubmitSection extends StatelessWidget {
  final bool agreedToTerms;
  final ValueChanged<bool?> onTermsChanged;
  final bool canSubmit;
  final VoidCallback onSubmit;

  const _TermsAndSubmitSection({
    required this.agreedToTerms,
    required this.onTermsChanged,
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: agreedToTerms,
              onChanged: onTermsChanged,
              activeColor: const Color(0xFF6B4EFF),
            ),
            const Text(
              '필수 약관에 동의합니다',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 전체 너비 버튼: width: double.infinity
        MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          onPressed: canSubmit ? onSubmit : null,
        ),
      ],
    );
  }
}