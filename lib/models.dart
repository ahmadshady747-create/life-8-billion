import 'dart:math';

/// إحصاءات الشخصية السبع. كل قيمة بين 0 و 100.
/// المال هنا مستوى ثروة عام، أما الرصيد النقدي الفعلي فيحفظه المحرك.
class Stats {
  int health;
  int happiness;
  int smarts;
  int money;
  int social;
  int skill;
  int reputation;

  Stats({
    required this.health,
    required this.happiness,
    required this.smarts,
    required this.money,
    required this.social,
    required this.skill,
    required this.reputation,
  });

  factory Stats.random(Random r, {required int money}) {
    return Stats(
      health: 60 + r.nextInt(36),
      happiness: 50 + r.nextInt(36),
      smarts: 40 + r.nextInt(46),
      money: money,
      social: 45 + r.nextInt(41),
      skill: 20 + r.nextInt(41),
      reputation: 40 + r.nextInt(31),
    );
  }

  void apply(Effect e) {
    health = _clamp(health + e.health);
    happiness = _clamp(happiness + e.happiness);
    smarts = _clamp(smarts + e.smarts);
    money = _clamp(money + e.money);
    social = _clamp(social + e.social);
    skill = _clamp(skill + e.skill);
    reputation = _clamp(reputation + e.reputation);
  }

  static int _clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);

  List<(String label, String icon, int value)> asList() => [
        ('الصحة', '❤️', health),
        ('السعادة', '😊', happiness),
        ('الذكاء', '🧠', smarts),
        ('المال', '💰', money),
        ('العلاقات', '🤝', social),
        ('المهارة', '🛠️', skill),
        ('السمعة', '⭐', reputation),
      ];

  Map<String, int> toJson() => {
        'health': health,
        'happiness': happiness,
        'smarts': smarts,
        'money': money,
        'social': social,
        'skill': skill,
        'reputation': reputation,
      };

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        health: (j['health'] as num).toInt(),
        happiness: (j['happiness'] as num).toInt(),
        smarts: (j['smarts'] as num).toInt(),
        money: (j['money'] as num).toInt(),
        social: (j['social'] as num).toInt(),
        skill: (j['skill'] as num?)?.toInt() ?? 30,
        reputation: (j['reputation'] as num?)?.toInt() ?? 50,
      );
}

/// أثر خيار واحد على الإحصاءات.
class Effect {
  final int health;
  final int happiness;
  final int smarts;
  final int money;
  final int social;
  final int skill;
  final int reputation;

  const Effect({
    this.health = 0,
    this.happiness = 0,
    this.smarts = 0,
    this.money = 0,
    this.social = 0,
    this.skill = 0,
    this.reputation = 0,
  });

  bool get isEmpty =>
      health == 0 &&
      happiness == 0 &&
      smarts == 0 &&
      money == 0 &&
      social == 0 &&
      skill == 0 &&
      reputation == 0;

  /// نص مختصر للتغيرات، مثل: +10 سعادة، -5 مال.
  String describe() {
    final parts = <String>[];
    void add(int v, String label) {
      if (v != 0) parts.add('${v > 0 ? '+' : ''}$v $label');
    }

    add(health, 'صحة');
    add(happiness, 'سعادة');
    add(smarts, 'ذكاء');
    add(money, 'مال');
    add(social, 'علاقات');
    add(skill, 'مهارة');
    add(reputation, 'سمعة');
    return parts.join('، ');
  }
}

/// تغيّر فعلي واحد في إحصاءة بعد تطبيق خيار، محسوبا بعد التقريب
/// إلى حدود 0-100، لا مجرد الرقم المقصود: فـ +10 صحة عند 98 تعني
/// فعليا +2 فقط، واللاعب يجب أن يرى القيمة الجديدة لا الوعد.
class StatChange {
  final String label;
  final String icon;
  final int delta;
  final int newValue;

  const StatChange({
    required this.label,
    required this.icon,
    required this.delta,
    required this.newValue,
  });
}

/// ملخص حقيقي لما تغيّر بعد قرار واحد، يُبنى في المحرك بمقارنة
/// ما قبل التطبيق بما بعده: إحصاءات، رصيد بتفصيله، نقاط مهارة،
/// سمات، وظيفة، طموح، أطفال، وإنجازات جديدة. لا شيء هنا تقديري.
class OutcomeSummary {
  final List<StatChange> statChanges;
  final int balanceBefore;
  final int balanceAfter;
  final int cashDelta;
  final int yearlyDelta;
  final int years;
  final int skillPointsDelta;
  final List<String> traitsAdded;
  final List<String> traitsRemoved;
  final String? jobBefore;
  final String? jobAfter;
  final String? ambitionAfter;
  final int childrenDelta;
  final List<String> newAchievements;

