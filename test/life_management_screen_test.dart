import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/life_management.dart';
import 'package:life_8_billion/screens/life_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('حفظ يدوي من اللوحة بعد تقدم شهر يعرض تأكيد حفظ',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
        const MaterialApp(home: LifeManagementScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تقدم شهرا ⏭️'));
    await tester.pumpAndSettle();
    expect(find.text('العمر 18 — الشهر 1'), findsOneWidget);
    await tester.tap(find.text('حفظ الإدارة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('تم حفظ الإدارة (الشهر 1)'), findsOneWidget);
  });

  testWidgets('فتح اللوحة مع حفظ موجود يستأنف الشهر والنقد المحفوظين',
      (tester) async {
    final saved =
        LifeManagementState(months: 3, cash: 4321, health: 80, skill: 45);
    SharedPreferences.setMockInitialValues({
      'life_management_v1': jsonEncode(saved.toJson()),
    });
    await tester.pumpWidget(
        const MaterialApp(home: LifeManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('تم استئناف إدارة محفوظة'), findsOneWidget);
    expect(find.text('العمر 18 — الشهر 3'), findsOneWidget);
    expect(find.text('النقد: 4321'), findsOneWidget);
  });

  testWidgets('حفظ تالف لا يكسر اللوحة بل يبدأ إدارة جديدة', (tester) async {
    SharedPreferences.setMockInitialValues({
      'life_management_v1': 'ليس JSON صالحا',
    });
    await tester.pumpWidget(
        const MaterialApp(home: LifeManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.text('العمر 18 — الشهر 0'), findsOneWidget);
    expect(find.text('النقد: 5000'), findsOneWidget);
    expect(find.textContaining('تم استئناف إدارة محفوظة'), findsNothing);
  });
}
