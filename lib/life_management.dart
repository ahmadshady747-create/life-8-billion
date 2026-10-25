/// لوحة إدارة الحياة: أساس المحاكاة الإدارية للعبة واحد من 8 مليارات.
/// ليست لعبة خيارات: اللاعب يوزّع ميزانية وقته وماله، ثم يضغط
/// "تقدم شهرا" ويرى النتائج المحسوبة، لا نتيجة خيار سردي واحد.
/// محتوى الخيارات القديم لم يُمسّ في هذه الجولة، واللوحة ليست بعد
/// الشاشة الرئيسية؛ بدء المشاريع والحفظ الكامل يأتيان في جولات لاحقة.
///
/// قواعد الأرقام (أصلية، بأرقام لعب لا بيانات رسمية):
/// - ميزانية الوقت 100 نقطة موزعة على عمل ودراسة وصحة وعلاقات وراحة.
/// - ميزانية المال 100 نقطة موزعة على سكن وطعام وادخار وتعلم وترفيه.
/// - مجموع كل ميزانية يبقى 100 دائما: رفع بند يسحب من أكبر بند آخر.
/// - الدخل الشهري = 1000 + عمل×15 + مهارة×3 (المهارة ترفع الأجر فعلا).
/// - المصروف الشهري = 300 + (سكن+طعام+ترفيه)×8.
/// - الادخار الشهري = الدخل × نسبة الادخار، ويُخصم من النقد ويُضاف
///   إلى رصيد الادخار المنفصل.
/// - المهارة تزيد بدراسة وتعلم، وتتراجع نقطة إن كانا صفرا معا.
/// - الصحة تتحسن بوقت الصحة والراحة معا، وتتراجع إن قلّ مجموعهما.
/// - العلاقات تتحسن بوقت العلاقات، وتتراجع إن قلّ عن 15.
/// - العمر يزيد سنة كل 12 شهرا، بدءا من 18 (إدارة حياة البالغين).
class MonthReport {
  final int month;
  final int income;
  final int expenses;
  final int savingsDeposit;
  final int cashDelta;
  final int skillDelta;
  final int healthDelta;
  final int relationshipsDelta;
  final List<String> lines;

  const MonthReport({
    required this.month,
    required this.income,
    required this.expenses,
    required this.savingsDeposit,
    required this.cashDelta,
    required this.skillDelta,
    required this.healthDelta,
    required this.relationshipsDelta,
    required this.lines,
  });
}

/// مشروع مخطط: يُعرض في تبويب المشاريع بمدته وتكلفته وأثره المقصود،
/// لكن بدءه وتقدمه يأتيان في جولة المشاريع اللاحقة، لا في هذه الجولة.
class LifeProjectPlan {
  final String id;
  final String name;
  final String description;
  final int durationMonths;
  final int cost;
  final String effect;

  const LifeProjectPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMonths,
    required this.cost,
    required this.effect,
  });
}

/// هدف قابل للقياس من حالة الإدارة نفسها، يُعرض بشريط تقدم.
class LifeGoal {
  final String name;
  final int current;
  final int target;

  const LifeGoal({required this.name, required this.current, required this.target});

  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1);
}

class LifeManagementState {
  static const timeBuckets = ['work', 'study', 'health', 'relationships', 'rest'];
  static const moneyBuckets = ['housing', 'food', 'savings', 'learning', 'leisure'];

  static const timeLabels = {
    'work': 'عمل',
    'study': 'دراسة',
    'health': 'صحة',
    'relationships': 'علاقات',
    'rest': 'راحة',
  };

  static const moneyLabels = {
    'housing': 'سكن',
    'food': 'طعام',
    'savings': 'ادخار',
    'learning': 'تعلم',
    'leisure': 'ترفيه',
  };

  static const projectCatalog = [
    LifeProjectPlan(
      id: 'certificate',
      name: 'شهادة مهنية',
      description: 'دراسة منظمة ترفع المهارة وتفتح أجرا أعلى.',
      durationMonths: 6,
      cost: 3000,
      effect: 'مهارة +20 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'side_business',
      name: 'مشروع جانبي',
      description: 'عمل صغير بجانب الوظيفة، يحتاج رأس مال وصبرا.',
      durationMonths: 12,
      cost: 5000,
      effect: 'دخل شهري إضافي عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'fitness',
      name: 'برنامج لياقة',
      description: 'التزام صحي طويل يرفع الصحة ويحميها من التراجع.',
      durationMonths: 4,
      cost: 800,
      effect: 'صحة +15 عند الاكتمال',
    ),
  ];

  int ageYears;
  int months;
  int cash;
  int savings;
  int health;
  int skill;
  int relationships;
  final Map<String, int> time;
  final Map<String, int> money;

  LifeManagementState({
    this.ageYears = 18,
    this.months = 0,
    this.cash = 5000,
    this.savings = 1000,
    this.health = 75,
    this.skill = 30,
    this.relationships = 50,
    Map<String, int>? time,
    Map<String, int>? money,
  })  : time = time ??
            {'work': 40, 'study': 20, 'health': 15, 'relationships': 15, 'rest': 10},
        money = money ??
            {'housing': 35, 'food': 25, 'savings': 20, 'learning': 10, 'leisure': 10};

  int get monthlyIncome => 1000 + time['work']! * 15 + skill * 3;

  int get monthlyExpenses =>
      300 + (money['housing']! + money['food']! + money['leisure']!) * 8;

  int get monthlySavingsDeposit => monthlyIncome * money['savings']! ~/ 100;

