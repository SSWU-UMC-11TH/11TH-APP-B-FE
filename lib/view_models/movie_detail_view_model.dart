import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'session_rating_store.dart';
import 'submit_status.dart';

export 'submit_status.dart';

/// 영화 상세 화면: 현재 영화 DTO와 평점 "등록" 상태만 관리합니다.
/// 8주차: memberId 없이 토큰(Authorization 헤더)만으로 등록합니다.
class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._auth,
    this._ratingStore,
    this.movie,
  );

  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final SessionRatingStore _ratingStore;
  final TmdbMovieDto movie;

  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async {
    if (submitStatus == SubmitStatus.submitting) return;
    final version = _auth.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      final rating = await _ratingService.createRating(
        CreateRatingRequest(
          movieId: movie.id, // TMDB 영화 ID. body에 memberId를 넣지 않습니다.
          score: score,
          comment: comment,
        ),
      );
      // 로그아웃·회원 전환 뒤 늦게 도착한 응답은 반영하지 않습니다.
      if (_disposed || version != _auth.sessionVersion) return;
      // 등록 result의 Rating 객체를 현재 세션 평점에 보관합니다.
      _ratingStore.upsert(version, rating);
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed || version != _auth.sessionVersion) return;
      submitStatus = SubmitStatus.error;
      submitMessage = writeRatingErrorMessage(error);
      if (isSessionExpiredCode(apiErrorCode(error))) {
        // 401: 세션 정리 → Router가 /login으로 이동, 로그인 화면이 만료 Snackbar 표시
        await _auth.expireSession();
        return;
      }
      // 403·409·400은 안내만 하고 로그인 상태를 유지합니다.
    } on StateError catch (error) {
      if (_disposed || version != _auth.sessionVersion) return;
      submitStatus = SubmitStatus.error;
      submitMessage = error.message;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
