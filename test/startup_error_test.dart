import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/main.dart';

void main() {
  testWidgets(
      'إصلاح الانهيار: شاشة خطأ بدء التشغيل تعرض نص الخطأ وزر إعادة المحاولة',
      (tester) async {
    await tester.pumpWidget(
      const StartupErrorApp(
        error: 'خطأ تجريبي عند البدء',
        stack: 'تتبع تجريبي',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('حدث خطأ عند بدء اللعبة'), findsOneWidget);
    expect(find.text('خطأ تجريبي عند البدء'), findsOneWidget);
    expect(find.text('تتبع تجريبي'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('تقدم شهرا ⏭️'), findsNothing);
  });
}
