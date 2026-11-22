import 'package:flutter/foundation.dart';

import '../data/models/rating_dto.dart';

/// 현재 로그인 세션에서 등록한 평점을 메모리에 보관합니다.
///
/// v7 로그인·내 정보 응답에는 memberId가 없고 토큰 기반 "내 평점 목록 GET"도 없어서,
/// 등록 response로 받은 Rating을 현재 세션에서만 수정·삭제합니다.
/// 세션(sessionVersion)이 바뀌면 이전 세션의 평점은 보이지 않습니다.
/// 앱 재시작 뒤 기존 평점 전체 복원은 API 계약 확인 전까지 지원하지 않습니다.
class SessionRatingStore extends ChangeNotifier {
  int _sessionVersion = -1;
  final List<RatingDto> _ratings = [];

  void _syncSession(int sessionVersion) {
    if (_sessionVersion == sessionVersion) return;
    _sessionVersion = sessionVersion;
    _ratings.clear();
  }

  /// 해당 세션의 평점 (최근 등록 순)
  List<RatingDto> ratingsFor(int sessionVersion) {
    if (_sessionVersion != sessionVersion) return const [];
    return List.unmodifiable(_ratings);
  }

  /// 등록·수정 result의 Rating 객체로 같은 ratingId 카드를 교체하거나 새로 추가합니다.
  void upsert(int sessionVersion, RatingDto rating) {
    _syncSession(sessionVersion);
    final index = _ratings.indexWhere((r) => r.ratingId == rating.ratingId);
    if (index >= 0) {
      _ratings[index] = rating;
    } else {
      _ratings.insert(0, rating);
    }
    notifyListeners();
  }

  void remove(int sessionVersion, int ratingId) {
    if (_sessionVersion != sessionVersion) return;
    _ratings.removeWhere((r) => r.ratingId == ratingId);
    notifyListeners();
  }
}
