import 'package:flutter/foundation.dart';

/// 회원가입 결과의 memberId를 보관하는 학습용 현재 회원 상태입니다.
/// 메모리에만 있으므로 앱을 재시작하면 사라집니다. memberId를 안다고 인증된 것은 아닙니다.
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
