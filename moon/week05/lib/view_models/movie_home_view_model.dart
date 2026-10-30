
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

// 홈 화면의 데이터 로딩 상태
enum MovieHomeLoadStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> popularMovies = const [];
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;

  Future<void> loadPopular() async {
    status = MovieHomeLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final page = await _service.fetchPopular();

      // Popular 결과에서 최대 5개만 추출
      popularMovies = page.results.take(5).toList();

      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } on DioException {
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    } catch (error) {
      status = MovieHomeLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';
      debugPrint('[MovieHomeViewModel 오류] ${error.runtimeType}');
    }

    notifyListeners();
  }
}
