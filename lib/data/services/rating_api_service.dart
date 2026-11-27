import 'package:dio/dio.dart';

import '../../core/network/api_error.dart';
import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

/// v7 등록·수정 성공 result는 Rating 객체입니다.
RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );
  final rating = common.result;
  if (rating == null) throw StateError('평점 result가 없습니다.');
  return rating;
}

List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

/// 유저별 평점 조회는 공개 Client, 등록·수정·삭제는 보호 Client로 보냅니다.
/// 어떤 Client를 쓸지는 Service가 메서드별로 결정합니다.
class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio;
  final Dio _authDio;

  /// 공개 조회: 직접 배열, 토큰 없음 (memberId path 유지)
  Future<List<RatingDto>> fetchMemberRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    return parseRatingList(response.data);
  }

  /// POST /v7/ratings — body와 path에 memberId가 없습니다. Authorization 헤더로 식별합니다.
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v7/ratings', data: request.toJson());
    return parseRatingResult(response.data);
  }

  /// PATCH는 전체 교체라 comment를 생략하면 기존 후기가 null로 덮입니다.
  /// 기존 score·comment를 채운 Dialog 값으로 두 값을 함께 보냅니다.
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v7/ratings/$ratingId',
      data: UpdateRatingRequest(score: score, comment: comment).toJson(),
    );
    return parseRatingResult(response.data);
  }

  /// v7 삭제 성공은 204가 아니라 result가 null인 200 응답입니다.
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

/// 화면에 보여줄 수 있는 쓰기 실패. Dialog가 message를 그대로 표시합니다.
class RatingActionException implements Exception {
  const RatingActionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// v7 도메인 오류 code별 안내 문구
String writeRatingErrorMessage(DioException error) {
  final code = apiErrorCode(error);
  switch (code) {
    case 'RATING403_1':
      return '본인이 작성한 평점만 수정하거나 삭제할 수 있어요.';
    case 'RATING404_1':
      return '존재하지 않는 평점이에요. 목록을 새로고침했어요.';
    case 'RATING409_1':
      return '이미 이 영화에 평점을 남겼어요. "내가 등록한 평점"에서 확인해 주세요.';
    case 'MEMBER404_1':
      return '회원 정보를 찾을 수 없어요.';
    case 'COMMON400':
      return apiErrorMessage(error) ?? '입력값을 확인해 주세요.';
  }
  if (isSessionExpiredCode(code)) return '로그인이 만료됐어요. 다시 로그인해 주세요.';
  if (error.response == null) return '네트워크 상태를 확인하고 다시 시도해 주세요.';
  return apiErrorMessage(error) ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}
