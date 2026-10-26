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

  test('بدء مشروع يخصم ثمنه مقدما ويرفض مشروعا ثانيا ومشروعا بلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('fitness'), isTrue);
    expect(s.cash, 5000 - 800);
    expect(s.activeProjectId, 'fitness');
    expect(s.startProject('certificate'), isFalse);
    expect(s.cash, 4200);
    final poor = LifeManagementState(cash: 100);
    expect(poor.startProject('certificate'), isFalse);
    expect(poor.cash, 100);
    expect(poor.activeProjectId, isNull);
  });

  test('برنامج اللياقة يكتمل بعد 4 أشهر ويضيف صحة 15 ولا يُعاد بدؤه', () {
    final s = LifeManagementState();
    s.startProject('fitness');
    MonthReport? last;
    for (var i = 0; i < 4; i++) {
      last = s.advanceMonth();
    }
    expect(s.activeProjectId, isNull);
    expect(s.completedProjectIds, contains('fitness'));
    expect(last!.lines.any((l) => l.contains('اكتمل مشروع برنامج لياقة')),
        isTrue);
    expect(s.startProject('fitness'), isFalse);
  });

  test('الشهادة تكتمل بعد 6 أشهر وتضيف مهارة 20 فوق أثر الشهر العادي', () {
    final s = LifeManagementState();
    s.startProject('certificate');
    for (var i = 0; i < 6; i++) {
      s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('certificate'));
    // مهارة البداية 30 + 3 شهريا من الدراسة والتعلم × 6 = 48، +20 للشهادة = 68.
    expect(s.skill, 68);
  });

  test('المشروع الجانبي يكتمل بعد 12 شهرا ويضيف دخلا شهريا دائما 600', () {
    final s = LifeManagementState(cash: 50000);
    s.startProject('side_business');
    for (var i = 0; i < 12; i++) {
      s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('side_business'));
    expect(s.extraMonthlyIncome, 600);
    expect(s.monthlyIncome, 1000 + 40 * 15 + s.skill * 3 + 600);
  });

  test('حفظ واسترجاع المشروع النشط والمكتمل والدخل الإضافي', () {
    final s = LifeManagementState();
    s.startProject('fitness');
    s.advanceMonth();
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'fitness');
    expect(restored.activeProjectMonths, 1);
    for (var i = 0; i < 3; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('fitness'));
    final old = LifeManagementState.fromJson({});
    expect(old.activeProjectId, isNull);
    expect(old.extraMonthlyIncome, 0);
  });

  test('الدين السالب يفرض فائدة 10% تُضاف إلى مصروف الشهر', () {
    final s = LifeManagementState(cash: -1000);
    final report = s.advanceMonth();
    expect(report.debtCharge, 100);
    expect(report.expenses, 860 + 100);
    expect(report.cashDelta, 1690 - 960 - 338);
    expect(s.cash, -608);
    expect(report.lines.any((l) => l.contains('فائدة دين هذا الشهر')),
        isTrue);
  });

  test('لا فائدة دين عندما يكون النقد غير سالب', () {
    final s = LifeManagementState();
    final report = s.advanceMonth();
    expect(report.debtCharge, 0);
    expect(report.expenses, 860);
  });

  test('دين صغير أقل من 10 لا يفرض فائدة (قسمة صحيحة)', () {
    final s = LifeManagementState(cash: -5);
    final report = s.advanceMonth();
    expect(report.debtCharge, 0);
    expect(report.lines.any((l) => l.contains('فائدة دين هذا الشهر')),
        isFalse);
  });

  test('حفظ واسترجاع النقد السالب يحفظ الدين وفائدته في الشهر التالي', () {
    final s = LifeManagementState(cash: -1000);
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.cash, -1000);
    final report = restored.advanceMonth();
    expect(report.debtCharge, 100);
    expect(restored.cash, -608);
  });
}
