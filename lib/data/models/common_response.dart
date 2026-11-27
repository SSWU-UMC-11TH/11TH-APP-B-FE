/// v6 공통 응답 형식 { isSuccess, code, message, result }
///
/// result는 API마다 담기는 값이 달라 제네릭 T로 표현합니다.
/// 값이 없거나 실패 응답이면 result는 null입니다.
class CommonResponse<T> {
  const CommonResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  final bool isSuccess;
  final String code;
  final String message;
  final T? result;

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) parseResult,
  ) {
    final rawResult = json['result'];
    return CommonResponse<T>(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: rawResult == null ? null : parseResult(rawResult),
    );
  }
}

/// DioException의 응답 본문이 공통 응답 형식이면 파싱하고, 아니면 null을 반환합니다.
CommonResponse<Object?>? tryParseCommonError(Object? data) {
  if (data is! Map<String, dynamic>) return null;
  try {
    return CommonResponse<Object?>.fromJson(data, (value) => value);
  } catch (_) {
    // 공통 형식이 아닌 본문(프록시 오류 페이지 등)은 무시합니다.
    return null;
  }
}
