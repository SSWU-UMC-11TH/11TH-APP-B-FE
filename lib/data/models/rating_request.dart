/// 서버 평점은 1~5 사이 정수만 허용합니다. 위젯이 정수로 막아도 남겨 두는 안전장치입니다.
int validateServerScore(double value) {
  if (value < 1 || value > 5 || value != value.roundToDouble()) {
    throw ArgumentError('서버 평점은 1~5 사이 정수여야 합니다.');
  }
  return value.toInt();
}

/// 평점 등록 요청. movieId는 배열 index가 아니라 5주차 TmdbMovieDto.id입니다.
class CreateRatingRequest {
  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  final int movieId;
  final int score;
  final String? comment;

  Map<String, dynamic> toJson() => {
    'movieId': movieId,
    'score': score,
    // 등록 comment는 선택 항목이라 비어 있으면 아예 넣지 않습니다.
    if (comment != null && comment!.trim().isNotEmpty)
      'comment': comment!.trim(),
  };
}
