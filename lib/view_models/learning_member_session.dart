import 'package:flutter/foundation.dart';

/// 회원가입으로 얻은 학습용 memberId를 앱 상단에 보관합니다.
///
/// 메모리에만 있으므로 앱을 재시작하면 사라집니다.
/// memberId를 안다는 사실은 인증이 아니며, JWT 주차에 토큰 기반으로 바뀝니다.
class LearningMemberSession extends ChangeNotifier {
  int? memberId;

  void setMemberId(int id) {
    memberId = id;
    notifyListeners();
  }

  void clear() {
    memberId = null;
    notifyListeners();
  }
}
