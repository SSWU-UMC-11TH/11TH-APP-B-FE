import '../models/movie.dart';

const List<Movie> mockMovies = [
  Movie(
  id: 1,
  title: '별빛 아래 우리',
  year: 2024,
  genres: ['로맨스', '드라마'],
  rating: 4.5,
  ratingCount: 1245,
  duration: 124,
  imagePath: 'assets/images/posters/hero_under_the_starlight.jpg',
  synopsis: '''바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.

과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...

별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.''',
),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    year: 2024,
    genres: ['SF'],
    rating: 4.2,
    ratingCount: 756,
    duration: 131,
    imagePath: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    synopsis:
        '미지의 행성을 탐사하던 우주비행사가 광활한 우주 속에서 자신과 인류의 존재에 대한 새로운 진실을 마주합니다.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    year: 2022,
    genres: ['애니메이션'],
    rating: 4.9,
    ratingCount: 892,
    duration: 108,
    imagePath: 'assets/images/posters/poster_whispering_woods.jpg',
    synopsis:
        '과거에 꿨던 꿈에서의 추억이 사실 실존하는 공간이었다니, 기억의 숲에 들어가 다시 한번 친구들을 만납니다..',
  ),
  
  Movie(
    id: 4,
    title: '밤의 그림자',
    year: 2024,
    genres: ['스릴러'],
    rating: 3.8,
    ratingCount: 623,
    duration: 116,
    imagePath: 'assets/images/posters/poster_night_shadows.jpg',
    synopsis:
        '어느날부턴가 밤마다 실종되는 사람들, 그들은 모두 연쇄살인마였다.'),
  Movie(
    id: 5,
    title: '봄날의 커피',
    year: 2021,
    genres: ['로맨스'],
    rating: 4.5,
    ratingCount: 514,
    duration: 112,
    imagePath: 'assets/images/posters/poster_fourth_afternoon.jpg',
    synopsis:
        '평범한 오후의 카페에서 우연히 만난 두 사람이 서로의 일상에 조금씩 스며들며 만들어가는 로맨스입니다.',
  ),
  Movie(
    id: 6,
    title: '스파이 코드',
    year: 2024,
    genres: ['액션'],
    rating: 4.6,
    ratingCount: 1032,
    duration: 128,
    imagePath: 'assets/images/posters/poster_abyss_walker.jpg',
    synopsis:
        '도시를 위협하는 거대한 사건 속에서 주인공이 위험천만한 임무에 뛰어드는 액션 어드벤처입니다.',
  ),
];