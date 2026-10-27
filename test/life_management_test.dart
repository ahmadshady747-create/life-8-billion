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

  test('مشروع الكتاب يكتمل بعد 8 أشهر ويرفع العلاقات 15 ولا يُعاد بدؤه', () {
    final s = LifeManagementState();
    expect(s.startProject('book'), isTrue);
    expect(s.cash, 3000);
    for (var i = 0; i < 8; i++) {
      s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('book'));
    expect(s.relationships, 65);
    final cashBefore = s.cash;
    expect(s.startProject('book'), isFalse);
    expect(s.cash, cashBefore);
  });

  test('حفظ واسترجاع مشروع الكتاب النشط يكمله بعد بقية مدته', () {
    final s = LifeManagementState();
    s.startProject('book');
    s.advanceMonth();
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'book');
    expect(restored.activeProjectMonths, 1);
    for (var i = 0; i < 7; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('book'));
    expect(restored.relationships, 65);
  });

  test('العمل الإضافي يرفع الدخل 500 ويخصم صحة وعلاقات في الشهر نفسه', () {
    final control = LifeManagementState();
    final controlReport = control.advanceMonth();
    final s = LifeManagementState();
    s.setOvertime(true);
    expect(s.monthlyIncome, controlReport.income + 500);
    final report = s.advanceMonth();
    expect(report.overtimeIncome, 500);
    expect(report.income, 2190);
    expect(report.expenses, 860);
    expect(report.savingsDeposit, 438);
    expect(report.cashDelta, 892);
    expect(s.cash, 5892);
    expect(s.health, 70);
    expect(s.relationships, 47);
    expect(report.skillDelta, controlReport.skillDelta);
    expect(report.lines.any((l) => l.contains('عمل إضافي هذا الشهر')),
        isTrue);
  });

  test('إطفاء العمل الإضافي يعيد الدخل والصحة والعلاقات إلى الأساس', () {
    final s = LifeManagementState();
    s.setOvertime(true);
    s.setOvertime(false);
    final report = s.advanceMonth();
    expect(report.overtimeIncome, 0);
    expect(report.income, 1690);
    expect(s.health, 75);
    expect(s.relationships, 50);
    expect(report.lines.any((l) => l.contains('عمل إضافي هذا الشهر')),
        isFalse);
  });

  test('العمل الإضافي لا يرفع الدخل في الأشهر السابقة لتشغيله', () {
    final s = LifeManagementState();
    final first = s.advanceMonth();
    expect(first.income, 1690);
    s.setOvertime(true);
    final second = s.advanceMonth();
    // المهارة صارت 33 بعد الشهر الأول، فالدخل 1000 + 600 + 99 + 500.
    expect(second.income, 2199);
  });

  test('حفظ واسترجاع العمل الإضافي يحفظ أثره في الشهر التالي', () {
    final s = LifeManagementState();
    s.setOvertime(true);
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.overtime, isTrue);
    final report = restored.advanceMonth();
    expect(report.overtimeIncome, 500);
    expect(restored.health, 70);
    expect(restored.relationships, 47);
  });

  test('توافق مع حالة قديمة بلا حقل العمل الإضافي (مُطفأ افتراضا)', () {
    final old = LifeManagementState().toJson()..remove('overtime');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.overtime, isFalse);
    expect(restored.advanceMonth().overtimeIncome, 0);
  });

  test('إجازة التعافي شهر كامل بأرقام دقيقة', () {
    final s = LifeManagementState();
    s.setRecovery(true);
    final report = s.advanceMonth();
    // دخل 1290 (1690 - 400)، مصروف 860، ادخار 258، صافي 172.
    expect(report.income, 1290);
    expect(report.recoveryCost, 400);
    expect(report.expenses, 860);
    expect(report.savingsDeposit, 258);
    expect(report.cashDelta, 172);
    expect(s.cash, 5172);
    expect(s.health, 81);
    expect(s.relationships, 52);
    expect(s.skill, 33);
    expect(report.lines.any((l) => l.contains('إجازة تعافٍ هذا الشهر')),
        isTrue);
  });

  test('إجازة التعافي والعمل الإضافي لا يجتمعان أبدا', () {
    final s = LifeManagementState();
    s.setOvertime(true);
    s.setRecovery(true);
    expect(s.recovery, isTrue);
    expect(s.overtime, isFalse);
    s.setOvertime(true);
    expect(s.overtime, isTrue);
    expect(s.recovery, isFalse);
    final report = s.advanceMonth();
    expect(report.overtimeIncome, 500);
    expect(report.recoveryCost, 0);
  });

  test('إطفاء إجازة التعافي يعيد الشهر إلى الأساس', () {
    final s = LifeManagementState();
    s.setRecovery(true);
    s.setRecovery(false);
    final report = s.advanceMonth();
    expect(report.income, 1690);
    expect(report.recoveryCost, 0);
    expect(s.health, 75);
    expect(s.relationships, 50);
    expect(report.lines.any((l) => l.contains('إجازة تعافٍ هذا الشهر')),
        isFalse);
  });

  test('حفظ واسترجاع إجازة التعافي يحفظ أثرها في الشهر التالي', () {
    final s = LifeManagementState();
    s.setRecovery(true);
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.recovery, isTrue);
    final report = restored.advanceMonth();
    expect(report.recoveryCost, 400);
    expect(restored.health, 81);
    expect(restored.relationships, 52);
  });

  test('توافق مع حالة قديمة بلا حقل إجازة التعافي (مُطفأة افتراضا)', () {
    final old = LifeManagementState().toJson()..remove('recovery');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.recovery, isFalse);
    expect(restored.advanceMonth().recoveryCost, 0);
  });

  test('مشروع البيت يبدأ بثمنه ويرفض بلا نقد كاف', () {
    final poor = LifeManagementState();
    expect(poor.startProject('home'), isFalse);
    expect(poor.cash, 5000);
    final s = LifeManagementState()..cash = 12000;
    expect(s.startProject('home'), isTrue);
    expect(s.cash, 0);
    expect(s.activeProjectId, 'home');
  });

  test('مشروع البيت يكتمل بعد 18 شهرا ويخفض المصروف من الشهر التالي', () {
    final s = LifeManagementState()..cash = 12000;
    expect(s.startProject('home'), isTrue);
    MonthReport? last;
    for (var i = 0; i < 18; i++) {
      last = s.advanceMonth();
    }
    expect(s.completedProjectIds.contains('home'), isTrue);
    expect(last!.expenses, 860);
    expect(last.lines.any((l) => l.contains('مصروف شهري -200')), isTrue);
    expect(s.monthlyExpenses, 660);
    final next = s.advanceMonth();
    expect(next.expenses, 660);
  });

  test('مشروع البيت المكتمل لا يُعاد بدؤه', () {
    final s = LifeManagementState()..cash = 12000;
    expect(s.startProject('home'), isTrue);
    for (var i = 0; i < 18; i++) {
      s.advanceMonth();
    }
    s.cash = 12000;
    expect(s.startProject('home'), isFalse);
    expect(s.cash, 12000);
  });

  test('حفظ واسترجاع مشروع البيت النشط يكمله بعد بقية مدته', () {
    final s = LifeManagementState()..cash = 12000;
    expect(s.startProject('home'), isTrue);
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'home');
    for (var i = 0; i < 18; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds.contains('home'), isTrue);
    expect(restored.monthlyExpenses, 660);
  });

  test('حالة قديمة بلا قائمة مشاريع مكتملة لا تحصل على خصم البيت', () {
    final old = LifeManagementState().toJson()
      ..remove('completedProjectIds');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.completedProjectIds.isEmpty, isTrue);
    expect(restored.monthlyExpenses, 860);
  });

  test('شهر بعضوية نادٍ رياضي بأرقام كاملة', () {
    final s = LifeManagementState()..gym = true;
    expect(s.monthlyIncome, 1440);
    final r = s.advanceMonth();
    expect(r.income, 1440);
    expect(r.gymCost, 250);
    expect(r.expenses, 860);
    expect(r.savingsDeposit, 288);
    expect(r.cashDelta, 292);
    expect(s.cash, 5292);
    expect(r.healthDelta, 4);
    expect(s.health, 79);
    expect(s.relationships, 50);
    expect(r.lines.any((l) => l.contains('عضوية نادٍ رياضي')), isTrue);
  });

  test('إطفاء العضوية يعيد الشهر إلى الأساس', () {
    final s = LifeManagementState()..gym = true;
    s.gym = false;
    expect(s.monthlyIncome, 1690);
    final r = s.advanceMonth();
    expect(r.gymCost, 0);
    expect(r.healthDelta, 0);
    expect(s.cash, 5492);
  });

  test('العضوية مع إجازة التعافي تجمع التكلفة والصحة', () {
    final s = LifeManagementState()
      ..gym = true
      ..setRecovery(true);
    expect(s.monthlyIncome, 1040);
    final r = s.advanceMonth();
    expect(r.healthDelta, 10);
    expect(s.health, 85);
    expect(r.relationshipsDelta, 2);
    expect(s.relationships, 52);
    expect(r.cashDelta, -28);
    expect(s.cash, 4972);
  });

  test('حفظ واسترجاع العضوية يحفظ أثرها في الشهر التالي', () {
    final s = LifeManagementState()..gym = true;
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.gym, isTrue);
    final r = restored.advanceMonth();
    expect(r.gymCost, 250);
    expect(restored.health, 79);
  });

  test('حالة قديمة بلا حقل عضوية تبقى العضوية مطفأة فيها', () {
    final old = LifeManagementState().toJson()..remove('gym');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.gym, isFalse);
    expect(restored.monthlyIncome, 1690);
  });

  test('شهر لقاء اجتماعي كامل بأرقام دقيقة', () {
    final s = LifeManagementState()..social = true;
    expect(s.monthlyIncome, 1390);
    final r = s.advanceMonth();
    expect(r.socialCost, 300);
    expect(r.income, 1390);
    expect(r.expenses, 860);
    expect(r.savingsDeposit, 278);
    expect(r.cashDelta, 252);
    expect(s.cash, 5252);
    expect(r.healthDelta, -1);
    expect(s.health, 74);
    expect(r.relationshipsDelta, 5);
    expect(s.relationships, 55);
  });

  test('إطفاء اللقاء الاجتماعي يعيد الأساس', () {
    final s = LifeManagementState()..social = true;
    s.social = false;
    expect(s.monthlyIncome, 1690);
    final r = s.advanceMonth();
    expect(r.socialCost, 0);
    expect(s.cash, 5492);
    expect(s.health, 75);
    expect(s.relationships, 50);
  });

  test('لقاء اجتماعي مع عضوية يجمع التكلفة والصحة والعلاقات', () {
    final s = LifeManagementState()
      ..social = true
      ..gym = true;
    expect(s.monthlyIncome, 1140);
    final r = s.advanceMonth();
    expect(r.socialCost, 300);
    expect(r.gymCost, 250);
    expect(r.cashDelta, 52);
    expect(s.cash, 5052);
    expect(r.healthDelta, 3);
    expect(s.health, 78);
    expect(r.relationshipsDelta, 5);
    expect(s.relationships, 55);
  });

  test('حفظ واسترجاع اللقاء الاجتماعي يحفظ أثره في الشهر التالي', () {
    final s = LifeManagementState()..social = true;
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.social, isTrue);
    final r = restored.advanceMonth();
    expect(r.socialCost, 300);
    expect(restored.relationships, 55);
    expect(restored.health, 74);
  });

  test('حالة قديمة بلا حقل لقاء اجتماعي تبقى مطفأة فيها', () {
    final old = LifeManagementState().toJson()..remove('social');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.social, isFalse);
    expect(restored.monthlyIncome, 1690);
  });

  test('شهر دورة مهنية كامل بأرقام دقيقة', () {
    final s = LifeManagementState()..course = true;
    expect(s.monthlyIncome, 1340);
    final r = s.advanceMonth();
    expect(r.courseCost, 350);
    expect(r.income, 1340);
    expect(r.expenses, 860);
    expect(r.savingsDeposit, 268);
    expect(r.cashDelta, 212);
    expect(s.cash, 5212);
    expect(r.skillDelta, 5);
    expect(s.skill, 35);
    expect(r.healthDelta, -1);
    expect(s.health, 74);
    expect(r.relationshipsDelta, 0);
    expect(s.relationships, 50);
  });

  test('إطفاء الدورة المهنية يعيد الأساس', () {
    final s = LifeManagementState()..course = true;
    s.course = false;
    expect(s.monthlyIncome, 1690);
    final r = s.advanceMonth();
    expect(r.courseCost, 0);
    expect(s.cash, 5492);
    expect(s.skill, 33);
    expect(s.health, 75);
  });

  test('دورة مهنية مع لقاء اجتماعي تجمع التكلفة والمهارة والعلاقات', () {
    final s = LifeManagementState()
      ..course = true
      ..social = true;
    expect(s.monthlyIncome, 1040);
    final r = s.advanceMonth();
    expect(r.courseCost, 350);
    expect(r.socialCost, 300);
    expect(r.skillDelta, 5);
    expect(s.skill, 35);
    expect(r.healthDelta, -2);
    expect(s.health, 73);
    expect(r.relationshipsDelta, 5);
    expect(s.relationships, 55);
  });

  test('حفظ واسترجاع الدورة المهنية يحفظ أثرها في الشهر التالي', () {
    final s = LifeManagementState()..course = true;
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.course, isTrue);
    final r = restored.advanceMonth();
    expect(r.courseCost, 350);
    expect(restored.skill, 35);
    expect(restored.health, 74);
  });

  test('حالة قديمة بلا حقل دورة مهنية تبقى مطفأة فيها', () {
    final old = LifeManagementState().toJson()..remove('course');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.course, isFalse);
    expect(restored.monthlyIncome, 1690);
  });

  test('بدء الحديقة المنزلية يخصم ثمنها ويرفض مشروعا ثانيا وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('garden'), isTrue);
    expect(s.cash, 3500);
    expect(s.activeProjectId, 'garden');
    expect(s.startProject('certificate'), isFalse);
    expect(s.cash, 3500);
    final poor = LifeManagementState(cash: 1000);
    expect(poor.startProject('garden'), isFalse);
    expect(poor.cash, 1000);
  });

  test('اكتمال الحديقة بعد 6 أشهر يخفض مصروف الشهر التالي إلى 760', () {
    final s = LifeManagementState();
    expect(s.startProject('garden'), isTrue);
    MonthReport? sixth;
    for (var i = 0; i < 6; i++) {
      sixth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('garden'));
    expect(sixth!.expenses, 860);
    expect(sixth.lines.any((l) => l.contains('حديقة منزلية')), isTrue);
    final seventh = s.advanceMonth();
    expect(seventh.expenses, 760);
  });

  test('الحديقة المكتملة لا يعاد بدؤها', () {
    final s = LifeManagementState();
    expect(s.startProject('garden'), isTrue);
    for (var i = 0; i < 6; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('garden'), isFalse);
  });

  test('حفظ واسترجاع الحديقة النشطة يكملها بعد 4 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('garden'), isTrue);
    s.advanceMonth();
    s.advanceMonth();
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'garden');
    expect(restored.activeProjectMonths, 2);
    for (var i = 0; i < 4; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('garden'));
    expect(restored.advanceMonth().expenses, 760);
  });

  test('حالة قديمة بلا قائمة مشاريع مكتملة لا تخفض مصروفها', () {
    final old = LifeManagementState().toJson()..remove('completedProjectIds');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.completedProjectIds, isEmpty);
    expect(restored.monthlyExpenses, 860);
    expect(restored.startProject('garden'), isTrue);
  });

  test('شهر تطوع مجتمعي كامل بأرقام دقيقة', () {
    final s = LifeManagementState()..volunteer = true;
    expect(s.monthlyIncome, 1490);
    final r = s.advanceMonth();
    expect(r.volunteerCost, 200);
    expect(r.income, 1490);
    expect(r.expenses, 860);
    expect(r.savingsDeposit, 298);
    expect(r.cashDelta, 332);
    expect(s.cash, 5332);
    expect(r.healthDelta, 1);
    expect(s.health, 76);
    expect(r.relationshipsDelta, 4);
    expect(s.relationships, 54);
  });

  test('إطفاء التطوع المجتمعي يعيد الأساس', () {
    final s = LifeManagementState()..volunteer = true;
    s.volunteer = false;
    expect(s.monthlyIncome, 1690);
    final r = s.advanceMonth();
    expect(r.volunteerCost, 0);
    expect(s.cash, 5492);
    expect(s.health, 75);
    expect(s.relationships, 50);
  });

  test('تطوع مجتمعي مع لقاء اجتماعي يجمع التكلفة والعلاقات والصحة', () {
    final s = LifeManagementState()
      ..volunteer = true
      ..social = true;
    expect(s.monthlyIncome, 1190);
    final r = s.advanceMonth();
    expect(r.volunteerCost, 200);
    expect(r.socialCost, 300);
    expect(r.cashDelta, 92);
    expect(s.cash, 5092);
    expect(r.healthDelta, 0);
    expect(s.health, 75);
    expect(r.relationshipsDelta, 9);
    expect(s.relationships, 59);
  });

  test('حفظ واسترجاع التطوع المجتمعي يحفظ أثره في الشهر التالي', () {
    final s = LifeManagementState()..volunteer = true;
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.volunteer, isTrue);
    final r = restored.advanceMonth();
    expect(r.volunteerCost, 200);
    expect(restored.relationships, 54);
    expect(restored.health, 76);
  });

  test('حالة قديمة بلا حقل تطوع مجتمعي تبقى مطفأة فيها', () {
    final old = LifeManagementState().toJson()..remove('volunteer');
    final restored = LifeManagementState.fromJson(old);
    expect(restored.volunteer, isFalse);
    expect(restored.monthlyIncome, 1690);
  });
  test('بدء النادي المجتمعي يخصم ثمنه ويرفض مشروعا ثانيا وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('club'), isTrue);
    expect(s.cash, 2500);
    expect(s.activeProjectId, 'club');
    expect(s.startProject('certificate'), isFalse);
    expect(s.cash, 2500);
    final poor = LifeManagementState(cash: 2000);
    expect(poor.startProject('club'), isFalse);
    expect(poor.cash, 2000);
  });
  test('اكتمال النادي بعد 9 أشهر يرفع العلاقات 10 والصحة 5 معا', () {
    final s = LifeManagementState();
    expect(s.startProject('club'), isTrue);
    MonthReport? ninth;
    for (var i = 0; i < 9; i++) {
      ninth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('club'));
    expect(ninth!.lines.any((l) => l.contains('نادٍ مجتمعي')), isTrue);
    expect(s.relationships, 60);
    expect(s.health, 80);
    expect(s.cash, 7191);
    expect(s.months, 9);
  });
  test('النادي المكتمل لا يعاد بدؤه', () {
    final s = LifeManagementState();
    expect(s.startProject('club'), isTrue);
    for (var i = 0; i < 9; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('club'), isFalse);
  });
  test('حفظ واسترجاع النادي النشط يكمله بعد 5 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('club'), isTrue);
    for (var i = 0; i < 4; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'club');
    expect(restored.activeProjectMonths, 4);
    for (var i = 0; i < 5; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('club'));
    expect(restored.relationships, 60);
    expect(restored.health, 80);
  });
  test('توافق النادي مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('club'), isTrue);
    expect(restored.cash, 2500);
  });
  test('بدء التطبيق الصغير يخصم ثمنه ويرفض مشروعا ثانيا وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('app'), isTrue);
    expect(s.cash, 1000);
    expect(s.activeProjectId, 'app');
    expect(s.startProject('certificate'), isFalse);
    expect(s.cash, 1000);
    final poor = LifeManagementState(cash: 3000);
    expect(poor.startProject('app'), isFalse);
    expect(poor.cash, 3000);
  });
  test('اكتمال التطبيق بعد 10 أشهر يرفع المهارة 10 ويضيف دخلا 300', () {
    final s = LifeManagementState();
    expect(s.startProject('app'), isTrue);
    MonthReport? tenth;
    for (var i = 0; i < 10; i++) {
      tenth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('app'));
    expect(tenth!.lines.any((l) => l.contains('تطبيق صغير')), isTrue);
    expect(s.skill, 70);
    expect(s.extraMonthlyIncome, 300);
    expect(s.monthlyIncome, 2110);
    expect(s.months, 10);
  });
  test('التطبيق المكتمل لا يعاد بدؤه', () {
    final s = LifeManagementState();
    expect(s.startProject('app'), isTrue);
    for (var i = 0; i < 10; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('app'), isFalse);
  });
  test('حفظ واسترجاع التطبيق النشط يكمله بعد 6 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('app'), isTrue);
    for (var i = 0; i < 4; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'app');
    expect(restored.activeProjectMonths, 4);
    for (var i = 0; i < 6; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('app'));
    expect(restored.skill, 70);
    expect(restored.extraMonthlyIncome, 300);
  });
  test('توافق التطبيق مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('app'), isTrue);
    expect(restored.cash, 1000);
  });
  test('بدء المطبخ الصحي يخصم ثمنه ويرفض مشروعا ثانيا وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('kitchen'), isTrue);
    expect(s.cash, 3200);
    expect(s.activeProjectId, 'kitchen');
    expect(s.startProject('certificate'), isFalse);
    expect(s.cash, 3200);
    final poor = LifeManagementState(cash: 1000);
    expect(poor.startProject('kitchen'), isFalse);
    expect(poor.cash, 1000);
  });
  test('اكتمال المطبخ بعد 5 أشهر يرفع الصحة 8 ويخفض المصروف 50 من الشهر التالي', () {
    final s = LifeManagementState();
    expect(s.startProject('kitchen'), isTrue);
    MonthReport? fifth;
    for (var i = 0; i < 5; i++) {
      fifth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('kitchen'));
    expect(fifth!.lines.any((l) => l.contains('مطبخ صحي منزلي')), isTrue);
    expect(fifth.expenses, 860);
    expect(s.health, 83);
    expect(s.skill, 45);
    expect(s.monthlyExpenses, 810);
    expect(s.cash, 5734);
    expect(s.months, 5);
    final sixth = s.advanceMonth();
    expect(sixth.expenses, 810);
    expect(s.cash, 6312);
    expect(s.months, 6);
  });
  test('المطبخ المكتمل لا يعاد بدؤه', () {
    final s = LifeManagementState();
    expect(s.startProject('kitchen'), isTrue);
    for (var i = 0; i < 5; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('kitchen'), isFalse);
  });
  test('حفظ واسترجاع المطبخ النشط يكمله بعد 3 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('kitchen'), isTrue);
    for (var i = 0; i < 2; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'kitchen');
    expect(restored.activeProjectMonths, 2);
    for (var i = 0; i < 3; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('kitchen'));
    expect(restored.health, 83);
    expect(restored.monthlyExpenses, 810);
  });
  test('توافق المطبخ مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('kitchen'), isTrue);
    expect(restored.cash, 3200);
  });
  test('بدء المجتمع المهني يخصم 3000 ويرفض الثاني وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('community'), isTrue);
    expect(s.cash, 2000);
    expect(s.startProject('app'), isFalse);
    expect(s.cash, 2000);
    final poor = LifeManagementState(cash: 1000);
    expect(poor.startProject('community'), isFalse);
    expect(poor.cash, 1000);
  });
  test('اكتمال المجتمع المهني بعد 7 أشهر يرفع المهارة 8 والعلاقات 8', () {
    final s = LifeManagementState();
    expect(s.startProject('community'), isTrue);
    MonthReport? seventh;
    for (var i = 0; i < 7; i++) {
      seventh = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('community'));
    expect(seventh!.lines.any((l) => l.contains('مجتمع مهني')), isTrue);
    expect(s.skill, 59);
    expect(s.relationships, 58);
    expect(s.cash, 5598);
    expect(s.months, 7);
  });
  test('المجتمع المهني المكتمل لا يعاد بدؤه', () {
    final s = LifeManagementState();
    expect(s.startProject('community'), isTrue);
    for (var i = 0; i < 7; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('community'), isFalse);
  });
  test('حفظ واسترجاع المجتمع المهني النشط يكمله بعد 4 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('community'), isTrue);
    for (var i = 0; i < 3; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'community');
    expect(restored.activeProjectMonths, 3);
    for (var i = 0; i < 4; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('community'));
    expect(restored.skill, 59);
    expect(restored.relationships, 58);
  });
  test('توافق المجتمع المهني مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('community'), isTrue);
    expect(restored.cash, 2000);
  });
  test('بدء التعاونية يخصم 2200 ويرفض الثاني وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('coop'), isTrue);
    expect(s.cash, 2800);
    expect(s.startProject('app'), isFalse);
    expect(s.cash, 2800);
    final poor = LifeManagementState(cash: 1000);
    expect(poor.startProject('coop'), isFalse);
    expect(poor.cash, 1000);
  });
  test('اكتمال التعاونية بعد 8 أشهر يرفع العلاقات 9 ويخفض المصروف 75', () {
    final s = LifeManagementState();
    expect(s.startProject('coop'), isTrue);
    MonthReport? eighth;
    for (var i = 0; i < 8; i++) {
      eighth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('coop'));
    expect(eighth!.lines.any((l) => l.contains('تعاونية حيّ')), isTrue);
    expect(eighth.expenses, 860);
    expect(s.relationships, 59);
    expect(s.skill, 54);
    expect(s.cash, 6941);
    expect(s.monthlyExpenses, 785);
    expect(s.months, 8);
    final ninth = s.advanceMonth();
    expect(ninth.expenses, 785);
    expect(s.cash, 7566);
  });
  test('التعاونية المكتملة لا يعاد بدؤها', () {
    final s = LifeManagementState();
    expect(s.startProject('coop'), isTrue);
    for (var i = 0; i < 8; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('coop'), isFalse);
  });
  test('حفظ واسترجاع التعاونية النشطة يكملها بعد 5 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('coop'), isTrue);
    for (var i = 0; i < 3; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'coop');
    expect(restored.activeProjectMonths, 3);
    for (var i = 0; i < 5; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('coop'));
    expect(restored.relationships, 59);
    expect(restored.monthlyExpenses, 785);
  });
  test('توافق التعاونية مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('coop'), isTrue);
    expect(restored.cash, 2800);
  });
  test('بدء تدريب الإسعاف يخصم 2600 ويرفض الثاني وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('first_aid'), isTrue);
    expect(s.cash, 2400);
    expect(s.startProject('app'), isFalse);
    expect(s.cash, 2400);
    final poor = LifeManagementState(cash: 1000);
    expect(poor.startProject('first_aid'), isFalse);
    expect(poor.cash, 1000);
  });
  test('اكتمال تدريب الإسعاف بعد 6 أشهر يرفع المهارة 10 والصحة 6', () {
    final s = LifeManagementState();
    expect(s.startProject('first_aid'), isTrue);
    MonthReport? sixth;
    for (var i = 0; i < 6; i++) {
      sixth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('first_aid'));
    expect(sixth!.lines.any((l) => l.contains('تدريب إسعاف ووقاية')), isTrue);
    expect(s.skill, 58);
    expect(s.health, 81);
    expect(s.relationships, 50);
    expect(s.cash, 5462);
    expect(s.months, 6);
  });
  test('تدريب الإسعاف المكتمل لا يعاد بدؤه', () {
    final s = LifeManagementState();
    expect(s.startProject('first_aid'), isTrue);
    for (var i = 0; i < 6; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('first_aid'), isFalse);
  });
  test('حفظ واسترجاع تدريب الإسعاف النشط يكمله بعد 4 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('first_aid'), isTrue);
    for (var i = 0; i < 2; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'first_aid');
    expect(restored.activeProjectMonths, 2);
    for (var i = 0; i < 4; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('first_aid'));
    expect(restored.skill, 58);
    expect(restored.health, 81);
  });
  test('توافق تدريب الإسعاف مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('first_aid'), isTrue);
    expect(restored.cash, 2400);
  });
  test('بدء خدمة التوصيل وخصمها ورفض الثاني وبلا نقد', () {
    final s = LifeManagementState();
    expect(s.startProject('delivery'), isTrue);
    expect(s.cash, 2200);
    expect(s.startProject('app'), isFalse);
    expect(s.cash, 2200);
    final poor = LifeManagementState(cash: 1000);
    expect(poor.startProject('delivery'), isFalse);
    expect(poor.cash, 1000);
  });
  test('اكتمال خدمة التوصيل بعد 8 أشهر يرفع العلاقات 7 ودخلا 200', () {
    final s = LifeManagementState();
    expect(s.startProject('delivery'), isTrue);
    MonthReport? eighth;
    for (var i = 0; i < 8; i++) {
      eighth = s.advanceMonth();
    }
    expect(s.completedProjectIds, contains('delivery'));
    expect(eighth!.lines.any((l) => l.contains('خدمة توصيل للحيّ')), isTrue);
    expect(s.skill, 54);
    expect(s.health, 75);
    expect(s.relationships, 57);
    expect(s.extraMonthlyIncome, 200);
    expect(s.cash, 6341);
    expect(s.months, 8);
  });
  test('خدمة التوصيل المكتملة لا يعاد بدؤها', () {
    final s = LifeManagementState();
    expect(s.startProject('delivery'), isTrue);
    for (var i = 0; i < 8; i++) {
      s.advanceMonth();
    }
    expect(s.startProject('delivery'), isFalse);
  });
  test('حفظ واسترجاع خدمة التوصيل النشطة يكملها بعد 5 أشهر أخرى', () {
    final s = LifeManagementState();
    expect(s.startProject('delivery'), isTrue);
    for (var i = 0; i < 3; i++) {
      s.advanceMonth();
    }
    final restored =
        LifeManagementState.fromJson(Map<String, dynamic>.from(s.toJson()));
    expect(restored.activeProjectId, 'delivery');
    expect(restored.activeProjectMonths, 3);
    for (var i = 0; i < 5; i++) {
      restored.advanceMonth();
    }
    expect(restored.completedProjectIds, contains('delivery'));
    expect(restored.relationships, 57);
    expect(restored.extraMonthlyIncome, 200);
  });
  test('توافق خدمة التوصيل مع حالة قديمة بلا قائمة مشاريع مكتملة بلا خصم', () {
    final old = <String, dynamic>{
      'cash': 5000,
      'health': 75,
      'skill': 30,
      'relationships': 50,
    };
    final restored = LifeManagementState.fromJson(old);
    expect(restored.startProject('delivery'), isTrue);
    expect(restored.cash, 2200);
  });
}
