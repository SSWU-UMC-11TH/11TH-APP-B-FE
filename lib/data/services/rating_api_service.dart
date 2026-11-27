import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);

  final Dio _dio;

  /// 200 + 직접 배열 (v5부터 있던 조회 API라 성공 응답은 wrapper가 없습니다)
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v6/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 201 + wrapper. result(ratingId/null) 계약이 확정되지 않아 파싱하지 않고,
  /// 성공 후 GET으로 목록을 다시 확인합니다.
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

  /// 200 + result null. score는 필수, comment는 유지하려면 기존 값을 명시적으로 보냅니다.
  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required UpdateRatingRequest request,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: request.toJson(),
    );
  }

  /// 204 + body 없음. 응답 본문을 JSON으로 파싱하지 않습니다.
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

/// 화면에 보여줄 수 있는 쓰기 실패. Dialog가 message를 그대로 표시합니다.
class RatingActionException implements Exception {
  const RatingActionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 같은 COMMON404라도 등록에서는 "유저", 수정·삭제에서는 "평점"을 가리키므로
/// code별 문구를 새로 만들지 않고 서버 message를 그대로 보여줍니다.
String writeErrorMessage(DioException error) {
  final common = tryParseCommonError(error.response?.data);
  if (common != null) return common.message;
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return '네트워크 연결을 확인한 뒤 다시 시도해 주세요.';
  }
  return '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

/// code는 문구가 아니라 "다시 조회할지"를 정하는 데만 씁니다.
/// 403·404는 화면 목록이 서버 상태와 어긋났다는 뜻이라 다시 조회합니다.
/// 400(별점 범위)·409(중복 등록)는 값만 고치거나 다시 시도하면 되므로 재조회하지 않습니다.
bool shouldRefreshAfterRatingError(DioException error) {
  final code = tryParseCommonError(error.response?.data)?.code;
  return code == 'COMMON403' || code == 'COMMON404';
}

/// 평점 목록 조회(GET) 실패 문구
String writeMyRatingsErrorMessage(DioException error) {
  final common = tryParseCommonError(error.response?.data);
  if (common != null) return common.message;
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}
