import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/goals.dart';

void main() {
  test('التحديات الشهرية تتجدد مع كتلة الأشهر', () {
    expect(monthBlock(0), 0);
    expect(monthBlock(2), 0);
    expect(monthBlock(3), 1);
    final early = monthlyChallenges(
        months: 0, health: 75, skill: 30, relationships: 50, savings: 1000);
    expect(early[1].target, 30);
    final later = monthlyChallenges(
        months: 9, health: 75, skill: 30, relationships: 50, savings: 1000);
    expect(later[1].target, 60);
  });

  test('الإنجازات والمستوى مشتقان من الأرقام فقط', () {
    final all = achievements(
      months: 14,
      health: 85,
      skill: 82,
      relationships: 75,
      savings: 6000,
      completedProjectCount: 1,
    );
    expect(all.where((g) => g.unlocked).length, greaterThan(5));
    expect(
        all
            .firstWhere((g) => g.title == 'ادخار 20000')
            .unlocked,
        isFalse);
    final points = levelPoints(
        health: 85,
        skill: 82,
        relationships: 75,
        completedProjectCount: 1,
        months: 14);
    expect(levelFromPoints(points), greaterThan(1));
  });

  testWidgets('لوحة الأهداف تعرض الخطر عند النقد السالب',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: GoalsPanel(
                months: 5,
                health: 75,
                skill: 30,
                relationships: 50,
                cash: -500,
                savings: 1000,
                completedProjectCount: 0,
                streakMonths: 3,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('لحظة خطر'), findsOneWidget);
    expect(find.byKey(const Key('goals-panel')), findsOneWidget);
  });
}