  List<LifeGoal> get goals => [
        LifeGoal(name: 'مهارة 70', current: skill, target: 70),
        LifeGoal(name: 'ادخار 10000', current: savings, target: 10000),
        LifeGoal(name: 'علاقات 80', current: relationships, target: 80),
        LifeGoal(name: 'صحة 90', current: health, target: 90),
      ];

  /// يضبط بندا في ميزانية ويعيد توازن المجموع إلى 100 بسحب الفرق
  /// من أكبر البنود الأخرى أو بإعطائه إليها، ولا يتجاوز ما تسمح به
  /// البنود الأخرى. يعيد القيمة النهائية للبند.
  int _rebalance(Map<String, int> budget, String key, int value) {
    value = value.clamp(0, 100);
    final old = budget[key]!;
    var delta = value - old;
    if (delta == 0) return old;
    final others = budget.keys.where((k) => k != key).toList()
      ..sort((a, b) => budget[b]!.compareTo(budget[a]!));
    if (delta > 0) {
      // نحتاج سحب delta من الآخرين؛ إن لم يكفِ مجموعهم، نُقلّص الهدف.
      var available = 0;
      for (final k in others) {
        available += budget[k]!;
      }
      if (delta > available) delta = available;
      var remaining = delta;
      for (final k in others) {
        if (remaining == 0) break;
        final take = budget[k]! < remaining ? budget[k]! : remaining;
        budget[k] = budget[k]! - take;
        remaining -= take;
      }
    } else {
      // نعيد -delta إلى أكبر بند آخر.
      budget[others.first] = budget[others.first]! - delta;
    }
    budget[key] = old + delta;
    return budget[key]!;
  }

  int setTimeBucket(String key, int value) => _rebalance(time, key, value);

  int setMoneyBucket(String key, int value) => _rebalance(money, key, value);

  int _clampScore(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);

  MonthReport advanceMonth() {
    final income = monthlyIncome;
    final expenses = monthlyExpenses;
    final deposit = monthlySavingsDeposit;
    final cashDelta = income - expenses - deposit;
    var skillDelta = time['study']! ~/ 10 + money['learning']! ~/ 10;
    if (time['study'] == 0 && money['learning'] == 0) skillDelta = -1;
    final healthDelta =
        (time['health']! + time['rest']! - 25) ~/ 5;
    final relDelta = (time['relationships']! - 15) ~/ 5;

    cash += cashDelta;
    savings += deposit;
    skill = _clampScore(skill + skillDelta);
    health = _clampScore(health + healthDelta);
    relationships = _clampScore(relationships + relDelta);
    months += 1;
    ageYears = 18 + months ~/ 12;

    final lines = <String>[
      'دخل الشهر: $income — مصروف الشهر: $expenses — ادخار: $deposit.',
      'صافي النقد هذا الشهر: ${cashDelta >= 0 ? '+' : ''}$cashDelta (النقد الآن $cash).',
      'المهارة ${skillDelta >= 0 ? '+' : ''}$skillDelta (الآن $skill)، '
          'الصحة ${healthDelta >= 0 ? '+' : ''}$healthDelta (الآن $health)، '
          'العلاقات ${relDelta >= 0 ? '+' : ''}$relDelta (الآن $relationships).',
    ];
    if (cash < 0) {
      lines.add('تحذير: النقد سالب — أنت مدين، وأي شهر سيئ آخر يهدد حياتك المالية.');
    }
    if (healthDelta < 0) {
      lines.add('إهمال الصحة بدأ يظهر: زد وقت الصحة أو الراحة قبل أن يتراجع أكثر.');
    }
    if (skillDelta > 0) {
      lines.add('استثمارك في التعلم يرفع مهارتك، والمهارة الأعلى تعني أجرا أعلى لاحقا.');
    }
    if (time['work']! >= 60) {
      lines.add('شهر عمل مكثف: دخل أعلى الآن، لكنه يأكل وقت الصحة والعلاقات والدراسة.');
    }
    return MonthReport(
      month: months,
      income: income,
      expenses: expenses,
      savingsDeposit: deposit,
      cashDelta: cashDelta,
      skillDelta: skillDelta,
      healthDelta: healthDelta,
      relationshipsDelta: relDelta,
      lines: lines,
    );
  }

  Map<String, dynamic> toJson() => {
        'ageYears': ageYears,
        'months': months,
        'cash': cash,
        'savings': savings,
        'health': health,
        'skill': skill,
        'relationships': relationships,
        'time': Map<String, int>.from(time),
        'money': Map<String, int>.from(money),
      };

  factory LifeManagementState.fromJson(Map<String, dynamic> j) {
    Map<String, int> bucket(dynamic raw, Map<String, int> fallback) {
      if (raw is! Map) return Map<String, int>.from(fallback);
      final out = <String, int>{};
      for (final e in raw.entries) {
        out[e.key.toString()] = (e.value as num).toInt();
      }
      return out;
    }

    return LifeManagementState(
      ageYears: (j['ageYears'] as num?)?.toInt() ?? 18,
      months: (j['months'] as num?)?.toInt() ?? 0,
      cash: (j['cash'] as num?)?.toInt() ?? 5000,
      savings: (j['savings'] as num?)?.toInt() ?? 1000,
      health: (j['health'] as num?)?.toInt() ?? 75,
      skill: (j['skill'] as num?)?.toInt() ?? 30,
      relationships: (j['relationships'] as num?)?.toInt() ?? 50,
      time: bucket(
          j['time'], {'work': 40, 'study': 20, 'health': 15, 'relationships': 15, 'rest': 10}),
      money: bucket(
          j['money'], {'housing': 35, 'food': 25, 'savings': 20, 'learning': 10, 'leisure': 10}),
    );
  }
}
