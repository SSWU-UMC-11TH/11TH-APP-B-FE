import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

/// 회원가입·평점 등록처럼 "쓰기 요청" 하나의 진행 상태입니다.
enum SubmitStatus { idle, submitting, success, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);

  final SignUpService _service;
  bool _disposed = false;

  // ───────────── 회원가입 제출 ─────────────
  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId; // 가입 성공 응답에서 읽은 실제 ID입니다.
  String? passwordErrorText; // 비밀번호 칸에 붙는 서버 400 오류
  String? snackbarMessage; // 어느 칸에도 붙지 않는 오류(그 외 400, 409)

  /// 중복 확인이 둘 다 통과했고 제출 중이 아닐 때만 가입할 수 있습니다.
  bool get duplicateChecksPassed =>
      nicknameCheckStatus == CheckStatus.available &&
      emailCheckStatus == CheckStatus.available;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  void onPasswordChanged() {
    passwordErrorText = null;
    notifyListeners();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting) return;
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _service.signUp(request);
      final id = response.result?.memberId;
      if (id == null) throw StateError('회원가입 결과에 memberId가 없습니다.');
      if (_disposed) return;
      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      final message = writeSignUpErrorMessage(error);
      if (error.response?.statusCode == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } on StateError {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    }
    if (!_disposed) notifyListeners();
  }

  // ───────────── 닉네임 ─────────────
  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String? _duplicatedNickname; // 마지막으로 "중복"이었던 값
  String _currentNickname = '';
  int _nicknameRequestVersion = 0;

  bool get canCheckNickname =>
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  void onNicknameChanged(String value) {
    final trimmed = value.trim();
    snackbarMessage = null; // 입력을 바꾸면 이전 서버 오류도 무효화합니다.
    _currentNickname = trimmed;
    _nicknameRequestVersion++; // 이전 요청의 응답을 무효화합니다.
    if (_duplicatedNickname != null && trimmed == _duplicatedNickname) {
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> checkNickname(String value) async {
    final requested = value.trim();
    if (requested.isEmpty ||
        requested != _currentNickname ||
        !canCheckNickname) {
      return;
    }

    final version = ++_nicknameRequestVersion;
    nicknameCheckStatus = CheckStatus.checking;
    nicknameErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkNickname(requested);
      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }
      nicknameCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      nicknameErrorText = available ? null : '이미 사용 중인 닉네임입니다.';
      if (!available) _duplicatedNickname = requested;
    } on DioException {
      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }
      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    if (!_disposed && version == _nicknameRequestVersion) notifyListeners();
  }

  // ───────────── 이메일 (닉네임과 같은 구조, 상태는 따로) ─────────────
  CheckStatus emailCheckStatus = CheckStatus.idle;
  String? emailErrorText;
  String? _duplicatedEmail; // 마지막으로 "중복"이었던 값
  String _currentEmail = '';
  int _emailRequestVersion = 0;

  bool get canCheckEmail =>
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  void onEmailChanged(String value) {
    final trimmed = value.trim();
    snackbarMessage = null; // 입력을 바꾸면 이전 서버 오류도 무효화합니다.
    _currentEmail = trimmed;
    _emailRequestVersion++; // 이전 요청의 응답을 무효화합니다.
    if (_duplicatedEmail != null && trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> checkEmail(String value) async {
    final requested = value.trim();
    if (requested.isEmpty || requested != _currentEmail || !canCheckEmail) {
      return;
    }

    final version = ++_emailRequestVersion;
    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkEmail(requested);
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }
      emailCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      emailErrorText = available ? null : '이미 사용 중인 이메일입니다.';
      if (!available) _duplicatedEmail = requested;
    } on DioException {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }
      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    if (!_disposed && version == _emailRequestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _nicknameRequestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
