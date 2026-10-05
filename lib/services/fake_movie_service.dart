import 'dart:async';
import '../models/movie.dart';

class FakeMovieService {
  Future<List<Movie>> fetchMovies({
    required String selectedGenre,
    bool forceError = false,
    bool forceEmpty = false,
  }) async {
    // 800ms 이상 지연  (1초 지연)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (forceError) {
      throw Exception('영화 목록을 불러오는 중 오류가 발생했습니다.');
    }

    if (forceEmpty) {
      return [];
    }

    // 3주차 Mock 데이터 재사용 및 필터링
    final List<Movie> allMovies = [
      Movie(title: '별빛 아래 우리', rating: 4.8, year: 2023, genre: '드라마', posterUrl: '...'),
      Movie(title: '우주의 끝에서', rating: 4.2, year: 2024, genre: 'SF', posterUrl: '...'),
      Movie(title: '기억의 숲', rating: 4.9, year: 2022, genre: '애니메이션', posterUrl: '...'),
      Movie(title: '밤의 그림자', rating: 3.8, year: 2024, genre: '스릴러', posterUrl: '...'),
      Movie(title: '봄날의 커피', rating: 4.5, year: 2021, genre: '로맨스', posterUrl: '...'),
      Movie(title: '도시의 선', rating: 4.1, year: 2023, genre: '다큐멘터리', posterUrl: '...'),
    ];

    if (selectedGenre == '전체') {
      return allMovies;
    }

    return allMovies.where((m) => m.genre == selectedGenre).toList();
  }
}