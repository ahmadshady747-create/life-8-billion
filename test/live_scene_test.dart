import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/live_scene.dart';

void main() {
  test('نسب مشهد الحياة مشتقة من الأرقام الحقيقية فقط', () {
    expect(statFraction(0), 0);
    expect(statFraction(100), 1);
    expect(statFraction(75), 0.75);
    expect(neighbourFaces(0), 0);
    expect(neighbourFaces(50), 2);
    expect(neighbourFaces(100), 5);
    expect(healthColor(80), Colors.green);
    expect(healthColor(50), Colors.orange);
    expect(healthColor(20), Colors.red);
  });

  testWidgets('مشهد الحياة يعرض الصحة والعلاقات',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: LifeLiveScene(
                health: 75,
                skill: 30,
                relationships: 50,
                cash: 5000,
                savings: 1000,
                ageYears: 18,
                months: 0,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('مشهد حياتك الحي'), findsOneWidget);
    expect(find.textContaining('الصحة: 75'), findsOneWidget);
    expect(find.textContaining('العلاقات: 50'), findsOneWidget);
    expect(find.byKey(const Key('live-scene')), findsOneWidget);
  });
}
