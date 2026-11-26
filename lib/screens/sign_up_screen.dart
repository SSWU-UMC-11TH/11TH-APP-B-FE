import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';

// Figma W2 회원가입 화면 기준 값
const _bg = Color(0xFFFAF9F5);
const _violet = Color(0xFF6750A4);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);
const _border = Color(0xFFCBC4D2);
const _fieldFill = Color(0xFFF5F3EF);
const _errorColor = Color(0xFFB3261E);
const _errorFill = Color(0xFFFFDAD6);
const _successColor = Color(0xFF2E7D32); // 사용 가능 (초록)
const _checkingColor = Color(0xFF1E6FD9); // 확인 중 (파랑)

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
                          // ViewModel의 중복 확인 상태가 바뀌면 이 부분만 다시 그린다.
                          Consumer<SignUpViewModel>(
                            builder: (context, viewModel, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _LabeledField(
                                    label: '닉네임',
                                    controller: _nicknameController,
                                    touched: _nicknameTouched,
                                    valid: _nicknameValid,
                                    errorText: '닉네임은 2자 이상이어야 합니다.',
                                    serverErrorText:
                                        viewModel.nicknameErrorText,
                                    checked:
                                        viewModel.nicknameCheckStatus ==
                                        CheckStatus.available,
                                    statusText: switch (viewModel
                                        .nicknameCheckStatus) {
                                      CheckStatus.checking =>
                                        '닉네임 사용 가능 여부를 확인 중입니다.',
                                      CheckStatus.available => '사용 가능한 닉네임입니다.',
                                      _ => null,
                                    },
                                    statusColor:
                                        viewModel.nicknameCheckStatus ==
                                            CheckStatus.checking
                                        ? _checkingColor
                                        : _successColor,
                                    onChanged: (value) {
                                      setState(() => _nicknameTouched = true);
                                      viewModel.onNicknameChanged(value);
                                    },
                                    // 입력창 옆 보조 버튼: width를 주지 않아 내용 기반 크기
                                    trailing: MovieLogButton(
                                      label: '중복 확인',
                                      isLoading:
                                          viewModel.nicknameCheckStatus ==
                                          CheckStatus.checking,
                                      onPressed: viewModel.canCheckNickname
                                          ? () => viewModel.checkNickname(
                                              _nicknameController.text,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: '이메일',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    touched: _emailTouched,
                                    valid: _emailValid,
                                    errorText: '올바른 이메일 형식이 아닙니다.',
                                    serverErrorText: viewModel.emailErrorText,
                                    checked:
                                        viewModel.emailCheckStatus ==
                                        CheckStatus.available,
                                    statusText: switch (viewModel
                                        .emailCheckStatus) {
                                      CheckStatus.checking =>
                                        '이메일 사용 가능 여부를 확인 중입니다.',
                                      CheckStatus.available => '사용 가능한 이메일입니다.',
                                      _ => null,
                                    },
                                    statusColor:
                                        viewModel.emailCheckStatus ==
                                            CheckStatus.checking
                                        ? _checkingColor
                                        : _successColor,
                                    onChanged: (value) {
                                      setState(() => _emailTouched = true);
                                      viewModel.onEmailChanged(value);
                                    },
                                    trailing: MovieLogButton(
                                      label: '중복 확인',
                                      isLoading:
                                          viewModel.emailCheckStatus ==
                                          CheckStatus.checking,
                                      onPressed: viewModel.canCheckEmail
                                          ? () => viewModel.checkEmail(
                                              _emailController.text,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                            },
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
                          // Form 하단 버튼: 전체 너비
                          // 실제 가입 요청은 이번 주차 범위가 아니라 유효하면 홈으로 이동만 한다.
                          MovieLogButton(
                            label: '가입하기',
                            width: double.infinity,
                            onPressed: _canSubmit ? _submit : null,
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
    this.serverErrorText,
    this.checked = false,
    this.statusText,
    this.statusColor = _successColor,
    this.trailing,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final bool touched;
  final bool valid;

  /// 형식 검사(validator)에 실패했을 때 문구
  final String errorText;

  /// 서버 중복 확인 결과 문구 (ViewModel이 내려줌). 형식 검사를 통과해도 있으면 에러 상태.
  final String? serverErrorText;

  /// 서버가 사용 가능하다고 확인했을 때만 입력창 안에 체크 표시
  final bool checked;

  /// 입력창 아래 안내 문구 (확인 중 / 사용 가능)
  final String? statusText;
  final Color statusColor;

  /// 입력창 오른쪽에 붙는 위젯 (중복 확인 버튼)
  final Widget? trailing;

  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final showError = (touched && !valid) || serverErrorText != null;
    final showCheck = checked && !showError;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 1),
    );

    final field = TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      // 2주차 형식 검사. 입력을 시작한 뒤부터 검사한다.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => valid ? null : errorText,
      style: const TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF211F26),
      ),
      decoration: InputDecoration(
        // validator가 통과하면 서버 결과 문구가 errorText로 표시된다.
        errorText: serverErrorText,
        errorStyle: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: _errorColor,
        ),
        isDense: true,
        filled: true,
        fillColor: showError ? _errorFill : _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        enabledBorder: border(_border),
        focusedBorder: border(_violet),
        errorBorder: border(_errorColor),
        focusedErrorBorder: border(_errorColor),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 20,
        ),
        // 체크/에러 표시는 입력창 안에만 둔다. (버튼과 겹치지 않게)
        suffixIcon: showError
            ? const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.error_outline, size: 20, color: _errorColor),
              )
            : showCheck
            ? const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.check_circle, size: 20, color: _violet),
              )
            : null,
      ),
    );

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
        if (trailing == null)
          field
        else
          // TextFormField와 버튼을 Row의 별도 형제로 두고 8px 간격
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: 8),
              trailing!,
            ],
          ),
        if (statusText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              statusText!,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
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
