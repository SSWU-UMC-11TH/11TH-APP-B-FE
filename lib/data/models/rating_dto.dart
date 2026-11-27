class RatingDto {
  const RatingDto({
    required this.ratingId,
    required this.movieId,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  final int ratingId;

  /// TMDB 영화 ID (5주차 TmdbMovieDto.id)
  final int movieId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    return RatingDto(
      ratingId: ((json['ratingId'] ?? json['id']) as num).toInt(),
      movieId: (json['movieId'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      comment: json['comment'] as String?,
      // createdAt이 없거나 형식이 다르면 표시용으로 현재 시각을 씁니다.
      createdAt: rawCreatedAt is String
          ? (DateTime.tryParse(rawCreatedAt) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
