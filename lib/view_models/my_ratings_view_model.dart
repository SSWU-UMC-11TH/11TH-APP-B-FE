import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_request.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

/// 마이페이지 — 내가 등록한 평점 (조회·수정·삭제)
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);

  final RatingApiService _service;
  final TmdbMovieService _movieService;

  /// 7주차: 회원가입 결과를 보관한 LearningMemberSession.memberId
  final int memberId;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  /// 저장(수정·삭제)은 성공했지만 목록 재조회(GET)만 실패했을 때의 안내
  String? refreshWarning;

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (_disposed || version != _requestVersion) return;

      final entries = <RatingWithMovie>[];
      var missingMovies = 0;

      // 평점 응답에는 제목·포스터가 없으므로 movieId로 TMDB 영화와 연결합니다.
      // 같은 movieId는 캐시를 사용하고, 영화 조회 실패가 평점 목록을 지우지 않습니다.
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] =
                await _movieService.findMovieById(rating.movieId);
          } on DioException {
            // 일시적 네트워크 실패는 캐시하지 않습니다. 다음 로딩에서 재시도합니다.
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }

      if (_disposed || version != _requestVersion) return;
      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      refreshWarning = null;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  /// 쓰기 성공 뒤 목록을 다시 읽습니다. GET 실패는 저장 실패로 다시 던지지 않습니다.
  Future<void> _refreshAfterWrite() async {
    await load();
    if (_disposed) return;
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      notifyListeners();
    } else {
      refreshWarning = null;
    }
  }

  /// PATCH: score는 항상 보내고, comment도 유지/삭제 의도를 명확히 보냅니다.
  /// 쓰기 실패일 때만 RatingActionException을 던져 Dialog가 실패로 처리합니다.
  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    try {
      await _service.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        request: UpdateRatingRequest(score: score, comment: comment),
      );
    } on DioException catch (error) {
      if (_disposed) rethrow;
      final errorMessage = writeErrorMessage(error);
      // 403(본인 평점 아님)·404(평점 없음)는 목록이 서버와 어긋났으므로 다시 조회합니다.
      if (shouldRefreshAfterRatingError(error)) await load();
      throw RatingActionException(errorMessage);
    }
    if (_disposed) return;
    await _refreshAfterWrite();
  }

  /// DELETE: 204는 body가 없으므로 파싱하지 않습니다.
  Future<void> deleteRating(int ratingId) async {
    try {
      await _service.deleteRating(memberId: memberId, ratingId: ratingId);
    } on DioException catch (error) {
      if (_disposed) rethrow;
      final errorMessage = writeErrorMessage(error);
      if (shouldRefreshAfterRatingError(error)) await load();
      throw RatingActionException(errorMessage);
    }
    if (_disposed) return;
    await _refreshAfterWrite(); // 마지막 항목이면 empty 상태가 됩니다.
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
