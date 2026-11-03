import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Authorization은 대소문자 상관없이 찾아서 원문 대신 마스킹 값으로 찍는다.
    final maskedHeaders = options.headers.map(
      (key, value) => MapEntry(
        key,
        key.toLowerCase() == 'authorization' ? 'Bearer ***' : value,
      ),
    );

    debugPrint('[TMDB 요청] ${options.method} ${options.uri}');
    debugPrint('[TMDB 요청 Header] $maskedHeaders');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[TMDB 요청 Query] ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('[TMDB 응답 Body] ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[TMDB 오류] ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri}',
    );
    debugPrint('[TMDB 오류 내용] ${err.type} ${err.message}');
    handler.next(err);
  }
}
