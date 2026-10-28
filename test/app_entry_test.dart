import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('المرحلة 1: فتح التطبيق يفتح لوحة إدارة الحياة مباشرة بلا شاشة بداية',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LifeApp());
    await tester.pumpAndSettle();
    expect(find.text('تقدم شهرا ⏭️'), findsOneWidget);
    expect(find.text('ابدأ حياة جديدة 🎲'), findsNothing);
    expect(find.text('لوحة الإدارة الجديدة 📊'), findsNothing);
  });

  testWidgets('المرحلة 1: حفظ إدارة قديم بحقول ناقصة يُستأنف دون كسر',
      (tester) async {
    // حفظ من صيغة أقدم: أشهر ونقد فقط، بلا حقول الخيارات الأحدث.
    SharedPreferences.setMockInitialValues({
      'life_management_v1': jsonEncode({'months': 4, 'cash': 7777}),
    });
    await tester.pumpWidget(const LifeApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('تم استئناف إدارة محفوظة'), findsOneWidget);
    expect(find.text('العمر 18 — الشهر 4'), findsOneWidget);
    expect(find.text('النقد: 7777'), findsOneWidget);
    await tester.tap(find.text('تقدم شهرا ⏭️'));
    await tester.pumpAndSettle();
    expect(find.text('العمر 18 — الشهر 5'), findsOneWidget);
  });
}
