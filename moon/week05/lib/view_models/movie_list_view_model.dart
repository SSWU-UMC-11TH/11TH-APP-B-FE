
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];

  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  // Discover API를 반복 호출하여 최대 30개 수집
  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({
    int? genreId,
  }) async {
    final byId = <int, TmdbMovieDto>{};

    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      // TMDB 영화 ID를 기준으로 중복 제거
      for (final movie in page.results) {
        byId.putIfAbsent(movie.id, () => movie);

        if (byId.length >= 30) {
          break;
        }
      }

      hasNextPage =
          pageNumber < page.totalPages && page.results.isNotEmpty;

      pageNumber++;
    }

    return byId.values.take(30).toList();
  }

  // 첫 화면 진입 시 장르와 영화 목록 조회
  Future<void> loadInitial() async {
    final version = ++_requestVersion;

    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      genres = await _service.fetchGenres();

      final result = await fetchUpToThirtyMovies(
        genreId: selectedGenreId,
      );

      if (_disposed || version != _requestVersion) return;

      movies = result;

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_disposed || version != _requestVersion) return;

      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    } catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MovieListLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';

      debugPrint('[MovieListViewModel 오류] ${error.runtimeType}');
    }

    if (!_disposed && version == _requestVersion) {
      notifyListeners();
    }
  }

  // 장르 선택 시 Discover API 재조회
  Future<void> selectGenre(int? genreId) async {
    // API 요청 중에는 장르 변경 방지
    if (isLoading || _disposed) return;

    selectedGenreId = genreId;

    final version = ++_requestVersion;

    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(
        genreId: genreId,
      );

      if (_disposed || version != _requestVersion) return;

      movies = result;

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_disposed || version != _requestVersion) return;

      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
    } catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MovieListLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';

      debugPrint('[MovieListViewModel 오류] ${error.runtimeType}');
    }

    if (!_disposed && version == _requestVersion) {
      notifyListeners();
    }
  }

  // 마지막으로 선택한 장르 조건으로 재시도
  Future<void> retry() async {
    if (isLoading || _disposed) return;

    // 첫 조회에서 장르 목록을 받지 못한 경우
    if (genres.isEmpty) {
      await loadInitial();
      return;
    }

    final genreId = selectedGenreId;

    final version = ++_requestVersion;

    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(
        genreId: genreId,
      );

      if (_disposed || version != _requestVersion) return;

      movies = result;

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MovieListLoadStatus.error;
      message = '영화를 다시 불러오지 못했어요.';

      debugPrint('[MovieList 재시도 오류] ${error.runtimeType}');
    }

    if (!_disposed && version == _requestVersion) {
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
