import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/life_management.dart';

void main() {
  test('المرحلة 2: إهمال الصحة مع عمل إضافي — مال يرتفع وصحة تنهار معا',
      () {
    final state = LifeManagementState();
    state.time['health'] = 0;
    state.time['rest'] = 0;
    state.setOvertime(true);
    for (var i = 0; i < 6; i++) {
      state.advanceMonth();
    }
    expect(state.health, lessThanOrEqualTo(30));
    expect(state.cash, greaterThan(5000));
  });

  test('المرحلة 2: الدين ثمن حقيقي — مدين ينهي أفقر من غير مدين بالفارق نفسه',
      () {
    final indebted = LifeManagementState(cash: -5000);
    final free = LifeManagementState(cash: 5000);
    for (var i = 0; i < 3; i++) {
      final report = indebted.advanceMonth();
      expect(report.debtCharge, greaterThan(0));
      free.advanceMonth();
    }
    expect(free.cash - indebted.cash, greaterThan(10000));
  });

  test('المرحلة 2: تعافٍ من الإدارة — تعافٍ ونادٍ يرفعان صحة منخفضة', () {
    final state = LifeManagementState(health: 40);
    state.time['health'] = 30;
    state.time['rest'] = 25;
    state.setRecovery(true);
    state.gym = true;
    for (var i = 0; i < 3; i++) {
      final report = state.advanceMonth();
      expect(report.healthDelta, greaterThan(0));
    }
    expect(state.health, greaterThan(70));
  });

  test('المرحلة 2: أرخص وأقصر مشروع ليس متعدد المحاور', () {
    const projects = LifeManagementState.projectCatalog;
    final minCost =
        projects.map((p) => p.cost).reduce((a, b) => a < b ? a : b);
    final minDuration = projects
        .map((p) => p.durationMonths)
        .reduce((a, b) => a < b ? a : b);
    const axes = ['مهارة', 'علاقات', 'دخل', 'مصروف'];
    var multiAxisExists = false;
    for (final p in projects) {
      final axisCount =
          axes.where((a) => p.effect.contains(a)).length;
      if (axisCount >= 2) multiAxisExists = true;
      expect(
          p.cost == minCost &&
              p.durationMonths == minDuration &&
              axisCount >= 2,
          isFalse,
          reason: 'المشروع ${p.name} أرخص وأقصر ومتعدد المحاور معا');
    }
    expect(multiAxisExists, isTrue);
  });
}
