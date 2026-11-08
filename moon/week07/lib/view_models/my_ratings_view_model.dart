import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._ratingService, this._tmdbService, this.memberId);

  final RatingApiService _ratingService;
  final TmdbMovieService _tmdbService;
  final int memberId;

  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  List<RatingWithMovie> ratings = [];
  String? errorMessage;

  // PATCH 또는 DELETE 요청 중인지 확인
  bool isMutating = false;

  // TMDB 영화 상세 정보 캐시
  final Map<int, TmdbMovieDto?> _movieCache = {};

  // 이전 요청 응답 및 dispose 이후 상태 변경 방지
  int _requestVersion = 0;
  bool _disposed = false;

  Future<TmdbMovieDto?> _loadMovie(int movieId) async {
    if (_movieCache.containsKey(movieId)) {
      return _movieCache[movieId];
    }

    try {
      final movie = await _tmdbService.fetchMovieDetail(movieId);

      if (_disposed) return null;

      _movieCache[movieId] = movie;
      return movie;
    } on DioException catch (error) {
      if (_disposed) return null;

      if (error.response?.statusCode == 404) {
        _movieCache[movieId] = null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 평점 목록 조회 GET
  Future<void> loadRatings() async {
    if (_disposed) return;

    final version = ++_requestVersion;

    status = MyRatingsLoadStatus.loading;
    errorMessage = null;
    ratings = [];
    notifyListeners();

    try {
      final ratingList = await _ratingService.getMemberRatings(memberId);

      if (_disposed || version != _requestVersion) return;

      if (ratingList.isEmpty) {
        status = MyRatingsLoadStatus.empty;
        notifyListeners();
        return;
      }

      final results = await Future.wait(
        ratingList.map((rating) async {
          final movie = await _loadMovie(rating.movieId);

          return RatingWithMovie(rating: rating, movie: movie);
        }),
      );

      if (_disposed || version != _requestVersion) return;

      ratings = results;
      status = MyRatingsLoadStatus.success;
      notifyListeners();
    } catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MyRatingsLoadStatus.error;
      errorMessage = '평점 목록을 불러오지 못했습니다.';

      debugPrint('[평점 조회 오류] ${error.runtimeType}');
      notifyListeners();
    }
  }

  // 평점 수정 PATCH
  Future<bool> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    if (_disposed || isMutating) {
      throw StateError('이미 평점 요청을 처리 중입니다.');
    }

    isMutating = true;
    notifyListeners();

    try {
      await _ratingService.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        score: score,
        comment: comment,
      );

      debugPrint('[평점 수정 성공] ratingId=$ratingId');

      if (_disposed) return false;

      // PATCH 성공 후 GET으로 최신 목록 재조회
      await loadRatings();

      // false는 수정 실패가 아니라 재조회 실패를 의미
      return status == MyRatingsLoadStatus.success ||
          status == MyRatingsLoadStatus.empty;
    } finally {
      if (!_disposed) {
        isMutating = false;
        notifyListeners();
      }
    }
  }

  // 평점 삭제 DELETE
  Future<bool> deleteRating(int ratingId) async {
    if (_disposed || isMutating) {
      throw StateError('이미 평점 요청을 처리 중입니다.');
    }

    isMutating = true;
    notifyListeners();

    try {
      await _ratingService.deleteRating(memberId: memberId, ratingId: ratingId);

      debugPrint('[평점 삭제 성공] ratingId=$ratingId');

      if (_disposed) return false;

      // DELETE 성공 후 GET으로 최신 목록 재조회
      await loadRatings();

      // false는 삭제 실패가 아니라 재조회 실패를 의미
      return status == MyRatingsLoadStatus.success ||
          status == MyRatingsLoadStatus.empty;
    } finally {
      if (!_disposed) {
        isMutating = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
