import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/life_management.dart';

void main() {
  test('القيم الابتدائية: مجموع الميزانيتين 100 والدخل والمصروف محسوبان', () {
    final s = LifeManagementState();
    expect(s.time.values.reduce((a, b) => a + b), 100);
    expect(s.money.values.reduce((a, b) => a + b), 100);
    expect(s.monthlyIncome, 1000 + 40 * 15 + 30 * 3);
    expect(s.monthlyExpenses, 300 + (35 + 25 + 10) * 8);
    expect(s.monthlySavingsDeposit, s.monthlyIncome * 20 ~/ 100);
  });

  test('تقدم شهر واحد من الحالة الابتدائية بأرقام محسوبة', () {
    final s = LifeManagementState();
    final report = s.advanceMonth();
    expect(s.months, 1);
    expect(s.ageYears, 18);
    expect(report.income, 1690);
    expect(report.expenses, 860);
    expect(report.savingsDeposit, 338);
    expect(report.cashDelta, 492);
    expect(s.cash, 5492);
    expect(s.savings, 1338);
    expect(report.skillDelta, 3);
    expect(s.skill, 33);
    expect(report.healthDelta, 0);
    expect(report.relationshipsDelta, 0);
    expect(report.lines, isNotEmpty);
  });

  test('رفع بند وقت يسحب من أكبر بند آخر ويبقي المجموع 100', () {
    final s = LifeManagementState();
    s.setTimeBucket('work', 60);
    expect(s.time['work'], 60);
    expect(s.time['study'], 0);
    expect(s.time.values.reduce((a, b) => a + b), 100);
  });

  test('خفض بند وقت يعيد الفرق إلى أكبر بند آخر', () {
    final s = LifeManagementState();
    s.setTimeBucket('work', 0);
    expect(s.time['work'], 0);
    expect(s.time['study'], 60);
    expect(s.time.values.reduce((a, b) => a + b), 100);
  });

  test('انعدام الدراسة والتعلم ينقص المهارة نقطة في الشهر', () {
    final s = LifeManagementState();
    s.setTimeBucket('study', 0);
    s.setMoneyBucket('learning', 0);
    final report = s.advanceMonth();
    expect(report.skillDelta, -1);
    expect(s.skill, 29);
  });

  test('إهمال الصحة والراحة ينقص الصحة خمس نقاط في الشهر', () {
    final s = LifeManagementState();
    s.setTimeBucket('health', 0);
    s.setTimeBucket('rest', 0);
    final report = s.advanceMonth();
    expect(report.healthDelta, -5);
    expect(s.health, 70);
    expect(report.lines.any((l) => l.contains('إهمال الصحة')), isTrue);
  });

  test('اثنا عشر شهرا ترفع العمر سنة واحدة', () {
    final s = LifeManagementState();
    for (var i = 0; i < 12; i++) {
      s.advanceMonth();
    }
    expect(s.months, 12);
    expect(s.ageYears, 19);
  });

  test('حفظ واسترجاع حالة الإدارة يحفظ الميزانيات والدرجات', () {
    final s = LifeManagementState();
    s.setTimeBucket('work', 60);
    s.advanceMonth();
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.time, s.time);
    expect(restored.money, s.money);
    expect(restored.cash, s.cash);
    expect(restored.savings, s.savings);
    expect(restored.months, s.months);
    expect(restored.skill, s.skill);
  });
}
