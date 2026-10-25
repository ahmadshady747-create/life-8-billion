import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/screens/start_screen.dart';

Widget wrap(StartScreen screen) {
  return MaterialApp(
    locale: const Locale('ar'),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: screen,
    ),
  );
}

void main() {
  testWidgets('شاشة البداية: زر بدء واحد واضح وثلاث خطوات موجزة',
      (tester) async {
    await tester.pumpWidget(wrap(StartScreen(
      onStart: () {},
      livesPlayed: 0,
    )));
    expect(find.text('واحد من 8 مليارات'), findsOneWidget);
    expect(find.text('ابدأ حياة جديدة 🎲'), findsOneWidget);
    expect(find.text('تولد'), findsOneWidget);
    expect(find.text('تختار'), findsOneWidget);
    expect(find.text('تُروى قصتك'), findsOneWidget);
    // لا شرح طويل: النقاط الست القديمة غائبة.
    expect(find.textContaining('أنظمة عميقة'), findsNothing);
    expect(find.textContaining('سجل حياة كامل'), findsNothing);
  });

  testWidgets('شاشة البداية: الاستئناف زر ثانوي واضح عند وجود حفظ',
      (tester) async {
    var continued = false;
    await tester.pumpWidget(wrap(StartScreen(
      onStart: () {},
      onContinue: () => continued = true,
      savedName: 'سالم',
      savedAge: 30,
      livesPlayed: 2,
    )));
    final resume = find.text('واصل حياة سالم (عمر 30) ▶️');
    expect(resume, findsOneWidget);
    await tester.ensureVisible(resume);
    await tester.pumpAndSettle();
    await tester.tap(resume);
    expect(continued, isTrue);
    expect(find.text('عشتَ 2 حيوات حتى الآن'), findsOneWidget);
  });
}
