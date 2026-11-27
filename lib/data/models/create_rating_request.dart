/// 평점 저장 요청. movieId에는 배열 index가 아니라 TMDB 영화 id를 그대로 넣는다.
/// (자체 API 연동 때 Swagger 스펙에 맞춰 필드 이름을 맞춘다.)
class CreateRatingRequest {
  const CreateRatingRequest({required this.movieId, required this.score});

  final int movieId;
  final double score;

  Map<String, dynamic> toJson() => {'movieId': movieId, 'score': score};
}
