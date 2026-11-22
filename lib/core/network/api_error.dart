import 'package:dio/dio.dart';

/// 서버 공통 오류 응답에서 code를 꺼냅니다. (예: AUTH401_2, RATING409_1)
String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final code = data['code'];
  return code is String ? code : null;
}

/// 서버 공통 오류 응답에서 사용자에게 보여줄 message를 꺼냅니다.
String? apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}

/// 보호 요청에서 토큰이 없거나(2) 무효하거나(3) 만료된(4) 경우만 세션 만료 후보입니다.
/// 로그인 입력 오류 AUTH401_1은 여기에 포함하지 않습니다.
bool isSessionExpiredCode(String? code) =>
    code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';

/// 응답 자체가 없는 네트워크 계열 실패인지 확인합니다.
bool isNetworkError(DioException error) =>
    error.response == null &&
    (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown);
