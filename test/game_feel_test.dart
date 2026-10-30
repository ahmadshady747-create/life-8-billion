import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/game_feel.dart';
import 'package:life_8_billion/screens/life_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('المرحلة 1: العدّاد المتحرك يستقر على القيمة الحقيقية',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCountText(prefix: 'النقد: ', value: 42),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('النقد: 42'), findsOneWidget);
  });

  testWidgets('المرحلة 1: الشريط المتحرك يستقر على الكسر الحقيقي',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBar(label: 'الصحة', fraction: 0.5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bar =
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, 0.5);
  });

  testWidgets('المرحلة 1: زر كتم الصوت موجود ويتبدل', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: LifeManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pump();
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
  });
}
