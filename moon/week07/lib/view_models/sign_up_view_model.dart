import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';

// 닉네임·이메일 중복 확인 상태
enum CheckStatus { idle, checking, available, duplicated, error }

// 회원가입 제출 상태
enum SubmitStatus { idle, submitting, success, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);

  final SignUpService _service;

  // 중복 확인 상태
  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  CheckStatus emailCheckStatus = CheckStatus.idle;

  String? nicknameErrorText;
  String? emailErrorText;

  String _currentNickname = '';
  String _currentEmail = '';

  // 6주차 Challenge: 마지막으로 중복이었던 값 기억
  String? _duplicatedNickname;
  String? _duplicatedEmail;

  int _nicknameRequestVersion = 0;
  int _emailRequestVersion = 0;

  // 7주차 회원가입 상태
  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;

  String? passwordErrorText;
  String? snackbarMessage;

  bool _disposed = false;

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  // 중복 확인 버튼 활성화 조건
  bool get canCheckNickname =>
      !_disposed &&
      !isSubmitting &&
      _currentNickname.isNotEmpty &&
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  bool get canCheckEmail =>
      !_disposed &&
      !isSubmitting &&
      _currentEmail.isNotEmpty &&
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  // 회원가입 버튼 활성화 조건
  bool get canSubmit =>
      !_disposed &&
      !isSubmitting &&
      nicknameCheckStatus == CheckStatus.available &&
      emailCheckStatus == CheckStatus.available;

  // 닉네임 변경
  void onNicknameChanged(String value) {
    if (_disposed || isSubmitting) return;

    final trimmed = value.trim();

    _currentNickname = trimmed;
    _nicknameRequestVersion++;

    // 기존 회원가입 오류 초기화
    _resetSubmitResult();

    if (_duplicatedNickname != null && trimmed == _duplicatedNickname) {
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }

    notifyListeners();
  }

  // 이메일 변경
  void onEmailChanged(String value) {
    if (_disposed || isSubmitting) return;

    final trimmed = value.trim();

    _currentEmail = trimmed;
    _emailRequestVersion++;

    _resetSubmitResult();

    if (_duplicatedEmail != null && trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }

    notifyListeners();
  }

  // 비밀번호 변경
  void onPasswordChanged() {
    if (_disposed || isSubmitting) return;

    passwordErrorText = null;
    _resetSubmitResult();
    notifyListeners();
  }

  // 닉네임 중복 확인
  Future<void> checkNickname(String value) async {
    final requested = value.trim();

    if (_disposed ||
        requested.isEmpty ||
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

      if (!available) {
        _duplicatedNickname = requested;
      }
    } on DioException {
      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _nicknameRequestVersion) {
      notifyListeners();
    }
  }

  // 이메일 중복 확인
  Future<void> checkEmail(String value) async {
    final requested = value.trim();

    if (_disposed ||
        requested.isEmpty ||
        requested != _currentEmail ||
        !canCheckEmail) {
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

      if (!available) {
        _duplicatedEmail = requested;
      }
    } on DioException {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _emailRequestVersion) {
      notifyListeners();
    }
  }

  // 7주차: 실제 회원가입 POST
  Future<void> submit(CreateMemberRequest request) async {
    if (!canSubmit) return;

    // 입력값이 실제 확인된 문자열과 같은지 검증
    if (request.nickname.trim() != _currentNickname ||
        request.email.trim() != _currentEmail) {
      return;
    }

    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;

    notifyListeners();

    try {
      final response = await _service.signUp(request);

      if (_disposed) return;

      final id = response.result?.memberId;

      if (!response.isSuccess || id == null || id < 1) {
        throw StateError('회원가입 응답을 확인할 수 없습니다.');
      }

      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;

      final message = _writeSignUpErrorMessage(error);

      // 서버에서 비밀번호 오류로 확인된 400만 입력창에 표시
      if (error.response?.statusCode == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        // 다른 400 및 409는 Snackbar로 안내
        snackbarMessage = message;
      }
    } on StateError {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    } catch (error) {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;
      snackbarMessage = '회원가입 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';

      debugPrint('[SignUpViewModel 오류] ${error.runtimeType}');
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  // v6 공통 오류 응답에서 서버 메시지 추출
  String _writeSignUpErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }

  // 입력값 변경 시 기존 제출 결과 초기화
  void _resetSubmitResult() {
    submitStatus = SubmitStatus.idle;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _nicknameRequestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
