import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/services/member_check_service.dart';

enum CheckStatus {
  idle,
  checking,
  available,
  duplicated,
  error,
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);

  final MemberCheckService _service;

  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  CheckStatus emailCheckStatus = CheckStatus.idle;

  String? nicknameErrorText;
  String? emailErrorText;

  String _currentNickname = '';
  String _currentEmail = '';

  String? _duplicatedNickname;
  String? _duplicatedEmail;

  int _nicknameRequestVersion = 0;
  int _emailRequestVersion = 0;

  bool _disposed = false;

  bool get canCheckNickname =>
      _currentNickname.isNotEmpty &&
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  bool get canCheckEmail =>
      _currentEmail.isNotEmpty &&
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  // 닉네임 입력이 변경될 때
  void onNicknameChanged(String value) {
    final trimmed = value.trim();

    _currentNickname = trimmed;
    _nicknameRequestVersion++;

    if (_duplicatedNickname != null &&
        trimmed == _duplicatedNickname) {
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }

    if (!_disposed) notifyListeners();
  }

  // 이메일 입력이 변경될 때
  void onEmailChanged(String value) {
    final trimmed = value.trim();

    _currentEmail = trimmed;
    _emailRequestVersion++;

    if (_duplicatedEmail != null &&
        trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }

    if (!_disposed) notifyListeners();
  }

  // 닉네임 중복 확인
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
      final available =
          await _service.checkNickname(requested);

      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;

      nicknameErrorText =
          available ? null : '이미 사용 중인 닉네임입니다.';

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
      nicknameErrorText =
          '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed &&
        version == _nicknameRequestVersion) {
      notifyListeners();
    }
  }

  // 이메일 중복 확인
  Future<void> checkEmail(String value) async {
    final requested = value.trim();

    if (requested.isEmpty ||
        requested != _currentEmail ||
        !canCheckEmail) {
      return;
    }

    final version = ++_emailRequestVersion;

    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final available =
          await _service.checkEmail(requested);

      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;

      emailErrorText =
          available ? null : '이미 사용 중인 이메일입니다.';

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
      emailErrorText =
          '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed &&
        version == _emailRequestVersion) {
      notifyListeners();
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
