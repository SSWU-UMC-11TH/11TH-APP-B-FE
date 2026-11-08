import 'package:dio/dio.dart';

import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);

  final Dio _dio;

  // 평점 목록 조회 GET
  Future<List<RatingDto>> getMemberRatings(int memberId) async {
    final response = await _dio.get('/v6/members/$memberId/ratings');

    final data = response.data as List<dynamic>;

    return data
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // 평점 등록 POST
  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );

    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  // 평점 수정 PATCH
  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment ?? ''},
    );
  }

  // 평점 삭제 DELETE
  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );

    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

// 서버 오류 메시지 구분
String writeErrorMessage(DioException error) {
  final statusCode = error.response?.statusCode;
  final data = error.response?.data;

  String? serverMessage;

  if (data is Map && data['message'] is String) {
    final message = data['message'] as String;

    if (message.trim().isNotEmpty) {
      serverMessage = message;
    }
  }

  switch (statusCode) {
    case 400:
      return serverMessage ?? '평점 또는 코멘트 입력값을 확인해주세요.';
    case 403:
      return '해당 평점을 수정하거나 삭제할 권한이 없습니다.';
    case 404:
      return '평점을 찾을 수 없습니다. 목록을 다시 확인해주세요.';
    case 409:
      return serverMessage ?? '이미 등록된 평점이 있습니다.';
    default:
      return serverMessage ?? '요청에 실패했습니다. 다시 시도해주세요.';
  }
}

// 서버 오류 발생 후 목록 재조회가 필요한지 판단
bool shouldRefreshAfterRatingError(DioException error) {
  final statusCode = error.response?.statusCode;

  return statusCode == 403 || statusCode == 404;
}
