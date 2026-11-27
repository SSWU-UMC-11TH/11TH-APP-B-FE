import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'current_rating_session.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._ratingService,
    this._tmdbService,
    this._ratingSession,
    this._auth,
  );

  final RatingApiService _ratingService;
  final TmdbMovieService _tmdbService;
  final CurrentRatingSession _ratingSession;
  final AuthViewModel _auth;

  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  List<RatingWithMovie> ratings = [];
  String? errorMessage;
  bool isMutating = false;

  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  bool _isCurrent(int requestVersion, int sessionVersion) {
    return !_disposed &&
        requestVersion == _requestVersion &&
        sessionVersion == _auth.sessionVersion &&
        _auth.status == AuthStatus.signedIn;
  }

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

  Future<void> loadRatings() async {
    if (_disposed) return;

    final requestVersion = ++_requestVersion;
    final sessionVersion = _auth.sessionVersion;

    status = MyRatingsLoadStatus.loading;
    errorMessage = null;
    ratings = [];
    notifyListeners();

    try {
      final ratingList = _ratingSession.ratings;
      if (!_isCurrent(requestVersion, sessionVersion)) return;

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

      if (!_isCurrent(requestVersion, sessionVersion)) return;

      ratings = results;
      status = MyRatingsLoadStatus.success;
      notifyListeners();
    } catch (_) {
      if (!_isCurrent(requestVersion, sessionVersion)) return;
      status = MyRatingsLoadStatus.error;
      errorMessage = '평점 목록을 불러오지 못했습니다.';
      notifyListeners();
    }
  }

  Future<bool> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    if (_disposed || isMutating) {
      throw StateError('이미 평점 요청을 처리 중입니다.');
    }
    if (_auth.status != AuthStatus.signedIn) return false;

    final sessionVersion = _auth.sessionVersion;
    isMutating = true;
    notifyListeners();

    try {
      final updated = await _ratingService.updateRatingV7(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );

      if (_disposed ||
          sessionVersion != _auth.sessionVersion ||
          _auth.status != AuthStatus.signedIn) {
        return false;
      }

      _ratingSession.saveRating(updated);
      await loadRatings();
      return status == MyRatingsLoadStatus.success ||
          status == MyRatingsLoadStatus.empty;
    } on DioException catch (error) {
      if (!_disposed && sessionVersion == _auth.sessionVersion) {
        final code = apiErrorCode(error);
        if (code == 'AUTH401_2' ||
            code == 'AUTH401_3' ||
            code == 'AUTH401_4') {
          await _auth.expireSession();
        }
      }
      rethrow;
    } finally {
      if (!_disposed) {
        isMutating = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deleteRating(int ratingId) async {
    if (_disposed || isMutating) {
      throw StateError('이미 평점 요청을 처리 중입니다.');
    }
    if (_auth.status != AuthStatus.signedIn) return false;

    final sessionVersion = _auth.sessionVersion;
    isMutating = true;
    notifyListeners();

    try {
      await _ratingService.deleteRatingV7(ratingId);

      if (_disposed ||
          sessionVersion != _auth.sessionVersion ||
          _auth.status != AuthStatus.signedIn) {
        return false;
      }

      _ratingSession.removeRating(ratingId);
      await loadRatings();
      return status == MyRatingsLoadStatus.success ||
          status == MyRatingsLoadStatus.empty;
    } on DioException catch (error) {
      if (!_disposed && sessionVersion == _auth.sessionVersion) {
        final code = apiErrorCode(error);
        if (code == 'AUTH401_2' ||
            code == 'AUTH401_3' ||
            code == 'AUTH401_4') {
          await _auth.expireSession();
        }
      }
      rethrow;
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
