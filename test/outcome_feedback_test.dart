import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/game_engine.dart';
import 'package:life_8_billion/models.dart';
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
  test('ملخص القرار: تغيّرات فعلية بعد التقريب وتفصيل الرصيد', () {
    final engine = GameEngine()..newLife();
    engine.stats.health = 98;
    final balanceBefore = engine.balance;
    engine.applyChoice(const EventChoice(
      text: 'اختبار',
      outcome: 'نتيجة اختبار',
      effect: Effect(health: 10, happiness: -5),
      cash: 1000,
      addTraits: ['graduate'],
      ambition: 'wealth',
    ));
    final summary = engine.lastSummary;
    expect(summary, isNotNull);
    final health = summary!.statChanges
        .firstWhere((c) => c.label == 'الصحة');
    // +10 عند 98 تعني فعليا +2 فقط، والقيمة الجديدة 100 لا 108.
    expect(health.delta, 2);
    expect(health.newValue, 100);
    final happiness = summary.statChanges
        .firstWhere((c) => c.label == 'السعادة');
    expect(happiness.delta, -5);
    expect(summary.balanceAfter,
        balanceBefore + 1000 + summary.yearlyDelta);
    expect(summary.cashDelta, 1000);
    expect(summary.traitsAdded, contains('graduate'));
    expect(summary.ambitionAfter, 'wealth');
  });

  testWidgets('بطاقة النتيجة تعرض ما تغيّر والقيمة الجديدة', (tester) async {
    final engine = GameEngine()..newLife();
    await tester.pumpWidget(wrap(GameScreen(
      engine: engine,
      onNewLife: () {},
      onFinish: () {},
    )));
    await tester.pumpAndSettle();
    final birth = find.text('ابدأ رحلة الحياة 👶');
    await tester.ensureVisible(birth);
    await tester.pumpAndSettle();
    await tester.tap(birth);
    await tester.pumpAndSettle();
    final choice = find.text('أقف بينهم وبين صديقي');
    await tester.ensureVisible(choice);
    await tester.pumpAndSettle();
    await tester.tap(choice);
    await tester.pumpAndSettle();
    expect(find.text('✨ ما حدث بعد قرارك'), findsOneWidget);
    expect(find.text('ما تغيّر في إحصاءاتك:'), findsOneWidget);
    // الصحة تنقص 8 في هذا الخيار، والسمعة تزيد 8: دلتا وقيمة جديدة.
    expect(find.textContaining('الصحة: -8 →'), findsOneWidget);
    expect(find.textContaining('السمعة: +8 →'), findsOneWidget);
    // الرصيد يتغير بمصاريف السنوات الخمس حتى دون ربح مباشر.
    expect(find.textContaining('دخل ومصاريف × 5 سنوات'), findsOneWidget);
  });
}
