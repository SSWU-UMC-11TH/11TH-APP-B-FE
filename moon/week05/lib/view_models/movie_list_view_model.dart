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

  bool _isInvalidRequest(int version) =>
      _disposed || version != _requestVersion;

  // Discover API를 반복 호출하여 최대 30개 수집
  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({
    int? genreId,
    int? requestVersion,
  }) async {
    final byId = <int, TmdbMovieDto>{};

    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      // 화면 종료나 새 요청 발생 시 불필요한 추가 호출 방지
      if (_disposed ||
          (requestVersion != null &&
              requestVersion != _requestVersion)) {
        return byId.values.take(30).toList();
      }

      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      if (_disposed ||
          (requestVersion != null &&
              requestVersion != _requestVersion)) {
        return byId.values.take(30).toList();
      }

      // TMDB 영화 ID 기준 중복 제거
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

  // 장르 목록 요청 (실패해도 영화 조회에 영향 없음)
  Future<void> _loadGenres(int version) async {
    try {
      final result = await _service.fetchGenres();

      if (_isInvalidRequest(version)) return;

      genres = result;
    } on DioException {
      if (_isInvalidRequest(version)) return;

      debugPrint('[MovieList] 장르 API 요청 실패');
    } catch (error) {
      if (_isInvalidRequest(version)) return;

      debugPrint(
        '[MovieList] 장르 데이터 처리 오류: ${error.runtimeType}',
      );
    }
  }

  // 첫 화면 진입 시 장르와 영화 목록 조회
  Future<void> loadInitial() async {
    if (_disposed) return;

    final version = ++_requestVersion;

    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    // 장르 실패와 무관하게 영화 목록 조회
    await _loadGenres(version);

    if (_isInvalidRequest(version)) return;

    try {
      final result = await fetchUpToThirtyMovies(
        genreId: selectedGenreId,
        requestVersion: version,
      );

      if (_isInvalidRequest(version)) return;

      movies = result;

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_isInvalidRequest(version)) return;

      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    } catch (error) {
      if (_isInvalidRequest(version)) return;

      status = MovieListLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';

      debugPrint(
        '[MovieListViewModel 오류] ${error.runtimeType}',
      );
    }

    if (!_isInvalidRequest(version)) {
      notifyListeners();
    }
  }

  // 장르 선택 시 Discover API 재조회
  Future<void> selectGenre(int? genreId) async {
    if (isLoading || _disposed) return;

    selectedGenreId = genreId;

    final version = ++_requestVersion;

    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(
        genreId: genreId,
        requestVersion: version,
      );

      if (_isInvalidRequest(version)) return;

      movies = result;

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_isInvalidRequest(version)) return;

      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
    } catch (error) {
      if (_isInvalidRequest(version)) return;

      status = MovieListLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';

      debugPrint(
        '[MovieListViewModel 오류] ${error.runtimeType}',
      );
    }

    if (!_isInvalidRequest(version)) {
      notifyListeners();
    }
  }

  // 마지막 선택 장르 기준 재시도
  Future<void> retry() async {
    if (isLoading || _disposed) return;

    // 장르 목록이 없으면 다시 조회를 시도하되,
    // 실패하더라도 영화 목록은 조회함
    if (genres.isEmpty) {
      await loadInitial();
      return;
    }

    final version = ++_requestVersion;

    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(
        genreId: selectedGenreId,
        requestVersion: version,
      );

      if (_isInvalidRequest(version)) return;

      movies = result;

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_isInvalidRequest(version)) return;

      status = MovieListLoadStatus.error;
      message = '영화를 다시 불러오지 못했어요.';
    } catch (error) {
      if (_isInvalidRequest(version)) return;

      status = MovieListLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';

      debugPrint(
        '[MovieList 재시도 오류] ${error.runtimeType}',
      );
    }

    if (!_isInvalidRequest(version)) {
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
