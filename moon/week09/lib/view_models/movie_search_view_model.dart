import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import 'load_phase.dart';

class MovieSearchViewModel extends ChangeNotifier {
  MovieSearchViewModel(this._service);

  final TmdbMovieService _service;

  LoadPhase phase = LoadPhase.idle;
  List<TmdbMovieDto> movies = const [];

  String query = '';
  String? errorMessage;

  int _requestVersion = 0;
  bool _disposed = false;

  Future<void> search(String keyword) async {
    final trimmed = keyword.trim();
    final version = ++_requestVersion;

    query = trimmed;
    movies = const [];
    errorMessage = null;

    if (trimmed.isEmpty) {
      phase = LoadPhase.idle;
      _notify();
      return;
    }

    phase = LoadPhase.loading;
    _notify();

    try {
      final page = await _service.searchMovies(query: trimmed, page: 1);

      if (!_isCurrent(version)) return;

      movies = page.results;
      phase = movies.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (error) {
      if (!_isCurrent(version)) return;

      phase = LoadPhase.error;
      errorMessage = '영화를 검색하지 못했습니다.';
      debugPrint('[영화 검색 오류] ${error.runtimeType}');
    }

    _notify();
  }

  Future<void> retry() => search(query);

  bool _isCurrent(int version) {
    return !_disposed && version == _requestVersion;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
