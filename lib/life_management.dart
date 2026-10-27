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
/// - العمل الإضافي خيار إداري شهري (مُطفأ افتراضا): دخل +500 في
///   الشهر، لكنه يخصم 5 من تغيّر الصحة و3 من تغيّر العلاقات في
///   الشهر نفسه، فالمال السريع له ثمن في الصحة والعلاقات، ولا
///   يكون دائما الخيار الأفضل.
/// - إجازة التعافي خيار إداري شهري مضاد للعمل الإضافي (مُطفأة
///   افتراضا، ولا يجتمعان أبدا): دخل -400 في الشهر، لكنها تضيف 6
///   إلى تغيّر الصحة و2 إلى تغيّر العلاقات في الشهر نفسه، فالتعافي
///   يُشترى بمال مفقود، والاختيار بين الإرهاق والتعافي والوسط
///   هو قرار إداري شهري لا حل واحد دائم.
/// - مشروع البيت الصغير (12000، 18 شهرا): ثمن كبير مقدّم لا يقدر
///   عليه النقد الابتدائي، فيحتاج ادخارا أولا، ومقابله مصروف شهري
///   أقل بـ 200 دائما من الشهر التالي للاكتمال، لا في شهر الاكتمال
///   نفسه، فالاستثمار طويل الأجل يخفف العبء الشهري ولا يلغي ثمنه.
/// - عضوية النادي الرياضي خيار إداري شهري (مُطفأة افتراضا): دخل
///   -250 في الشهر، مقابل صحة +4 في الشهر نفسه، بلا أثر على
///   العلاقات، فالصحة تُشترى بمال شهري متكرر لا بدفعة واحدة،
///   وهي أرخص من إجازة التعافي لكنها لا تعطي راحة العلاقات،
///   فالاختيار بينهما وبين الجمع بينهما قرار تكلفة لا حل واحد.
/// - اللقاء الاجتماعي الشهري خيار إداري شهري (مُطفأ افتراضا):
///   دخل -300 في الشهر، مقابل علاقات +5 في الشهر نفسه، لكنه
///   يخصم 1 من تغيّر الصحة (سهر وإرهاق اجتماعي)، فيجمع بين
///   ثمن مالي وثمن صحي صغير، ولا يكون مجانا أبدا، ويمكن جمعه
///   مع العضوية والتعافي فيجمع أثمانها كلها.
/// - مشروع الحديقة المنزلية (1500، 6 أشهر): ثمن مقدّم متوسط،
///   ومقابله مصروف شهري أقل بـ 100 دائما من الشهر التالي للاكتمال،
///   لا في شهر الاكتمال نفسه، على غرار البيت الصغير لكن بثمن
///   ومدة أقل وأثر أصغر، فيجمع اللاعب بينهما إن أراد خفضا أكبر
///   للمصروف، ولا يلغي أي منهما الآخر.
/// - مشروع النادي المجتمعي (2500، 9 أشهر): ثمن مقدّم متوسط،
///   ومقابله علاقات +10 وصحة +5 معا عند الاكتمال، فهو يجمع بين
///   نظامي العلاقات والصحة لا أحدهما فقط، على عكس الكتاب الذي
///   يرفع العلاقات وحدها وبرنامج اللياقة الذي يرفع الصحة وحدها،
///   لكنه أبطأ وأغلى من كل منهما وحده في أثره المنفرد، فالاختيار
///   بين التخصص والجمع قرار توازن لا حل واحد دائم.
/// - الدورة المهنية الشهرية خيار إداري شهري (مُطفأة افتراضا):
///   دخل -350 في الشهر، مقابل مهارة +2 في الشهر نفسه، لكنها
///   تخصم 1 من تغيّر الصحة (جهد دراسي إضافي)، فتسريع المهارة
///   يُشترى بمال وجهد لا مجانا، ولا يلغي أثر الدراسة والتعلم
///   العاديين بل يضاف إليهما، ويمكن جمعها مع الخيارات الأخرى
///   فيجمع أثمانها كلها.
class MonthReport {
  final int month;
  final int income;
  final int expenses;
  final int savingsDeposit;
  final int debtCharge;
  final int overtimeIncome;
  final int recoveryCost;
  final int gymCost;
  final int socialCost;
  final int courseCost;
  final int volunteerCost;
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
    this.overtimeIncome = 0,
    this.recoveryCost = 0,
    this.gymCost = 0,
    this.socialCost = 0,
    this.courseCost = 0,
    this.volunteerCost = 0,
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
    LifeProjectPlan(
      id: 'book',
      name: 'كتاب أو مدونة',
      description: 'كتابة منتظمة توثق خبرتك وتبني جمهورا وعلاقات.',
      durationMonths: 8,
      cost: 2000,
      effect: 'علاقات +15 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'home',
      name: 'بيت صغير',
      description: 'شراء بيت صغير بعد ادخار طويل، يخفف عبء السكن الشهري.',
      durationMonths: 18,
      cost: 12000,
      effect: 'مصروف شهري -200 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'garden',
      name: 'حديقة منزلية',
      description: 'زراعة خضروات في البيت تقلل مصروف الطعام الشهري.',
      durationMonths: 6,
      cost: 1500,
      effect: 'مصروف شهري -100 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'club',
      name: 'نادٍ مجتمعي',
      description: 'نشاط جماعي منتظم يبني صداقات ويحرك الجسم معا.',
      durationMonths: 9,
      cost: 2500,
      effect: 'علاقات +10 وصحة +5 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'app',
      name: 'تطبيق صغير',
      description:
          'تطبيق عملي صغير يبنيه اللاعب من مهارته، ثم يبيع اشتراكا بسيطا بعد إطلاقه.',
      durationMonths: 10,
      cost: 4000,
      effect: 'مهارة +10 ودخل شهري إضافي +300 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'kitchen',
      name: 'مطبخ صحي منزلي',
      description:
          'تجهيز مطبخ لطبخ صحي في البيت: أكل أفضل ومصروف طعام أقل معا.',
      durationMonths: 5,
      cost: 1800,
      effect: 'صحة +8 ومصروف شهري -50 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'community',
      name: 'مجتمع مهني',
      description:
          'بناء مجتمع مهني صغير: تعلّم من خبرات الآخرين وتبادل فرص معهم معا.',
      durationMonths: 7,
      cost: 3000,
      effect: 'مهارة +8 وعلاقات +8 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'coop',
      name: 'تعاونية حيّ',
      description:
          'مجموعة شراء تعاونية مع الجيران: تشترون معا بأسعار أقل وتتعرفون أكثر.',
      durationMonths: 8,
      cost: 2200,
      effect: 'علاقات +9 ومصروف شهري -75 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'first_aid',
      name: 'تدريب إسعاف ووقاية',
      description:
          'دورة إسعاف ووقاية صحية منظمة: مهارة عملية تنفعك وتنفع من حولك، وعادات صحية أفضل.',
      durationMonths: 6,
      cost: 2600,
      effect: 'مهارة +10 وصحة +6 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'delivery',
      name: 'خدمة توصيل للحيّ',
      description:
          'توصيل طلبات الجيران بانتظام: دخل إضافي شهري وعلاقات أقوى مع أهل الحيّ معا.',
      durationMonths: 8,
      cost: 2800,
      effect: 'علاقات +7 ودخل شهري إضافي +200 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'repair',
      name: 'ورشة إصلاح منزلية',
      description:
          'تعلّم إصلاح الأعطال المنزلية بنفسك: مهارة عملية ومصروف صيانة أقل معا.',
      durationMonths: 7,
      cost: 2400,
      effect: 'مهارة +8 ومصروف شهري -60 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'fitness_coach',
      name: 'تدريب لياقة للجيران',
      description:
          'تدريب جيرانك على اللياقة بانتظام: تحافظ على لياقتك وتكسب دخلا إضافيا معا.',
      durationMonths: 6,
      cost: 2000,
      effect: 'صحة +6 ودخل شهري إضافي +150 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'library',
      name: 'مكتبة حيّ',
      description:
          'مكتبة صغيرة مفتوحة للجيران: تقرأ معهم وتتبادلون الكتب، فتتعلم وتتعرف وتوفر ثمن شراء الكتب معا.',
      durationMonths: 9,
      cost: 2600,
      effect:
          'مهارة +5 وعلاقات +5 ومصروف شهري -40 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'summer_camp',
      name: 'مخيم صيفي للأطفال',
      description:
          'تنظيم مخيم صيفي لأطفال الحي: أنشطة بدنية وألعاب جماعية وتعلم عملي، فتتحرك وتتعرف وتتعلم معا.',
      durationMonths: 10,
      cost: 3200,
      effect: 'مهارة +5 وصحة +5 وعلاقات +5 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'healthy_cooking',
      name: 'دورة طبخ صحي للجيران',
      description:
          'تعليم جيرانك الطبخ الصحي أسبوعيا: تأكل أفضل، وتتعرف أكثر، وتكسب دخلا صغيرا من رسوم الدورة معا.',
      durationMonths: 9,
      cost: 3000,
      effect: 'صحة +5 وعلاقات +5 ودخل شهري إضافي +120 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'vocational_coaching',
      name: 'تدريب مهني للجيران',
      description:
          'تدريب جيرانك على مهارة عملية من خبرتك: تتقنها أكثر، وتتعرف أكثر، وتكسب دخلا صغيرا من رسوم التدريب معا.',
      durationMonths: 8,
      cost: 2800,
      effect: 'مهارة +4 وعلاقات +4 ودخل شهري إضافي +100 عند الاكتمال',
    ),
    LifeProjectPlan(
      id: 'green_cleanup',
      name: 'حملة نظافة وتشجير الحيّ',
      description:
          'تنظيف الحيّ وزراعة شتلات مع الجيران بانتظام: تتحرك في الهواء الطلق، وتتعرف أكثر، وتقل حاجتك لشراء نباتات وزينة للبيت معا.',
      durationMonths: 8,
      cost: 2400,
      effect: 'صحة +4 وعلاقات +4 ومصروف شهري -30 دائما من الشهر التالي للاكتمال',
    ),
    LifeProjectPlan(
      id: 'walking_cooking',
      name: 'مشي وطبخ صحي جماعي',
      description:
          'مشي جماعي أسبوعي مع تعلّم طبخ صحي: تتحرك أكثر، وتتقن وصفات صحية، وتقل حاجتك لشراء وجبات جاهزة معا.',
      durationMonths: 7,
      cost: 2700,
      effect: 'مهارة +5 وصحة +6 ومصروف شهري -45 دائما من الشهر التالي للاكتمال',
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
  bool overtime;
  bool recovery;
  bool gym;
  bool social;
  bool course;
  bool volunteer;
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
    this.overtime = false,
    this.recovery = false,
    this.gym = false,
    this.social = false,
    this.course = false,
    this.volunteer = false,
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
      1000 +
      time['work']! * 15 +
      skill * 3 +
      extraMonthlyIncome +
      (overtime ? 500 : 0) -
      (recovery ? 400 : 0) -
      (gym ? 250 : 0) -
      (social ? 300 : 0) -
      (course ? 350 : 0) -
      (volunteer ? 200 : 0);

  /// يشغّل العمل الإضافي للشهر التالي أو يطفئه. لا يغيّر الماضي،
  /// بل يظهر أثره في أول شهر يتقدم والخيار مشغّل. تشغيله يطفئ
  /// إجازة التعافي، فالخياران لا يجتمعان أبدا.
  void setOvertime(bool value) {
    overtime = value;
    if (value) recovery = false;
  }

  /// يشغّل إجازة التعافي للشهر التالي أو يطفئها. لا يغيّر الماضي،
  /// بل يظهر أثره في أول شهر يتقدم والخيار مشغّلا. تشغيلها يطفئ
  /// العمل الإضافي، فالخياران لا يجتمعان أبدا.
  void setRecovery(bool value) {
    recovery = value;
    if (value) overtime = false;
  }

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
      300 +
      (money['housing']! + money['food']! + money['leisure']!) * 8 -
      (completedProjectIds.contains('home') ? 200 : 0) -
      (completedProjectIds.contains('garden') ? 100 : 0) -
      (completedProjectIds.contains('kitchen') ? 50 : 0) -
      (completedProjectIds.contains('coop') ? 75 : 0) -
      (completedProjectIds.contains('repair') ? 60 : 0) -
      (completedProjectIds.contains('library') ? 40 : 0) -
      (completedProjectIds.contains('green_cleanup') ? 30 : 0) -
      (completedProjectIds.contains('walking_cooking') ? 45 : 0);

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
    var healthDelta = (time['health']! + time['rest']! - 25) ~/ 5;
    var relDelta = (time['relationships']! - 15) ~/ 5;
    final overtimeIncome = overtime ? 500 : 0;
    if (overtime) {
      healthDelta -= 5;
      relDelta -= 3;
    }
    final recoveryCost = recovery ? 400 : 0;
    if (recovery) {
      healthDelta += 6;
      relDelta += 2;
    }
    final gymCost = gym ? 250 : 0;
    if (gym) {
      healthDelta += 4;
    }
    final socialCost = social ? 300 : 0;
    if (social) {
      relDelta += 5;
      healthDelta -= 1;
    }
    final courseCost = course ? 350 : 0;
    if (course) {
      skillDelta += 2;
      healthDelta -= 1;
    }
    final volunteerCost = volunteer ? 200 : 0;
    if (volunteer) {
      relDelta += 4;
      healthDelta += 1;
    }

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
          case 'book':
            relationships = _clampScore(relationships + 15);
            projectLine =
                'اكتمل مشروع ${project.name}: العلاقات +15 (الآن $relationships).';
            break;
          case 'home':
            projectLine =
                'اكتمل مشروع ${project.name}: مصروف شهري -200 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'garden':
            projectLine =
                'اكتمل مشروع ${project.name}: مصروف شهري -100 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'club':
            relationships = _clampScore(relationships + 10);
            health = _clampScore(health + 5);
            projectLine =
                'اكتمل مشروع ${project.name}: العلاقات +10 (الآن $relationships) والصحة +5 (الآن $health).';
            break;
          case 'app':
            skill = _clampScore(skill + 10);
            extraMonthlyIncome += 300;
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +10 (الآن $skill) ودخل شهري إضافي دائم +300.';
            break;
          case 'kitchen':
            health = _clampScore(health + 8);
            projectLine =
                'اكتمل مشروع ${project.name}: الصحة +8 (الآن $health) ومصروف شهري -50 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'community':
            skill = _clampScore(skill + 8);
            relationships = _clampScore(relationships + 8);
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +8 (الآن $skill) والعلاقات +8 (الآن $relationships).';
            break;
          case 'coop':
            relationships = _clampScore(relationships + 9);
            projectLine =
                'اكتمل مشروع ${project.name}: العلاقات +9 (الآن $relationships) ومصروف شهري -75 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'first_aid':
            skill = _clampScore(skill + 10);
            health = _clampScore(health + 6);
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +10 (الآن $skill) والصحة +6 (الآن $health).';
            break;
          case 'delivery':
            relationships = _clampScore(relationships + 7);
            extraMonthlyIncome += 200;
            projectLine =
                'اكتمل مشروع ${project.name}: العلاقات +7 (الآن $relationships) ودخل شهري إضافي دائم +200.';
            break;
          case 'repair':
            skill = _clampScore(skill + 8);
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +8 (الآن $skill) ومصروف شهري -60 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'fitness_coach':
            health = _clampScore(health + 6);
            extraMonthlyIncome += 150;
            projectLine =
                'اكتمل مشروع ${project.name}: الصحة +6 (الآن $health) ودخل شهري إضافي دائم +150.';
            break;
          case 'library':
            skill = _clampScore(skill + 5);
            relationships = _clampScore(relationships + 5);
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +5 (الآن $skill) والعلاقات +5 (الآن $relationships) ومصروف شهري -40 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'summer_camp':
            skill = _clampScore(skill + 5);
            health = _clampScore(health + 5);
            relationships = _clampScore(relationships + 5);
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +5 (الآن $skill) والصحة +5 (الآن $health) والعلاقات +5 (الآن $relationships).';
            break;
          case 'healthy_cooking':
            health = _clampScore(health + 5);
            relationships = _clampScore(relationships + 5);
            extraMonthlyIncome += 120;
            projectLine =
                'اكتمل مشروع ${project.name}: الصحة +5 (الآن $health) والعلاقات +5 (الآن $relationships) ودخل شهري إضافي دائم +120.';
            break;
          case 'vocational_coaching':
            skill = _clampScore(skill + 4);
            relationships = _clampScore(relationships + 4);
            extraMonthlyIncome += 100;
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +4 (الآن $skill) والعلاقات +4 (الآن $relationships) ودخل شهري إضافي دائم +100.';
            break;
          case 'green_cleanup':
            health = _clampScore(health + 4);
            relationships = _clampScore(relationships + 4);
            projectLine =
                'اكتمل مشروع ${project.name}: الصحة +4 (الآن $health) والعلاقات +4 (الآن $relationships) ومصروف شهري -30 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
            break;
          case 'walking_cooking':
            skill = _clampScore(skill + 5);
            health = _clampScore(health + 6);
            projectLine =
                'اكتمل مشروع ${project.name}: المهارة +5 (الآن $skill) والصحة +6 (الآن $health) ومصروف شهري -45 دائما من الشهر التالي (المتوقع الآن $monthlyExpenses).';
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
      if (overtime)
        'عمل إضافي هذا الشهر: دخل +500، لكن الصحة -5 والعلاقات -3 من الإرهاق.',
      if (recovery)
        'إجازة تعافٍ هذا الشهر: دخل -400، لكن الصحة +6 والعلاقات +2 من الراحة.',
      if (gym)
        'عضوية نادٍ رياضي هذا الشهر: دخل -250، لكن الصحة +4 من التمرين المنتظم.',
      if (social)
        'لقاء اجتماعي هذا الشهر: دخل -300، لكن العلاقات +5 من التواصل المنتظم، والصحة -1 من السهر والإرهاق.',
      if (course)
        'دورة مهنية هذا الشهر: دخل -350، لكن المهارة +2 من الدراسة المكثفة، والصحة -1 من الجهد الإضافي.',
      if (volunteer)
        'تطوع مجتمعي هذا الشهر: دخل -200، لكن العلاقات +4 من خدمة الآخرين، والصحة +1 من النشاط والمعنى، فهو أرخص من اللقاء وأبطأ علاقات منه لكنه لا يرهقك.',
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
      overtimeIncome: overtimeIncome,
      recoveryCost: recoveryCost,
      gymCost: gymCost,
      socialCost: socialCost,
      courseCost: courseCost,
      volunteerCost: volunteerCost,
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
        'overtime': overtime,
        'recovery': recovery,
        'gym': gym,
        'social': social,
        'course': course,
        'volunteer': volunteer,
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
      overtime: j['overtime'] as bool? ?? false,
      recovery: j['recovery'] as bool? ?? false,
      gym: j['gym'] as bool? ?? false,
      social: j['social'] as bool? ?? false,
      course: j['course'] as bool? ?? false,
      volunteer: j['volunteer'] as bool? ?? false,
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
