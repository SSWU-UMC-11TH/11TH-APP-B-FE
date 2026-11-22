/// v6 서버 평점은 1~5 사이 정수입니다.
/// 위젯이 이미 정수 단위로 막아 주더라도 남겨 두는 안전장치입니다.
int validateServerScore(double value) {
  if (value < 1 || value > 5 || value != value.roundToDouble()) {
    throw ArgumentError('서버 평점은 1~5 사이 정수여야 합니다.');
  }
  return value.toInt();
}

/// 평점 등록 요청 body (POST /v6/members/{memberId}/ratings)
class CreateRatingRequest {
  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  /// 5주차 TmdbMovieDto.id (영화 배열 index가 아닙니다)
  final int movieId;
  final int score;
  final String? comment;

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'score': score,
        if (comment != null && comment!.trim().isNotEmpty)
          'comment': comment!.trim(),
      };
}

/// 평점 수정 요청 body (PATCH /v6/members/{memberId}/ratings/{ratingId})
///
/// comment를 생략하면 서버가 기존 후기를 null로 덮으므로
/// score와 comment를 항상 명시적으로 보냅니다. (null = 코멘트 삭제 의도)
class UpdateRatingRequest {
  const UpdateRatingRequest({required this.score, required this.comment});

  final int score;
  final String? comment;

  Map<String, dynamic> toJson() => {
        'score': score,
        'comment': (comment == null || comment!.trim().isEmpty)
            ? null
            : comment!.trim(),
      };
}