  const OutcomeSummary({
    required this.statChanges,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.cashDelta,
    required this.yearlyDelta,
    required this.years,
    required this.skillPointsDelta,
    required this.traitsAdded,
    required this.traitsRemoved,
    required this.jobBefore,
    required this.jobAfter,
    required this.ambitionAfter,
    required this.childrenDelta,
    required this.newAchievements,
  });
}

/// خيار واحد داخل حدث.
class EventChoice {
  final String text;
  final String outcome;
  final Effect effect;
  final List<String> addTraits;
  final List<String> removeTraits;
  final int ageJump;
  final String? deathCause;

  /// طموح حياة يختاره اللاعب مرة واحدة (مثل 'wealth' أو 'family').
  final String? ambition;

  /// وظيفة جديدة يبدأها هذا الخيار، مع راتب سنوي تقريبي بوحدات اللعبة.
  final String? job;
  final int jobSalary;

  /// تغير مباشر في الرصيد النقدي (ربح استثمار، دين، شراء...).
  final int cash;

  /// الفصل التالي في قصة متسلسلة، إن كان هذا الخيار يفتح واحدا.
  /// بهذا لا ينتهي القرار عند نتيجته، بل يحدد ما سيحدث بعد سنة.
  final String? nextId;

  /// تغيّر في علاقة مع شخصية (معرّفها في خريطة علاقات المحرك)،
  /// مثل 'friend' بزيادة أو نقصان. يُطبَّق مع باقي آثار الخيار.
  final String? relId;
  final int relDelta;

  /// نقاط مهارة مهنية يمنحها هذا الخيار مباشرة (تدريب، ترقية...).
  final int skillPoints;

  const EventChoice({
    required this.text,
    required this.outcome,
    this.effect = const Effect(),
    this.addTraits = const [],
    this.removeTraits = const [],
    this.ageJump = 2,
    this.deathCause,
    this.ambition,
    this.job,
    this.jobSalary = 0,
    this.cash = 0,
    this.nextId,
    this.relId,
    this.relDelta = 0,
    this.skillPoints = 0,
  });
}

/// حدث واحد في حياة الشخص.
/// حقول المنطقة والاقتصاد تخص الأحداث العالمية فقط: فحدث حرب إقليمية
/// مثلا لا يناسب إلا من يعيش في ذلك الإقليم، وحدث أزمة اقتصادية يضرب
/// أكثر من يعيش في اقتصاد هش.
class LifeEvent {
  final String id;
  final int minAge;
  final int maxAge;
  final String title;
  final String story;
  final List<EventChoice> choices;
  final String? requiresTrait;
  final String? forbidsTrait;
  final String? region;
  final int? maxEconomy;
  final int? minEconomy;
  final bool isWorld;

  /// فصل في قصة متسلسلة، واسم القصة لعرضه في الواجهة.
  final bool isArcChapter;
  final String? arcName;

  const LifeEvent({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.title,
    required this.story,
    required this.choices,
    this.requiresTrait,
    this.forbidsTrait,
    this.region,
    this.maxEconomy,
    this.minEconomy,
    this.isWorld = false,
    this.isArcChapter = false,
    this.arcName,
  });

  bool fits(
    int age,
    Set<String> traits,
    Set<String> used, {
    String? personRegion,
    int? personEconomy,
  }) {
    if (used.contains(id)) return false;
    if (age < minAge || age > maxAge) return false;
    if (requiresTrait != null && !traits.contains(requiresTrait)) return false;
    if (forbidsTrait != null && traits.contains(forbidsTrait)) return false;
    if (region != null && region != personRegion) return false;
    final maxEco = maxEconomy;
    if (maxEco != null && personEconomy != null && personEconomy > maxEco) {
      return false;
    }
    final minEco = minEconomy;
    if (minEco != null && personEconomy != null && personEconomy < minEco) {
      return false;
    }
    return true;
  }
}

/// دولة للولادة العشوائية.
/// الأرقام الأربعة الأخيرة ملف سياسات مبسّط لأغراض اللعب فقط (0-100)،
/// وليست بيانات رسمية: اقتصاد قوي يعني رواتب أعلى وأزمات أخف،
/// ورعاية صحية قوية تعني علاجا أرخص وأمراضا أخف، وأمان عالٍ يعني
/// حروبا وجرائم أقل، وتعليم قوي يعني دراسة أرخص وأفضل.
class Country {
  final String name;
  final String flag;
  final int weight;
  final List<String> maleNames;
  final List<String> femaleNames;
  final List<String> surnames;
  final String region;
  final int economy;
  final int healthcare;
  final int safety;
  final int education;

  const Country({
    required this.name,
    required this.flag,
    required this.weight,
    required this.maleNames,
    required this.femaleNames,
    required this.surnames,
    required this.region,
    required this.economy,
    required this.healthcare,
    required this.safety,
    required this.education,
  });
}

