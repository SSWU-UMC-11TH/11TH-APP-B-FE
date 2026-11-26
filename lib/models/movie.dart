class Movie {
  final int id;
  final String title;
  final String genre;
  final int year;
  final int runtime;
  final double rating;
  final int ratingCount;
  final String posterUrl;
  final String description;
  final List<String> tags;

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.runtime,
    required this.rating,
    required this.ratingCount,
    required this.posterUrl,
    required this.description,
    required this.tags,
  });
}

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    runtime: 124,
    rating: 4.5,
    ratingCount: 1245,
    posterUrl: 'assets/images/posters/hero_under_the_starlight.jpg',
    description: '밤하늘 아래 펼쳐지는 두 남녀의 스릴 있고 감동적인 러브 스토리.',
    tags: ['로맨스', '드라마', '감동적인'],
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    runtime: 135,
    rating: 4.2,
    ratingCount: 890,
    posterUrl: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    description: '인류의 새로운 터전을 찾아 나선 우주비행사들의 미지의 여정.',
    tags: ['SF', '모험', '우주'],
  ),
  Movie(
    id: 3,
    title: 'Whispering Woods',
    genre: '애니메이션',
    year: 2023,
    runtime: 98,
    rating: 4.9,
    ratingCount: 2100,
    posterUrl: 'assets/images/posters/poster_whispering_woods.jpg',
    description: '신비로운 숲속 동화 같은 이야기와 아름다운 모험.',
    tags: ['애니메이션', '판타지', '힐링'],
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    runtime: 115,
    rating: 3.8,
    ratingCount: 540,
    posterUrl: 'assets/images/posters/poster_night_shadows.jpg',
    description: '도심 속에서 일어나는 의문의 사건을 추적하는 서스펜스 스릴러.',
    tags: ['스릴러', '범죄', '긴장감'],
  ),
];

Movie? findMovieById(int id) {
  try {
    return mockMovies.firstWhere((movie) => movie.id == id);
  } catch (_) {
    return null;
  }
}
