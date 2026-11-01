class Movie {
  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final String duration;
  final String synopsis;

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.duration,
    required this.synopsis,
  });
}

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/movie_1.png',
    rating: 4.8,
    duration: '120분',
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/movie_2.png',
    rating: 4.2,
    duration: '135분',
    synopsis: '우주 탐사선이 알 수 없는 시공간의 균열에 빠지면서 벌어지는 SF 스릴러.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    posterAsset: 'assets/images/movie_3.png',
    rating: 4.9,
    duration: '98분',
    synopsis: '잃어버린 기억을 찾아 신비로운 숲으로 떠나는 동화 같은 이야기.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/movie_4.png',
    rating: 3.8,
    duration: '110분',
    synopsis: '어두운 도시의 밤, 숨겨진 진실을 파헤치는 스릴러 영화.',
  ),
];

Movie? findMovieById(int id) {
  try {
    return mockMovies.firstWhere((movie) => movie.id == id);
  } catch (_) {
    return null;
  }
}
