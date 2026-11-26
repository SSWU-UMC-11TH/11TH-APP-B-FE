import 'package:flutter/foundation.dart';

import '../core/session/session_guard.dart';
import '../core/utils/safe_notify.dart';
import '../data/models/favorite_response_dto.dart';
import '../data/services/favorite_api_service.dart';
import 'load_phase.dart';

class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
  });

  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteResponseDto> favorites = [];
  String? errorMessage;

  int _requestId = 0;

  bool get isLoading => phase == LoadPhase.loading;

  Future<void> loadFavorites() async {
    final generation = sessionGuard.generation;
    if (!sessionGuard.isCurrent(generation, accountId) || isDisposed) {
      return;
    }

    final requestId = ++_requestId;

    phase = LoadPhase.loading;
    errorMessage = null;
    notifyIfAlive();

    try {
      final result = await favoriteApi.fetchMyFavorites();

      if (!_isValid(generation, requestId)) return;

      favorites = result;
      phase = result.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (_) {
      if (!_isValid(generation, requestId)) return;

      favorites = [];
      phase = LoadPhase.error;
      errorMessage = '즐겨찾기를 불러오지 못했습니다.';
    }

    if (_isValid(generation, requestId)) {
      notifyIfAlive();
    }
  }

  Future<void> retry() => loadFavorites();

  bool _isValid(int generation, int requestId) {
    return !isDisposed &&
        _requestId == requestId &&
        sessionGuard.isCurrent(generation, accountId);
  }
}
