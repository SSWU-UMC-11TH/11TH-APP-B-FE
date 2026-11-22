import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';
import 'submit_status.dart';

export 'submit_status.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

class SignUpViewModel extends ChangeNotifier {
  // 6주차 MemberCheckService → 7주차 SignUpService
  SignUpViewModel(this._service);

  final SignUpService _service;
  bool _disposed = false;

  // ───────────── 닉네임 ─────────────
  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String? _duplicatedNickname;
  String _currentNickname = '';
  int _nicknameRequestVersion = 0;

  bool get canCheckNickname =>
      !isSubmitting &&
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  void onNicknameChanged(String value) {
    final trimmed = value.trim();
    _currentNickname = trimmed;
    _nicknameRequestVersion++; // 이전 요청의 응답을 무효화합니다.
    snackbarMessage = null; // 이전 서버 오류(409 등)도 함께 무효화합니다.

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
      nicknameCheckStatus =
          available ? CheckStatus.available : CheckStatus.duplicated;
      nicknameErrorText = available ? null : '이미 사용 중인 닉네임입니다.';
      if (!available) _duplicatedNickname = requested;
    } on DioException catch (error) {
      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }
      nicknameCheckStatus = CheckStatus.error;
      // v6 오류는 공통 응답 형식이라 서버 message를 우선 사용합니다.
      nicknameErrorText = _checkErrorMessage(error);
    }
    if (!_disposed && version == _nicknameRequestVersion) notifyListeners();
  }

  // ───────────── 이메일 ─────────────
  CheckStatus emailCheckStatus = CheckStatus.idle;
  String? emailErrorText;
  String? _duplicatedEmail;
  String _currentEmail = '';
  int _emailRequestVersion = 0;

  bool get canCheckEmail =>
      !isSubmitting &&
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  void onEmailChanged(String value) {
    final trimmed = value.trim();
    _currentEmail = trimmed;
    _emailRequestVersion++;
    snackbarMessage = null;

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
      emailCheckStatus =
          available ? CheckStatus.available : CheckStatus.duplicated;
      emailErrorText = available ? null : '이미 사용 중인 이메일입니다.';
      if (!available) _duplicatedEmail = requested;
    } on DioException catch (error) {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }
      emailCheckStatus = CheckStatus.error;
      emailErrorText = _checkErrorMessage(error);
    }
    if (!_disposed && version == _emailRequestVersion) notifyListeners();
  }

  String _checkErrorMessage(DioException error) {
    // 응답이 없으면(네트워크 오류) 서버 message가 없으므로 기본 문구를 씁니다.
    if (error.response == null) return '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    return writeSignUpErrorMessage(error);
  }

  // ───────────── 회원가입 제출 (7주차) ─────────────
  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId; // 가입 성공 응답에서 읽은 실제 ID입니다.
  String? passwordErrorText; // 비밀번호 입력칸에 붙는 필드 단위 오류 (400)
  String? snackbarMessage; // 어느 입력칸에도 붙지 않는 화면 단위 오류 (그 외 400, 409)

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  /// 닉네임·이메일 중복 확인이 모두 통과해야 가입할 수 있습니다.
  bool get isDuplicateCheckPassed =>
      nicknameCheckStatus == CheckStatus.available &&
      emailCheckStatus == CheckStatus.available;

  void onPasswordChanged() {
    if (passwordErrorText == null && snackbarMessage == null) return;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (isSubmitting) return; // 연속 탭 방지
    if (!isDuplicateCheckPassed) return;

    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _service.signUp(request);
      if (_disposed) return;
      final id = response.result?.memberId;
      if (id == null) throw StateError('회원가입 결과에 memberId가 없습니다.');
      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      final message = writeSignUpErrorMessage(error);
      final status = error.response?.statusCode;
      if (status == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        // 그 외 400, 409(최종 중복), 네트워크 오류는 Snackbar로 보여줍니다.
        snackbarMessage = message;
      }
      if (status == 409) {
        // 중복 확인 직후 다른 사용자가 먼저 가입한 경우입니다. 다시 확인하도록 되돌립니다.
        _resetDuplicateChecksAfterConflict(message);
      }
    } on StateError {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    } on TypeError {
      // 응답 JSON 형식이 계약과 다른 경우
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    }
    if (!_disposed) notifyListeners();
  }

  /// 서버는 이메일을 먼저 검사하므로 message로 어느 쪽 중복인지 구분합니다.
  void _resetDuplicateChecksAfterConflict(String message) {
    if (message.contains('이메일')) {
      _duplicatedEmail = _currentEmail;
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else if (message.contains('닉네임')) {
      _duplicatedNickname = _currentNickname;
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _nicknameRequestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
