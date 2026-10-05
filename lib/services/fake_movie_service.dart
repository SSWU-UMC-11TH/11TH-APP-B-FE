import 'dart:async';
import '../models/movie.dart';

class FakeMovieService {
    Future<List<Movie>> fetchMovies({
    required String selectedGenre,
    bool forceError = false,
    bool forceEmpty = false,
  }) async {
    // 최소 800ms 이상 지연 (1초 지연)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (forceError) {
      throw Exception('영화 목록을 불러오는 중 오류가 발생했습니다.');
    }

    if (forceEmpty) {
      return [];
    }

    // movie.dart에 정의된 mockMovies를 직접 활용
    if (selectedGenre == '전체') {
      return mockMovies;
    }

    return mockMovies.where((m) => m.genre == selectedGenre).toList();
  }
}