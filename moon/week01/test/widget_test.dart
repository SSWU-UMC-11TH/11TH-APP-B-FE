import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/main.dart';

void main() {
  testWidgets('MovieLog start screen smoke test', (WidgetTester tester) async {
    // 앱 실행
    await tester.pumpWidget(const MyApp());

    // 시작 화면의 주요 UI가 표시되는지 확인
    expect(find.text('FLUTTER 1주차'), findsOneWidget);
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(
      find.text('보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요'),
      findsOneWidget,
    );
    expect(find.text('시작하기'), findsOneWidget);
  });
}
