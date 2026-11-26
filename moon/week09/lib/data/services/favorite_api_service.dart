import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/favorite_check_dto.dart';
import '../models/favorite_response_dto.dart';

class FavoriteApiService {
  FavoriteApiService(this._dio);

  final Dio _dio;

  // 즐겨찾기 등록: POST /v8/favorites
  Future<FavoriteResponseDto> addFavorite({
    required int movieId,
  }) async {
    final response = await _dio.post(
      '/v8/favorites',
      data: {'movieId': movieId},
    );

    final body = CommonResponse<FavoriteResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      FavoriteResponseDto.fromJson,
    );

    final result = body.result;
    if (result == null) {
      throw const FormatException('즐겨찾기 등록 응답이 비어 있습니다.');
    }

    return result;
  }

  // 내 즐겨찾기 목록 조회: GET /v8/favorites
  Future<List<FavoriteResponseDto>> fetchMyFavorites() async {
    final response = await _dio.get('/v8/favorites');

    final body = CommonResponse<List<FavoriteResponseDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => (value as List<dynamic>)
          .map(FavoriteResponseDto.fromJson)
          .toList(),
    );

    return body.result ?? const [];
  }

  // 특정 영화의 즐겨찾기 여부 조회
  // GET /v8/favorites/{movieId}
  Future<FavoriteCheckDto> checkFavorite({
    required int movieId,
  }) async {
    final response = await _dio.get('/v8/favorites/$movieId');

    final body = CommonResponse<FavoriteCheckDto>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => FavoriteCheckDto.fromJson(
        value,
        movieId: movieId,
      ),
    );

    final result = body.result;
    if (result == null) {
      throw const FormatException('즐겨찾기 여부 응답이 비어 있습니다.');
    }

    return result;
  }

  // 즐겨찾기 해제: DELETE /v8/favorites/{movieId}
  Future<void> deleteFavorite({
    required int movieId,
  }) async {
    await _dio.delete('/v8/favorites/$movieId');
  }
}
