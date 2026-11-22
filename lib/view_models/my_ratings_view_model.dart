import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'session_rating_store.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

/// 마이페이지 — 내가 등록한 평점 (8주차: 토큰 기반 수정·삭제)
///
/// v7에는 토큰 기반 "내 평점 목록 GET"이 없고 로그인 응답에 memberId도 없으므로,
/// 현재 세션에서 등록한 Rating(SessionRatingStore)을 보여주고 v7 PATCH/DELETE로 변경합니다.
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._ratingStore,
    this._auth,
  );

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final SessionRatingStore _ratingStore;
  final AuthViewModel _auth;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  Future<void> load() async {
    if (_disposed) return;
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    final rawRatings = _ratingStore.ratingsFor(_auth.sessionVersion);
    final entries = <RatingWithMovie>[];
    var missingMovies = 0;

    // 평점 응답에는 제목·포스터가 없으므로 movieId(TMDB id)로 TMDB 영화와 연결합니다.
    // 영화 조회에 실패해도 평점 자체는 지우지 않고 "영화 #id" placeholder로 보여줍니다.
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
    status =
        entries.isEmpty ? MyRatingsLoadStatus.empty : MyRatingsLoadStatus.success;
    if (missingMovies > 0) {
      message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
    }
    notifyListeners();
  }

  /// 쓰기 실패를 code별로 처리하고 Dialog에 보여줄 예외로 바꿉니다.
  Future<Never> _handleWriteError(
    DioException error,
    int ratingId,
    int sessionVersion,
  ) async {
    final code = apiErrorCode(error);
    final errorMessage = writeRatingErrorMessage(error);
    if (isSessionExpiredCode(code)) {
      // 401: 세션 정리 → Router가 /login으로 이동 (로그인 화면이 만료 Snackbar 표시)
      await _auth.expireSession();
    } else if (code == 'RATING404_1') {
      // 이미 없는 평점: 목록에서 빼고 새로고침합니다.
      _ratingStore.remove(sessionVersion, ratingId);
      if (!_disposed) await load();
    }
    // RATING403_1·COMMON400 등은 안내만 하고 로그아웃하지 않습니다.
    throw RatingActionException(errorMessage);
  }

  /// PATCH /v7/ratings/{ratingId}: score·comment를 함께 보내고, result Rating으로 카드를 갱신합니다.
  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final sessionVersion = _auth.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_disposed || sessionVersion != _auth.sessionVersion) return;
      _ratingStore.upsert(sessionVersion, updated);
    } on DioException catch (error) {
      if (_disposed || sessionVersion != _auth.sessionVersion) rethrow;
      await _handleWriteError(error, ratingId, sessionVersion);
    }
    await load();
  }

  /// DELETE /v7/ratings/{ratingId}: 200 + result null
  Future<void> deleteRating(int ratingId) async {
    final sessionVersion = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (_disposed || sessionVersion != _auth.sessionVersion) return;
      _ratingStore.remove(sessionVersion, ratingId);
    } on DioException catch (error) {
      if (_disposed || sessionVersion != _auth.sessionVersion) rethrow;
      await _handleWriteError(error, ratingId, sessionVersion);
    }
    await load(); // 마지막 항목이면 empty 상태가 됩니다.
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
