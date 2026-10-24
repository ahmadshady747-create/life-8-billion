import 'dart:math';

import 'data/countries.dart';
import 'data/events.dart';
import 'models.dart';

/// محرك اللعبة: ولادة عشوائية، اختيار أحداث، تطبيق قرارات، وحساب النهاية.
/// لا يحفظ شيئا خارج الذاكرة؛ كل حياة جديدة عشوائية تماما.
class GameEngine {
  final Random _r = Random();
  late Person person;
  late Stats stats;
  int age = 0;
  int lifespan = 75;
  final Set<String> traits = {};
  final Set<String> usedEvents = {};
  final List<LogEntry> log = [];
  LifeEvent? currentEvent;
  EventChoice? lastChoice;
  bool isDead = false;
  String? deathCause;

  /// ولادة جديدة: دولة مرجحة بالسكان، اسم من أسماء تلك الدولة،
  /// جنس عشوائي، وطبقة عائلية تحدد نقطة بداية المال.
  void newLife() {
    final totalWeight = countries.fold<int>(0, (s, c) => s + c.weight);
    var roll = _r.nextInt(totalWeight);
    Country country = countries.first;
    for (final c in countries) {
      roll -= c.weight;
      if (roll < 0) {
        country = c;
        break;
      }
    }
    final isMale = _r.nextBool();
    final first = isMale
        ? country.maleNames[_r.nextInt(country.maleNames.length)]
        : country.femaleNames[_r.nextInt(country.femaleNames.length)];
    final last = country.surnames[_r.nextInt(country.surnames.length)];

    final familyRoll = _r.nextInt(100);
    final String familyClass;
    final int money;
    if (familyRoll < 35) {
      familyClass = 'عائلة فقيرة';
      money = 10 + _r.nextInt(16);
    } else if (familyRoll < 80) {
      familyClass = 'عائلة متوسطة';
      money = 35 + _r.nextInt(26);
    } else {
      familyClass = 'عائلة ميسورة';
      money = 65 + _r.nextInt(26);
    }

    person = Person(
      firstName: first,
      lastName: last,
      country: country.name,
      flag: country.flag,
      isMale: isMale,
      birthYear: DateTime.now().year,
      familyClass: familyClass,
    );
    stats = Stats.random(_r, money: money);
    age = 0;
    traits.clear();
    usedEvents.clear();
    log.clear();
    currentEvent = null;
    lastChoice = null;
    isDead = false;
    deathCause = null;
    // العمر المتوقع: صحة البداية تؤثر، مع عشوائية واسعة، كما في الحياة.
    lifespan = (68 + (stats.health - 50) ~/ 4 + _r.nextInt(36) - 15)
        .clamp(50, 102);
    currentEvent = pickNextEvent();
  }

  /// اختيار الحدث التالي المناسب للعمر والسمات، دون تكرار.
  LifeEvent pickNextEvent() {
    final pool = [...allEvents, ...laterEvents];
    final candidates =
        pool.where((ev) => ev.fits(age, traits, usedEvents)).toList();
    if (candidates.isEmpty) return genericEvent(age);
    candidates.shuffle(_r);
    final chosen = candidates.first;
    usedEvents.add(chosen.id);
    return chosen;
  }

  /// تطبيق خيار اللاعب: إحصاءات، سمات، سجل، وتقدم العمر.
  /// تعيد النص الذي يُعرض في شاشة النتيجة.
  String applyChoice(EventChoice choice) {
    final event = currentEvent;
    if (event != null) {
      log.add(LogEntry(
        age: age,
        title: event.title,
        choice: choice.text,
        outcome: choice.outcome,
      ));
    }
    stats.apply(choice.effect);
    traits.addAll(choice.addTraits);
    traits.removeAll(choice.removeTraits);
    lastChoice = choice;

    if (choice.deathCause != null) {
      isDead = true;
      deathCause = choice.deathCause;
      return choice.outcome;
    }
    age += choice.ageJump;
    if (age >= lifespan) {
      isDead = true;
      deathCause = 'وفاة طبيعية بعد عمر طويل';
      if (stats.health < 25) {
        deathCause = 'تدهور صحي بعد سنوات من الإهمال';
      }
      return choice.outcome;
    }
    return choice.outcome;
  }

  /// الانتقال للحدث التالي بعد عرض النتيجة.
  void nextEvent() {
    lastChoice = null;
    if (!isDead) currentEvent = pickNextEvent();
  }

  /// نص القصة كاملا، للنسخ والمشاركة.
  String storyText() {
    final b = StringBuffer();
    b.writeln('حياة ${person.fullName} (${person.flag} ${person.country})');
    b.writeln('وُلد سنة ${person.birthYear} في ${person.familyClass}.');
    b.writeln('عاش حتى عمر $age سنة. سبب الوفاة: ${deathCause ?? '—'}.');
    b.writeln();
    for (final entry in log) {
      b.writeln('• عمر ${entry.age}: ${entry.title}');
      b.writeln('  قرار: ${entry.choice}');
      b.writeln('  ${entry.outcome}');
    }
    return b.toString();
  }
}
