import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/movie_log_app.dart';

void main() {
  testWidgets('MovieLogApp 로딩 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 실행합니다.
    await tester.pumpWidget(const MovieLogApp());

    // MovieLogApp이 에러 없이 정상적으로 로드되었는지 확인합니다.
    expect(find.byType(MovieLogApp), findsOneWidget);
  });
}