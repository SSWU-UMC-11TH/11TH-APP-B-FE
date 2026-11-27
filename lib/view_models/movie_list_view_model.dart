import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);

  static const maxMovieCount = 30;

  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId; // null이면 "전체"
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  /// 화면이 처음 만들어질 때 한 번 호출한다.
  Future<void> loadInitial() => _load();

  /// 에러 화면의 "다시 시도". 마지막으로 고른 장르 그대로 다시 요청한다.
  Future<void> retry() => _load();

  /// 장르 칩 선택. 로컬에서 거르지 않고 with_genres로 page 1부터 다시 요청한다.
  Future<void> selectGenre(int? genreId) async {
    // Required 7: Discover 요청 중에는 장르를 바꿀 수 없다.
    if (isLoading) return;
    // 이미 그 장르 결과가 떠 있으면 다시 요청하지 않는다.
    if (genreId == selectedGenreId && status == MovieListLoadStatus.success) {
      return;
    }

    selectedGenreId = genreId;
    await _load();
  }

  Future<void> _load() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      // 장르 목록은 처음 한 번만 받아 온다.
      if (genres.isEmpty) {
        final fetchedGenres = await _service.fetchGenres();
        if (_isStale(version)) return;
        genres = fetchedGenres;
        notifyListeners(); // 칩부터 먼저 보여 준다. (로딩 중이라 비활성 상태)
      }

      final result = await _fetchUpToThirtyMovies(genreId: selectedGenreId);
      if (_isStale(version)) return; // 늦게 도착한 이전 요청 결과는 버린다.

      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = selectedGenreId == null
          ? '영화를 불러오지 못했어요.'
          : '해당 장르 영화를 불러오지 못했어요.';
    } catch (_) {
      if (_isStale(version)) return;
      status = MovieListLoadStatus.error;
      message = '영화 정보를 읽는 중 문제가 생겼어요.';
    }

    notifyListeners();
  }

  /// 30개가 모이거나 더 이상 페이지가 없을 때까지 Discover를 이어서 요청한다.
  /// TMDB id를 Map의 key로 써서 페이지 사이 중복을 없앤다.
  Future<List<TmdbMovieDto>> _fetchUpToThirtyMovies({int? genreId}) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < maxMovieCount && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == maxMovieCount) break;
      }

      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }

    debugPrint(
      '[MovieList] 장르=${genreId ?? '전체'} → ${byId.length}개 수집 '
      '(요청한 페이지 ${pageNumber - 1}개)',
    );
    return byId.values.take(maxMovieCount).toList();
  }

  /// TMDB genre_ids를 장르 이름 목록으로 바꾼다.
  List<String> genreNamesOf(TmdbMovieDto movie) {
    final nameById = {for (final genre in genres) genre.id: genre.name};
    return movie.genreIds
        .map((id) => nameById[id])
        .whereType<String>()
        .toList();
  }

  bool _isStale(int version) => _disposed || version != _requestVersion;

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
