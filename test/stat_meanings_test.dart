import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/game_engine.dart';
import 'package:life_8_billion/screens/game_screen.dart';

Widget wrap(GameScreen screen) {
  return MaterialApp(
    locale: const Locale('ar'),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: screen,
    ),
  );
}

void main() {
  testWidgets('واجهة اللعب: الضغط على إحصاءة يشرح معناها وأثرها',
      (tester) async {
    final engine = GameEngine()..newLife();
    await tester.pumpWidget(wrap(GameScreen(
      engine: engine,
      onNewLife: () {},
      onFinish: () {},
    )));
    await tester.pumpAndSettle();
    expect(find.text('📊 إحصاءاتك'), findsOneWidget);
    expect(
        find.text('اضغط أي إحصاءة لتعرف معناها وأثرها على حياتك.'),
        findsOneWidget);
    final health = find.text('الصحة');
    expect(health, findsOneWidget);
    await tester.ensureVisible(health);
    await tester.pumpAndSettle();
    await tester.tap(health);
    await tester.pumpAndSettle();
    expect(find.textContaining('عافيتك الجسدية'), findsOneWidget);
    expect(find.textContaining('طول عمرك المتوقع'), findsOneWidget);
  });
}