/// الشخصية المولودة عشوائيا.
class Person {
  final String firstName;
  final String lastName;
  final String country;
  final String flag;
  final bool isMale;
  final int birthYear;
  final String familyClass;

  const Person({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.flag,
    required this.isMale,
    required this.birthYear,
    required this.familyClass,
  });

  String get fullName => '$firstName $lastName';
  String get genderLabel => isMale ? 'ذكر' : 'أنثى';

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        'flag': flag,
        'isMale': isMale,
        'birthYear': birthYear,
        'familyClass': familyClass,
      };

  factory Person.fromJson(Map<String, dynamic> j) => Person(
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        country: j['country'] as String,
        flag: j['flag'] as String,
        isMale: j['isMale'] as bool,
        birthYear: (j['birthYear'] as num).toInt(),
        familyClass: j['familyClass'] as String,
      );
}

/// شخصية في حياة اللاعب بدرجة علاقة تتغير بالقرارات.
/// الدرجة بين -100 (عداوة) و+100 (ولاء عميق)، وتبدأ حول الصفر.
class Relationship {
  final String id;
  final String name;
  final String role;
  final String icon;
  int score;

  Relationship({
    required this.id,
    required this.name,
    required this.role,
    required this.icon,
    this.score = 0,
  });

  String get label {
    if (score <= -60) return 'عدو لدود';
    if (score <= -20) return 'علاقة متوترة';
    if (score < 20) return 'معرفة عابرة';
    if (score < 60) return 'صديق جيد';
    return 'رفيق عمر';
  }

  void change(int delta) {
    score = (score + delta).clamp(-100, 100);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'icon': icon,
        'score': score,
      };

  factory Relationship.fromJson(Map<String, dynamic> j) => Relationship(
        id: j['id'] as String,
        name: j['name'] as String,
        role: j['role'] as String,
        icon: j['icon'] as String,
        score: (j['score'] as num).toInt(),
      );
}

/// سطر واحد في سجل الحياة.
class LogEntry {
  final int age;
  final String title;
  final String choice;
  final String outcome;

  const LogEntry({
    required this.age,
    required this.title,
    required this.choice,
    required this.outcome,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'title': title,
        'choice': choice,
        'outcome': outcome,
      };

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
        age: (j['age'] as num).toInt(),
        title: j['title'] as String,
        choice: j['choice'] as String,
        outcome: j['outcome'] as String,
      );
}

/// طموحات الحياة التي يختار منها اللاعب واحدا في شبابه.
const ambitionLabels = {
  'wealth': 'طموح الثروة',
  'fame': 'طموح الشهرة',
  'knowledge': 'طموح العلم',
  'family': 'طموح العائلة',
  'travel': 'طموح السفر',
};

/// الإنجازات القابلة للفتح خلال الحياة.
const achievementLabels = {
  'age50': '🏅 عاش 50 سنة',
  'age80': '🏆 عاش 80 سنة',
  'graduate': '🎓 تخرّج من الجامعة',
  'married': '💍 تزوّج',
  'parent': '👶 أنجب طفلا',
  'grandparent': '👴 صار جدّا',
  'business': '🏢 أسس عمله الخاص',
  'rich': '💰 بلغ ثروة 90 أو أكثر',
  'traveler': '✈️ سافر وعاش المغامرة',
  'healthy': '💪 حافظ على صحة 90 أو أكثر',
  'famous': '⭐ بلغ سمعة 90 أو أكثر',
  'survivor': '🛡️ نجا من أزمة عالمية',
};

String stageLabel(int age) {
  if (age < 6) return 'طفولة مبكرة';
  if (age < 13) return 'طفولة';
  if (age < 18) return 'مراهقة';
  if (age < 30) return 'شباب';
  if (age < 50) return 'نضج';
  if (age < 65) return 'منتصف العمر';
  return 'شيخوخة';
}

String stageEmoji(int age, bool isMale) {
  if (age < 3) return '👶';
  if (age < 13) return isMale ? '👦' : '👧';
  if (age < 30) return isMale ? '🧑' : '👩';
  if (age < 65) return isMale ? '👨' : '👩';
  return isMale ? '👴' : '👵';
}

/// أسماء السمات بالعربية لعرضها كشارات.
const traitLabels = {
  'student': 'طالب',
  'graduate': 'خريج',
  'employed': 'موظف',
  'partner': 'في علاقة',
  'married': 'متزوج',
  'parent': 'أب / أم',
  'business': 'صاحب عمل',
  'traveler': 'محب للسفر',
  'retired': 'متقاعد',
  'grandparent': 'جد / جدة',
  'chronic': 'مرض مزمن',
};
