import 'package:flutter/foundation.dart';
import '../data/models/rating_dto.dart';
import 'auth_view_model.dart';

class CurrentRatingSession extends ChangeNotifier {
  CurrentRatingSession(this._auth) {
    _sessionVersion = _auth.sessionVersion;
    _auth.addListener(_onAuthChanged);
  }

  final AuthViewModel _auth;
  final Map<int, RatingDto> _ratings = {};
  late int _sessionVersion;

  List<RatingDto> get ratings => List.unmodifiable(_ratings.values);

  bool get isEmpty => _ratings.isEmpty;

  void _onAuthChanged() {
    if (_sessionVersion != _auth.sessionVersion ||
        _auth.status == AuthStatus.signedOut) {
      _sessionVersion = _auth.sessionVersion;
      if (_ratings.isNotEmpty) {
        _ratings.clear();
        notifyListeners();
      }
    }
  }

  void saveRating(RatingDto rating) {
    if (_auth.status != AuthStatus.signedIn) return;
    _ratings[rating.ratingId] = rating;
    notifyListeners();
  }

  void removeRating(int ratingId) {
    if (_ratings.remove(ratingId) != null) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
