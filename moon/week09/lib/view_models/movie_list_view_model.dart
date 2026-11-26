import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];

  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  int nextPage = 1;
  int totalPages = 1;

  bool isLoadingMore = false;
  String? loadMoreError;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  bool get hasMore =>
      status == MovieListLoadStatus.success &&
      nextPage <= totalPages &&
      nextPage <= 500;

  bool _isCurrent(int version) {
    return !_disposed && version == _requestVersion;
  }

  // 첫 화면 진입 시 장르와 영화 1페이지 조회
  Future<void> loadInitial() async {
    if (_disposed) return;

    final version = ++_requestVersion;

    _resetMovies();
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      final fetchedGenres = await _service.fetchGenres();

      if (!_isCurrent(version)) return;

      genres = fetchedGenres;
    } catch (error) {
      if (!_isCurrent(version)) return;

      genres = const [];
      debugPrint('[장르 목록 조회 오류] ${error.runtimeType}');
    }

    await _loadFirstPage(version);
  }

  // 장르 변경 시 목록을 비우고 1페이지부터 다시 조회
  Future<void> selectGenre(int? genreId) async {
    if (_disposed) return;

    if (selectedGenreId == genreId && status == MovieListLoadStatus.success) {
      return;
    }

    selectedGenreId = genreId;

    final version = ++_requestVersion;

    _resetMovies();
    status = MovieListLoadStatus.loading;
    notifyListeners();

    await _loadFirstPage(version);
  }

  // 첫 페이지 조회 실패 시 재시도
  Future<void> retry() async {
    if (_disposed || isLoading) return;

    if (genres.isEmpty) {
      await loadInitial();
      return;
    }

    final version = ++_requestVersion;

    _resetMovies();
    status = MovieListLoadStatus.loading;
    notifyListeners();

    await _loadFirstPage(version);
  }

  Future<void> _loadFirstPage(int version) async {
    if (!_isCurrent(version)) return;

    try {
      final page = await _service.discoverMovies(
        page: 1,
        genreId: selectedGenreId,
      );

      if (!_isCurrent(version)) return;

      final uniqueMovies = <int, TmdbMovieDto>{};

      for (final movie in page.results) {
        uniqueMovies.putIfAbsent(movie.id, () => movie);
      }

      movies = uniqueMovies.values.toList();

      totalPages = page.totalPages.clamp(0, 500).toInt();
      nextPage = 2;

      if (page.results.isEmpty) {
        totalPages = 1;
        nextPage = 2;
      }

      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;

      message = null;
    } catch (error) {
      if (!_isCurrent(version)) return;

      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';

      debugPrint('[영화 첫 페이지 조회 오류] ${error.runtimeType}');
    }

    if (_isCurrent(version)) {
      notifyListeners();
    }
  }

  // 기존 목록을 유지하면서 다음 페이지 추가
  Future<void> loadMore() async {
    if (_disposed || isLoading || isLoadingMore || !hasMore) {
      return;
    }

    final version = _requestVersion;
    final requestedPage = nextPage;
    final genreId = selectedGenreId;

    isLoadingMore = true;
    loadMoreError = null;
    notifyListeners();

    try {
      final page = await _service.discoverMovies(
        page: requestedPage,
        genreId: genreId,
      );

      if (!_isCurrent(version)) return;

      final uniqueMovies = <int, TmdbMovieDto>{
        for (final movie in movies) movie.id: movie,
      };

      for (final movie in page.results) {
        uniqueMovies.putIfAbsent(movie.id, () => movie);
      }

      movies = uniqueMovies.values.toList();

      totalPages = page.totalPages.clamp(0, 500).toInt();

      // 성공한 페이지에서만 다음 페이지 번호로 이동
      nextPage = requestedPage + 1;

      // 빈 페이지가 도착하면 추가 요청 중단
      if (page.results.isEmpty) {
        totalPages = requestedPage;
      }

      loadMoreError = null;
    } catch (error) {
      if (!_isCurrent(version)) return;

      // 실패했을 때 nextPage를 변경하지 않습니다.
      // 따라서 다시 누르면 같은 페이지를 요청합니다.
      loadMoreError = '추가 영화 조회에 실패했습니다.';

      debugPrint('[영화 추가 페이지 조회 오류] ${error.runtimeType}');
    } finally {
      if (_isCurrent(version)) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  void _resetMovies() {
    movies = const [];
    nextPage = 1;
    totalPages = 1;
    message = null;
    loadMoreError = null;
    isLoadingMore = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
