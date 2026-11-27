import '../data/models/tmdb_movie_dto.dart';

/// 상세 화면으로 이동할 때 go_router의 extra에 담는 값.
/// 경로 /movies/:movieId 에는 TMDB id가 들어가고,
/// 화면에 그릴 영화 데이터와 장르 이름은 이걸로 넘긴다.
class MovieDetailArgs {
  const MovieDetailArgs({required this.movie, this.genreNames = const []});

  final TmdbMovieDto movie;
  final List<String> genreNames;
}
