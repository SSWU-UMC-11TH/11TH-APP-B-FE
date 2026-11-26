import 'package:dio/dio.dart';
import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';
import '../../core/network/api_error.dart';

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio;
  final Dio _authDio;

  RatingDto _parseRatingResult(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw StateError('평점 응답 형식이 올바르지 않습니다.');
    }

    final common = CommonResponse<RatingDto>.fromJson(
      data,
      (value) => RatingDto.fromJson(value as Map<String, dynamic>),
    );

    final rating = common.result;
    if (rating == null) {
      throw StateError('평점 result가 없습니다.');
    }

    return rating;
  }

  // v7: 회원별 평점 목록 조회 (공개 API)
  Future<List<RatingDto>> getMemberRatingsV7(int memberId) async {
    final response = await _publicDio.get(
      '/v8/members/$memberId/ratings',
    );

    final data = response.data;
    if (data is! List) {
      throw StateError('평점 목록 응답은 배열이어야 합니다.');
    }

    return data
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // v7: JWT 기반 평점 등록
  Future<RatingDto> createRatingV7(CreateRatingRequest request) async {
    final response = await _authDio.post(
      '/v8/ratings',
      data: request.toJson(),
    );

    return _parseRatingResult(response.data);
  }

  // v7: JWT 기반 평점 수정
  Future<RatingDto> updateRatingV7({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v8/ratings/$ratingId',
      data: {
        'score': score,
        'comment': comment,
      },
    );

    return _parseRatingResult(response.data);
  }

  // v7: JWT 기반 평점 삭제
  Future<void> deleteRatingV7(int ratingId) async {
    final response = await _authDio.delete(
      '/v8/ratings/$ratingId',
    );

    if (response.statusCode != 200) {
      throw StateError(
        '예상하지 못한 삭제 응답: ${response.statusCode}',
      );
    }
  }
}

// 평점 API 오류 메시지
String writeErrorMessage(DioException error) {
  final code = apiErrorCode(error);
  final message = apiErrorMessage(error);

  switch (code) {
    case 'AUTH401_2':
    case 'AUTH401_3':
    case 'AUTH401_4':
      return '로그인이 만료됐어요. 다시 로그인해 주세요.';
    case 'RATING403_1':
      return '해당 평점을 수정하거나 삭제할 권한이 없습니다.';
    case 'RATING404_1':
      return '평점을 찾을 수 없습니다.';
    case 'RATING409_1':
      return '이미 등록된 평점이 있습니다.';
    case 'COMMON400':
      return message ?? '평점 또는 코멘트 입력값을 확인해 주세요.';
  }

  switch (error.response?.statusCode) {
    case 400:
      return message ?? '입력값을 확인해 주세요.';
    case 401:
      return '로그인 인증에 실패했어요. 다시 로그인해 주세요.';
    case 403:
      return '해당 평점을 변경할 권한이 없습니다.';
    case 404:
      return '평점을 찾을 수 없습니다.';
    case 409:
      return message ?? '이미 등록된 평점이 있습니다.';
    default:
      return '요청에 실패했습니다. 다시 시도해 주세요.';
  }
}

// 평점 오류 이후 목록 갱신이 필요한지 확인
bool shouldRefreshAfterRatingError(DioException error) {
  final code = apiErrorCode(error);

  return code == 'RATING403_1' ||
      code == 'RATING404_1' ||
      error.response?.statusCode == 403 ||
      error.response?.statusCode == 404;
}
