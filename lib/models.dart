import 'dart:math';

/// إحصاءات الشخصية الخمس. كل قيمة بين 0 و 100.
class Stats {
  int health;
  int happiness;
  int smarts;
  int money;
  int social;

  Stats({
    required this.health,
    required this.happiness,
    required this.smarts,
    required this.money,
    required this.social,
  });

  factory Stats.random(Random r, {required int money}) {
    return Stats(
      health: 60 + r.nextInt(36),
      happiness: 50 + r.nextInt(36),
      smarts: 40 + r.nextInt(46),
      money: money,
      social: 45 + r.nextInt(41),
    );
  }

  void apply(Effect e) {
    health = _clamp(health + e.health);
    happiness = _clamp(happiness + e.happiness);
    smarts = _clamp(smarts + e.smarts);
    money = _clamp(money + e.money);
    social = _clamp(social + e.social);
  }

  static int _clamp(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);

  List<(String label, String icon, int value)> asList() => [
        ('الصحة', '❤️', health),
        ('السعادة', '😊', happiness),
        ('الذكاء', '🧠', smarts),
        ('المال', '💰', money),
        ('العلاقات', '🤝', social),
      ];
}

/// أثر خيار واحد على الإحصاءات.
class Effect {
  final int health;
  final int happiness;
  final int smarts;
  final int money;
  final int social;

  const Effect({
    this.health = 0,
    this.happiness = 0,
    this.smarts = 0,
    this.money = 0,
    this.social = 0,
  });

  bool get isEmpty =>
      health == 0 && happiness == 0 && smarts == 0 && money == 0 && social == 0;

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
    return parts.join('، ');
  }
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

  const EventChoice({
    required this.text,
    required this.outcome,
    this.effect = const Effect(),
    this.addTraits = const [],
    this.removeTraits = const [],
    this.ageJump = 2,
    this.deathCause,
  });
}

/// حدث واحد في حياة الشخص.
class LifeEvent {
  final String id;
  final int minAge;
  final int maxAge;
  final String title;
  final String story;
  final List<EventChoice> choices;
  final String? requiresTrait;
  final String? forbidsTrait;

  const LifeEvent({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.title,
    required this.story,
    required this.choices,
    this.requiresTrait,
    this.forbidsTrait,
  });

  bool fits(int age, Set<String> traits, Set<String> used) {
    if (used.contains(id)) return false;
    if (age < minAge || age > maxAge) return false;
    if (requiresTrait != null && !traits.contains(requiresTrait)) return false;
    if (forbidsTrait != null && traits.contains(forbidsTrait)) return false;
    return true;
  }
}

/// دولة للولادة العشوائية.
class Country {
  final String name;
  final String flag;
  final int weight;
  final List<String> maleNames;
  final List<String> femaleNames;
  final List<String> surnames;

  const Country({
    required this.name,
    required this.flag,
    required this.weight,
    required this.maleNames,
    required this.femaleNames,
    required this.surnames,
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
}

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
