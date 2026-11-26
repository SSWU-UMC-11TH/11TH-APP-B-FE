import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/models/tmdb_movie_page.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, success, empty, error }

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> popularMovies = const [];
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;

  Map<int, String> _genreNameById = const {};
  bool _disposed = false;

  Future<void> loadPopular() async {
    if (status == MovieHomeLoadStatus.loading) return; // 중복 요청 방지

    status = MovieHomeLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _service.fetchPopular(),
        _service.fetchGenres(),
      ]);
      final page = results[0] as TmdbMoviePageDto;
      final genres = results[1] as List<TmdbGenreDto>;

      // "인기 5개"는 화면 정책이라 Service가 아니라 여기서 자른다.
      // 5개보다 적게 와도 take는 있는 만큼만 돌려준다.
      popularMovies = page.results.take(5).toList();
      _genreNameById = {for (final genre in genres) genre.id: genre.name};

      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } on DioException {
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    } catch (_) {
      status = MovieHomeLoadStatus.error;
      message = '영화 정보를 읽는 중 문제가 생겼어요.';
    }

    if (!_disposed) notifyListeners();
  }

  /// TMDB genre_ids를 장르 이름 목록으로 바꾼다.
  List<String> genreNamesOf(TmdbMovieDto movie) {
    return movie.genreIds
        .map((id) => _genreNameById[id])
        .whereType<String>()
        .toList();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
