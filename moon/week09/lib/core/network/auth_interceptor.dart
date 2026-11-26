import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final TokenStorage _storage;

  
bool _isProtected(RequestOptions options) {
  // MovieLog 서버 외에는 JWT를 전송하지 않습니다.
  if (options.uri.host != 'workbook.devnoco.com') {
    return false;
  }

  final path = options.uri.path;
  final method = options.method.toUpperCase();

  // 로그인, 내 정보, 평점 API의 v8 보호 경로
  final existingProtected =
      path == '/v8/members/me' ||
      path == '/v8/ratings' ||
      path.startsWith('/v8/ratings/');

  // 9주차 즐겨찾기 API
  final favorites =
      (path == '/v8/favorites' &&
          (method == 'GET' || method == 'POST')) ||
      (RegExp(r'^/v8/favorites/[1-9]\d*$').hasMatch(path) &&
          (method == 'GET' || method == 'DELETE'));

  // Challenge: 평점과 즐겨찾기 통합 저장
  final movieRecord =
      path == '/v8/movie-records' && method == 'POST';

  return existingProtected || favorites || movieRecord;
}


  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isProtected(options)) {
      handler.next(options);
      return;
    }

    options.headers.remove('Authorization');

    try {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('인증 저장소를 읽지 못했습니다.'),
        ),
      );
    }
  }
}
