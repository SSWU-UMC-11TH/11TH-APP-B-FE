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

  // 비동기 요청 및 ViewModel 생명주기 관리
  int _requestVersion = 0;
  bool _disposed = false;

  Future<void> loadPopular() async {
    // 이미 종료된 ViewModel에서는 요청하지 않음
    if (_disposed) return;

    // 가장 최근 요청을 구분하기 위한 버전
    final version = ++_requestVersion;

    status = MovieHomeLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final page = await _service.fetchPopular();

      // 화면이 종료됐거나 이전 요청이면 결과 무시
      if (_disposed || version != _requestVersion) return;

      // Popular 결과에서 최대 5개만 추출
      popularMovies = page.results.take(5).toList();

      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } on DioException {
      // 종료된 화면이나 오래된 요청의 오류는 무시
      if (_disposed || version != _requestVersion) return;

      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    } catch (error) {
      if (_disposed || version != _requestVersion) return;

      status = MovieHomeLoadStatus.error;
      message = '영화 데이터를 처리하는 중 문제가 발생했어요.';

      debugPrint(
        '[MovieHomeViewModel 오류] ${error.runtimeType}',
      );
    }

    // 유효한 최신 요청만 UI에 반영
    if (!_disposed && version == _requestVersion) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    // 진행 중인 요청의 응답을 무효화
    _requestVersion++;

    super.dispose();
  }
}
