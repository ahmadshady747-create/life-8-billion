/// لوحة إدارة الحياة: أساس المحاكاة الإدارية للعبة واحد من 8 مليارات.
/// ليست لعبة خيارات: اللاعب يوزّع ميزانية وقته وماله، ثم يضغط
/// "تقدم شهرا" ويرى النتائج المحسوبة، لا نتيجة خيار سردي واحد.
/// محتوى الخيارات القديم لم يُمسّ، واللوحة ليست بعد الشاشة الرئيسية.
/// المشاريع: مشروع واحد نشط فقط، ثمنه مقدّم من النقد، يتقدم شهرا
/// بعد شهر، وأثره يُطبق مرة واحدة عند الاكتمال، ولا يُعاد بدؤه.
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
/// - الدين له ثمن: إن كان النقد سالبا عند بدء الشهر، تُضاف فائدة
///   10% من الدين إلى مصروف ذلك الشهر، فالدين يتفاقم إن أُهمل،
///   والخروج منه يحتاج دخلا أعلى أو مصروفا أقل، لا مجرد الانتظار.
class MonthReport {
  final int month;
  final int income;
  final int expenses;
  final int savingsDeposit;
  final int debtCharge;
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
    this.debtCharge = 0,
    required this.cashDelta,
    required this.skillDelta,
    required this.healthDelta,
    required this.relationshipsDelta,
    required this.lines,
  });
}

/// مشروع إداري: يُبدأ بثمن مقدّم، يتقدم مع كل شهر، ويُطبق أثره
/// مرة واحدة عند الاكتمال. مشروع واحد نشط فقط في كل وقت.
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
  int extraMonthlyIncome;
  String? activeProjectId;
  int activeProjectMonths;
  final Set<String> completedProjectIds;
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
    this.extraMonthlyIncome = 0,
    this.activeProjectId,
    this.activeProjectMonths = 0,
    Set<String>? completedProjectIds,
    Map<String, int>? time,
    Map<String, int>? money,
  })  : completedProjectIds = completedProjectIds ?? {},
        time = time ??
            {'work': 40, 'study': 20, 'health': 15, 'relationships': 15, 'rest': 10},
        money = money ??
            {'housing': 35, 'food': 25, 'savings': 20, 'learning': 10, 'leisure': 10};

  int get monthlyIncome =>
      1000 + time['work']! * 15 + skill * 3 + extraMonthlyIncome;

  LifeProjectPlan? get activeProject {
    if (activeProjectId == null) return null;
    for (final p in projectCatalog) {
      if (p.id == activeProjectId) return p;
    }
    return null;
  }

  /// يبدأ مشروعا بثمنه مقدّما من النقد. يرفض إن كان هناك مشروع نشط
  /// آخر، أو كان المشروع مكتملا من قبل، أو لم يكفِ النقد. يعيد
  /// true عند البدء فعلا، وfalse عند الرفض، بلا أي خصم عند الرفض.
  bool startProject(String id) {
    LifeProjectPlan? plan;
    for (final p in projectCatalog) {
      if (p.id == id) plan = p;
    }
    if (plan == null) return false;
    if (activeProjectId != null) return false;
    if (completedProjectIds.contains(id)) return false;
    if (cash < plan.cost) return false;
    cash -= plan.cost;
    activeProjectId = id;
    activeProjectMonths = 0;
    return true;
  }

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
    // فائدة الدين تُحسب من النقد عند بدء الشهر، قبل أي تغيير فيه.
    final debtCharge = cash < 0 ? (-cash) * 10 ~/ 100 : 0;
    final expenses = monthlyExpenses + debtCharge;
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

    String? projectLine;
    final project = activeProject;
    if (project != null) {
      activeProjectMonths += 1;
      if (activeProjectMonths >= project.durationMonths) {
        completedProjectIds.add(project.id);
        activeProjectId = null;
        activeProjectMonths = 0;
        switch (project.id) {
          case 'certificate':
            skill = _clampScore(skill + 20);
            projectLine = 'اكتمل مشروع ${project.name}: المهارة +20 (الآن $skill).';
            break;
          case 'side_business':
            extraMonthlyIncome += 600;
            projectLine =
                'اكتمل مشروع ${project.name}: دخل شهري إضافي دائم +600.';
            break;
          case 'fitness':
            health = _clampScore(health + 15);
            projectLine = 'اكتمل مشروع ${project.name}: الصحة +15 (الآن $health).';
            break;
        }
      } else {
        projectLine =
            'مشروع نشط: ${project.name} — شهر $activeProjectMonths من ${project.durationMonths}.';
      }
    }

    final lines = <String>[
      'دخل الشهر: $income — مصروف الشهر: $expenses — ادخار: $deposit.',
      if (debtCharge > 0)
        'فائدة دين هذا الشهر: $debtCharge (10% من دينك عند بدء الشهر).',
      'صافي النقد هذا الشهر: ${cashDelta >= 0 ? '+' : ''}$cashDelta (النقد الآن $cash).',
      'المهارة ${skillDelta >= 0 ? '+' : ''}$skillDelta (الآن $skill)، '
          'الصحة ${healthDelta >= 0 ? '+' : ''}$healthDelta (الآن $health)، '
          'العلاقات ${relDelta >= 0 ? '+' : ''}$relDelta (الآن $relationships).',
    ];
    if (cash < 0) {
      lines.add('تحذير: النقد سالب — أنت مدين، وفائدة 10% شهريا تزيد دينك إن لم تخرج منه.');
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
    if (projectLine != null) {
      lines.add(projectLine);
    }
    return MonthReport(
      month: months,
      income: income,
      expenses: expenses,
      savingsDeposit: deposit,
      debtCharge: debtCharge,
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
        'extraMonthlyIncome': extraMonthlyIncome,
        'activeProjectId': activeProjectId,
        'activeProjectMonths': activeProjectMonths,
        'completedProjectIds': completedProjectIds.toList(),
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
      extraMonthlyIncome: (j['extraMonthlyIncome'] as num?)?.toInt() ?? 0,
      activeProjectId: j['activeProjectId'] as String?,
      activeProjectMonths: (j['activeProjectMonths'] as num?)?.toInt() ?? 0,
      completedProjectIds: j['completedProjectIds'] is List
          ? (j['completedProjectIds'] as List)
              .map((e) => e.toString())
              .toSet()
          : null,
      time: bucket(
          j['time'], {'work': 40, 'study': 20, 'health': 15, 'relationships': 15, 'rest': 10}),
      money: bucket(
          j['money'], {'housing': 35, 'food': 25, 'savings': 20, 'learning': 10, 'leisure': 10}),
    );
  }
}
