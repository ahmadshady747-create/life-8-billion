import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/world_events.dart';

void main() {
  testWidgets('مشهد الشهر يعرض دلتا الشهر ويستدعي القرار',
      (tester) async {
    var decided = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: MonthEventScene(
                healthDelta: -2,
                skillDelta: 3,
                relationshipsDelta: 1,
                cashDelta: -400,
                streakMonths: 3,
                gymOn: false,
                socialOn: false,
                onFocusHealth: () => decided = 'health',
                onFocusRelationships: () => decided = 'relations',
                onKeepPlan: () => decided = 'keep',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('مشهد الشهر'), findsOneWidget);
    expect(find.textContaining('صحة -2'), findsOneWidget);
    expect(find.textContaining('سلسلة أشهرك'), findsOneWidget);
    expect(find.byKey(const Key('world-event-scene')), findsOneWidget);
    await tester.tap(find.textContaining('ركّز على الصحة'));
    await tester.pump();
    expect(decided, 'health');
    await tester.tap(find.textContaining('لا تغيير'));
    await tester.pump();
    expect(decided, 'keep');
  });
}
