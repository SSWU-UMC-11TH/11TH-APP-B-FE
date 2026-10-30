import '../data/movie_data.dart';
import '../models/movie.dart';

enum MovieLoadMode {
  success,
  empty,
  failure,
}

class MovieLoadException implements Exception {
  final String message;

  const MovieLoadException(this.message);
}

// TODO: 5주차 유저별 평점 조회 API 연결 시 실제 API로 교체
class FakeMovieService {
  const FakeMovieService();


  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {

    await Future.delayed(
      const Duration(seconds: 1),
    );


    switch(mode){

      case MovieLoadMode.success:
        return mockMovies;


      case MovieLoadMode.empty:
        return [];


      case MovieLoadMode.failure:
        throw const MovieLoadException(
          '영화를 불러오지 못했습니다.',
        );
    }
  }
}