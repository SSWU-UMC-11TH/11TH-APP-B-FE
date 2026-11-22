import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/create_member_request.dart';
import 'package:flutter_application_1/view_models/sign_up_view_model.dart';
import 'package:flutter_application_1/widgets/movielog_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final _emailRegex = RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$');

/// 비밀번호: 8자 이상, 소문자·대문자·숫자·특수문자(!@#$%^&*) 각각 1개 이상
String? validatePasswordFormat(String? value) {
  final val = value ?? '';
  if (val.isEmpty) return '비밀번호를 입력해주세요.';
  if (val.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
  if (!RegExp(r'[a-z]').hasMatch(val) ||
      !RegExp(r'[A-Z]').hasMatch(val) ||
      !RegExp(r'[0-9]').hasMatch(val) ||
      !RegExp(r'[!@#$%^&*]').hasMatch(val)) {
    return '대문자/소문자/숫자/특수문자(!@#\$%^&*)를 각각 포함해야 합니다.';
  }
  return null;
}

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

  /// 로컬 Form 검증 + 닉네임·이메일 중복 확인 통과 + 제출 중 아님
  bool _canSubmit(SignUpViewModel vm) {
    final nickname = _nicknameController.text.trim();
    return nickname.length >= 2 &&
        nickname.length <= 12 &&
        _emailRegex.hasMatch(_emailController.text.trim()) &&
        validatePasswordFormat(_passwordController.text) == null &&
        _agreedToTerms &&
        vm.isDuplicateCheckPassed &&
        !vm.isSubmitting;
  }

  Future<void> _submitForm() async {
    final vm = context.read<SignUpViewModel>();
    if (!_canSubmit(vm)) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();

    await vm.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return; // 화면 이탈 뒤에는 이전 요청 결과를 반영하지 않습니다.

    final messenger = ScaffoldMessenger.of(context);
    final memberId = vm.createdMemberId;
    if (vm.submitStatus == SubmitStatus.success && memberId != null) {
      // 8주차: 가입 후에는 로그인해서 토큰을 받아야 보호 화면에 들어갈 수 있습니다.
      messenger.showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다! 로그인해 주세요.')),
      );
      context.go('/login');
      return;
    }
    final message = vm.snackbarMessage;
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();

    // 제출 중에는 뒤로가기·스와이프 백을 막고, 끝나면(성공/실패) 다시 나갈 수 있습니다.
    return PopScope(
      canPop: !vm.isSubmitting,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F8F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: !vm.isSubmitting,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                    onTermsChanged: vm.isSubmitting
                        ? null
                        : (value) =>
                            setState(() => _agreedToTerms = value ?? false),
                    canSubmit: _canSubmit(vm),
                    isSubmitting: vm.isSubmitting,
                    onSubmit: _submitForm,
                  ),
                ],
              ),
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

// 공통 커스텀 위젯 구현
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
  final String? errorText; // ViewModel의 중복 확인 / 서버 에러 문구
  final Widget? trailing; // 입력창 오른쪽 버튼
  final Widget? footer; // 입력창 아래 안내 문구

  // 7주차 추가: 제출 중에는 입력을 잠급니다.
  final bool readOnly;

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
    this.readOnly = false,
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
                readOnly: readOnly,
                decoration: InputDecoration(
                  hintText: hintText,
                  errorText: errorText,
                  errorMaxLines: 2,
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
          hintText: '닉네임을 입력해주세요 (2~12자)',
          controller: nicknameController,
          textInputAction: TextInputAction.next,
          readOnly: vm.isSubmitting,
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
            if (val.length < 2 || val.length > 12) {
              return '닉네임은 2~12자여야 합니다.';
            }
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
          readOnly: vm.isSubmitting,
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
            if (!_emailRegex.hasMatch(val)) return '올바른 이메일 형식이 아닙니다.';
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
          hintText: '대·소문자, 숫자, 특수문자 포함 8자 이상',
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true,
          textInputAction: TextInputAction.done,
          readOnly: vm.isSubmitting,
          // 로컬 validator가 통과해도 서버가 거부한 값(400)이면 계속 에러로 보입니다.
          errorText: vm.passwordErrorText,
          validator: validatePasswordFormat,
          onChanged: () {
            vm.onPasswordChanged();
            onChanged();
          },
          onFieldSubmitted: (_) => onSubmit(),
        ),
      ],
    );
  }
}

// 위젯 3 약관 동의 및 버튼
class _TermsAndSubmitSection extends StatelessWidget {
  final bool agreedToTerms;
  final ValueChanged<bool?>? onTermsChanged;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _TermsAndSubmitSection({
    required this.agreedToTerms,
    required this.onTermsChanged,
    required this.canSubmit,
    required this.isSubmitting,
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
        // 제출 중에는 회색 + 로딩 인디케이터로 바뀌고 다시 누를 수 없습니다.
        MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          isLoading: isSubmitting,
          onPressed: canSubmit ? onSubmit : null,
        ),
      ],
    );
  }
}
