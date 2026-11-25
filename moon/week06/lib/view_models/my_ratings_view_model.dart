import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._ratingService, this._tmdbService);

  final RatingApiService _ratingService;
  final TmdbMovieService _tmdbService;

  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  List<RatingWithMovie> ratings = [];
  String? errorMessage;

  final Map<int, TmdbMovieDto?> _movieCache = {};

  int _requestVersion = 0;
  bool _disposed = false;

  Future<TmdbMovieDto?> _loadMovie(int movieId) async {
    if (_movieCache.containsKey(movieId)) {
      return _movieCache[movieId];
    }

    try {
      final movie = await _tmdbService.fetchMovieDetail(movieId);
      _movieCache[movieId] = movie;
      return movie;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        _movieCache[movieId] = null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadRatings({int memberId = 1}) async {
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
    } catch (_) {
      if (_disposed || version != _requestVersion) return;

      status = MyRatingsLoadStatus.error;
      errorMessage = '평점 목록을 불러오지 못했습니다.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
