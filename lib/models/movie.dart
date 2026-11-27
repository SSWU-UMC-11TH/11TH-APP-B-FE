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
    description:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n'
        '과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데…\n\n'
        '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.',
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
    description:
        '인류의 새로운 터전을 찾아 나선 우주비행사들이 미지의 행성에 도착합니다. 하지만 도착과 동시에 교신이 끊기고, 대원들은 이 행성이 처음부터 누군가의 신호에 이끌려 선택된 곳이었다는 사실을 알게 됩니다.\n\n'
        '고립된 우주선 안에서 식량과 산소는 줄어들고, 서로를 향한 의심은 점점 커져 갑니다. 돌아갈 수 있는 유일한 방법은 신호의 정체를 밝혀내는 것뿐입니다.\n\n'
        '광활한 우주의 정적과 압도적인 영상미 속에서, 인간이 어디까지 나아갈 수 있는지를 묻는 SF 어드벤처.',
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
    description:
        '신비로운 숲속 마을에서 자란 소녀는 어느 날 나무들이 속삭이는 소리를 듣게 됩니다. 소리를 따라 숲 깊은 곳으로 들어간 소녀는 오래전 사라진 숲의 수호자와 마주합니다.\n\n'
        '숲이 점점 시들어 가는 이유를 찾기 위해 소녀는 작은 정령들과 함께 모험을 떠납니다. 그 여정에서 소녀는 자연과 연결되어 있다는 것의 의미를 배워 갑니다.\n\n'
        '손으로 그린 듯한 따뜻한 화면과 포근한 음악이 어우러진, 온 가족이 함께 볼 수 있는 힐링 애니메이션.',
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
    description:
        '도심에서 연이어 일어나는 의문의 사건을 추적하던 형사는 모든 사건의 현장에서 같은 그림자가 목격되었다는 사실을 알게 됩니다. 단서를 쫓을수록 사건은 형사 자신의 과거와 연결되어 있음이 드러납니다.\n\n'
        '믿었던 동료마저 의심해야 하는 상황에서 형사는 진실에 한 걸음씩 다가갑니다. 하지만 진실은 그가 상상한 것보다 훨씬 가까운 곳에 숨어 있었습니다.\n\n'
        '어두운 도시의 밤을 배경으로 긴장감을 끝까지 놓지 않는 서스펜스 스릴러.',
    tags: ['스릴러', '범죄', '긴장감'],
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    runtime: 108,
    rating: 4.5,
    ratingCount: 760,
    posterUrl: 'assets/images/posters/poster_fourth_afternoon.jpg',
    description:
        '작은 동네 골목에서 카페를 운영하는 주인공은 매일 오후 네 시, 같은 자리에 앉아 책을 읽는 손님이 신경 쓰입니다. 말없이 건네는 커피 한 잔으로 시작된 두 사람의 대화는 어느새 서로의 하루를 채워 갑니다.\n\n'
        '계절이 바뀌는 동안 두 사람은 말하지 못했던 이야기를 하나씩 꺼내 놓습니다. 그러던 어느 날, 손님이 더 이상 카페에 찾아오지 않게 되는데…\n\n'
        '따뜻한 햇살과 커피 향이 가득한 화면으로, 평범한 일상이 얼마나 소중한지 되새기게 하는 로맨스 영화.',
    tags: ['로맨스', '일상', '따뜻한'],
  ),
  Movie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2024,
    runtime: 92,
    rating: 4.1,
    ratingCount: 320,
    posterUrl: 'assets/images/posters/poster_city_lines.jpg',
    description:
        '하늘을 가르는 선, 건물이 만들어 내는 그림자, 그리고 그 사이를 오가는 사람들. 이 다큐멘터리는 도시를 이루는 건축물의 선과 면을 따라가며 우리가 매일 지나치는 풍경의 의미를 다시 들여다봅니다.\n\n'
        '세계 곳곳의 건축가들은 하나의 건물이 사람들의 삶과 어떻게 연결되는지를 이야기합니다. 오래된 골목과 새로 지은 고층 빌딩이 공존하는 도시의 모습은 과거와 미래를 동시에 보여 줍니다.\n\n'
        '정교한 촬영과 차분한 내레이션으로 도시의 숨은 아름다움을 보여 주는 건축 다큐멘터리.',
    tags: ['다큐멘터리', '건축', '도시'],
  ),
];

Movie? findMovieById(int id) {
  try {
    return mockMovies.firstWhere((movie) => movie.id == id);
  } catch (_) {
    return null;
  }
}
