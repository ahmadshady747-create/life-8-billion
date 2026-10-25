import 'dart:math';

import 'data/arcs.dart';
import 'data/career_events.dart';
import 'data/countries.dart';
import 'data/deep_events.dart';
import 'data/events.dart';
import 'data/relationships.dart';
import 'data/world_events.dart';
import 'data/yearly_events.dart';
import 'models.dart';

/// محرك اللعبة، النسخة العميقة.
/// الأنظمة المتشابكة:
/// - دولة بملف سياسات (اقتصاد، رعاية صحية، أمان، تعليم) يغيّر الرواتب
///   وتكاليف العلاج وشدة الأزمات.
/// - وظيفة وراتب سنوي ومصاريف ورصيد نقدي يتراكم عبر السنوات.
/// - طموح حياة يختاره اللاعب ويُقاس تحققه عند الموت.
/// - إنجازات تُفتح عبر الحياة، ونقاط حياة نهائية.
/// - أحداث عالمية كل بضع سنوات، تعتمد على إقليم بلدك وقوة اقتصاده.
/// - حفظ كامل للحياة في ملف JSON لاستئنافها لاحقا.
class GameEngine {
  GameEngine();

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

  int balance = 0;
  String? jobTitle;
  int jobSalary = 0;

  /// نقاط مهارة مهنية تُجمع سنويا أثناء العمل وتمنحها بعض القرارات.
  /// تفتح مستويات مهنية ترفع الراتب فعليا، لا مجرد سمة.
  int skillPoints = 0;

  /// المستوى المهني من نقاط المهارة: مبتدئ، محترف، خبير، قائد.
  /// القائد يشترط سمعة 40 على الأقل: الخبرة وحدها لا تكفي لقيادة الناس،
  /// وقد تفقد المنصب إن سقطت سمعتك — هذا هو الواقع الفوضوي.
  int get careerTierIndex {
    if (skillPoints >= 70 && stats.reputation >= 40) return 3;
    if (skillPoints >= 35) return 2;
    if (skillPoints >= 12) return 1;
    return 0;
  }

  String get careerTier =>
      const ['مبتدئ', 'محترف', 'خبير', 'قائد'][careerTierIndex];

  double get careerMultiplier =>
      const [1.0, 1.25, 1.6, 2.1][careerTierIndex];

  /// الراتب الفعلي بعد مضاعف المستوى المهني.
  int get effectiveSalary => (jobSalary * careerMultiplier).round();

  /// نقاط المستوى التالي، أو null إن بلغت القمة.
  int? get nextTierPoints {
    switch (careerTierIndex) {
      case 0:
        return 12;
      case 1:
        return 35;
      case 2:
        return 70;
      default:
        return null;
    }
  }
  int childrenCount = 0;
  String? ambition;
  final Set<String> achievements = {};
  int lastWorldAge = -99;

  /// شخصيات بذاكرة: درجة علاقة تتغير بالقرارات وتظهر في الواجهة.
  final Map<String, Relationship> relationships = {};

  /// سلسلة القصص: الفصل التالي المفروض، إن وجد.
  String? pendingNextId;

  /// بعد حدث مصيري، تأتي سنة تدبير قبل الحدث المصيري التالي.
  bool yearlyTurn = false;

  Country get country =>
      countries.firstWhere((c) => c.name == person.country, orElse: () => countries.first);

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
    final int startBalance;
    if (familyRoll < 35) {
      familyClass = 'عائلة فقيرة';
      money = 10 + _r.nextInt(16);
      startBalance = 500;
    } else if (familyRoll < 80) {
      familyClass = 'عائلة متوسطة';
      money = 35 + _r.nextInt(26);
      startBalance = 5000;
    } else {
      familyClass = 'عائلة ميسورة';
      money = 65 + _r.nextInt(26);
      startBalance = 20000;
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
    relationships.clear();
    relationships['friend'] = Relationship(
      id: 'friend',
      name:
          '${country.maleNames[_r.nextInt(country.maleNames.length)]} ${country.surnames[_r.nextInt(country.surnames.length)]}',
      role: 'صديق الطفولة',
      icon: '👦',
      score: 20,
    );
    relationships['mentor'] = Relationship(
      id: 'mentor',
      name:
          '${country.maleNames[_r.nextInt(country.maleNames.length)]} ${country.surnames[_r.nextInt(country.surnames.length)]}',
      role: 'معلم قديم',
      icon: '🧑‍🏫',
      score: 10,
    );
    relationships['rival'] = Relationship(
      id: 'rival',
      name:
          '${country.maleNames[_r.nextInt(country.maleNames.length)]} ${country.surnames[_r.nextInt(country.surnames.length)]}',
      role: 'منافس',
      icon: '😤',
      score: -10,
    );
    currentEvent = null;
    lastChoice = null;
    isDead = false;
    deathCause = null;
    balance = startBalance;
    jobTitle = null;
    jobSalary = 0;
    skillPoints = 0;
    childrenCount = 0;
    ambition = null;
    achievements.clear();
    lastWorldAge = -99;
    pendingNextId = null;
    yearlyTurn = false;
    lifespan = (68 + (stats.health - 50) ~/ 4 + _r.nextInt(36) - 15)
        .clamp(50, 102);
    currentEvent = pickNextEvent();
  }

  List<LifeEvent> get _personalPool => [
        ...allEvents,
        ...laterEvents,
        ...deepEvents,
        ...relationshipEvents,
        ...arcStarters,
        ...careerEvents,
      ];

  LifeEvent _findEvent(String id) {
    for (final ev in [..._personalPool, ...worldEvents, ...arcChapters]) {
      if (ev.id == id) return ev;
    }
    return genericEvent(age);
  }

  LifeEvent pickNextEvent() {
    // 1. فصل قصة متسلسلة: يفرض نفسه، ولا يُختار عشوائيا.
    // إن كان الفصل يشترط سمة لا تملكها، جرّب نسخته البديلة (_alt).
    if (pendingNextId != null) {
      final id = pendingNextId!;
      pendingNextId = null;
      var candidate = _findEvent(id);
      final blocked = (candidate.requiresTrait != null &&
              !traits.contains(candidate.requiresTrait)) ||
          (candidate.forbidsTrait != null &&
              traits.contains(candidate.forbidsTrait));
      if (blocked) {
        final alt = _findEvent('${id}_alt');
        if (alt.id == '${id}_alt') candidate = alt;
      }
      usedEvents.add(candidate.id);
      return candidate;
    }
    // 2. سنة تدبير بين الأحداث المصيرية.
    if (yearlyTurn && age >= 6) {
      yearlyTurn = false;
      return yearlyEventForAge(age);
    }
    yearlyTurn = false;
    // حدث عالمي كل 7 سنوات على الأقل بعد سن 18، باحتمال 65%.
    if (age >= 18 && age - lastWorldAge >= 7 && _r.nextDouble() < 0.65) {
      final worldCandidates = worldEvents
          .where((ev) => ev.fits(age, traits, usedEvents,
              personRegion: country.region, personEconomy: country.economy))
          .toList();
      if (worldCandidates.isNotEmpty) {
        worldCandidates.shuffle(_r);
        lastWorldAge = age;
        final chosen = worldCandidates.first;
        usedEvents.add(chosen.id);
        return chosen;
      }
    }
    final candidates = _personalPool
        .where((ev) => ev.fits(age, traits, usedEvents))
        .toList();
    if (candidates.isEmpty) return genericEvent(age);
    candidates.shuffle(_r);
    final chosen = candidates.first;
    usedEvents.add(chosen.id);
    return chosen;
  }

  String applyChoice(EventChoice choice) {
    final event = currentEvent;
    final wasWorld = event?.isWorld ?? false;
    // القصة المتسلسلة تستمر، وسنة التدبير لا تتكرر مرتين متتاليتين،
    // وكل حدث مصيري آخر يتبعه سنة تدبير.
    pendingNextId = choice.nextId;
    if (choice.nextId != null) {
      yearlyTurn = false;
    } else if (event != null && event.id.startsWith('yearly_')) {
      yearlyTurn = false;
    } else {
      yearlyTurn = true;
    }
    if (event != null) {
      log.add(LogEntry(
        age: age,
        title: event.title,
        choice: choice.text,
        outcome: choice.outcome,
      ));
    }
    final hadParent = traits.contains('parent');
    stats.apply(choice.effect);
    skillPoints += choice.skillPoints;
    if (choice.relId != null) {
      relationships[choice.relId]?.change(choice.relDelta);
    }
    traits.addAll(choice.addTraits);
    traits.removeAll(choice.removeTraits);
    if (choice.addTraits.contains('parent')) {
      childrenCount = hadParent ? childrenCount + 1 : 1;
    }
    if (choice.ambition != null) ambition = choice.ambition;
    if (choice.job != null) {
      jobTitle = choice.job;
      // الراتب يتأثر باقتصاد الدولة: اقتصاد قوي يعني أجورا أعلى.
      jobSalary = (choice.jobSalary * (0.4 + country.economy / 100)).round();
      traits.add('employed');
    }
    if (traits.contains('employed') && jobSalary == 0) {
      jobTitle ??= 'موظف';
      jobSalary = (30000 * (0.4 + country.economy / 100)).round();
    }
    if (choice.removeTraits.contains('employed')) {
      jobTitle = null;
      jobSalary = 0;
    }

    // الاقتصاد السنوي: دخل ناقص مصاريف، مضروب في سنوات القفزة.
    // المصاريف أعلى في الاقتصادات القوية، والعلاج أرخص حيث الرعاية قوية.
    final years = choice.ageJump;
    var yearly = 0;
    if (traits.contains('employed') && jobSalary > 0) {
      // الراتب الفعلي يتضاعف مع المستوى المهني، لا الراتب الأساسي وحده.
      yearly += effectiveSalary;
      // نقاط مهارة سنوية: سنة عمل تمنح نقطة أو أكثر حسب مهارتك الحالية.
      skillPoints += years * (1 + stats.skill ~/ 50);
    }
    var expenses = (15000 * (0.5 + country.economy / 100)).round();
    if (traits.contains('chronic')) {
      expenses += (4000 * (2 - country.healthcare / 100)).round();
    }
    yearly -= expenses;
    balance += choice.cash + yearly * years;
    lastChoice = choice;

    if (wasWorld && choice.deathCause == null) {
      achievements.add('survivor');
    }
    _checkAchievements();

    if (choice.deathCause != null) {
      isDead = true;
      deathCause = choice.deathCause;
      return choice.outcome;
    }
    age += years;
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

  void _checkAchievements() {
    if (age >= 50) achievements.add('age50');
    if (age >= 80) achievements.add('age80');
    if (traits.contains('graduate')) achievements.add('graduate');
    if (traits.contains('married')) achievements.add('married');
    if (traits.contains('parent')) achievements.add('parent');
    if (traits.contains('grandparent')) achievements.add('grandparent');
    if (traits.contains('business')) achievements.add('business');
    if (traits.contains('traveler')) achievements.add('traveler');
    if (stats.money >= 90) achievements.add('rich');
    if (stats.health >= 90) achievements.add('healthy');
    if (stats.reputation >= 90) achievements.add('famous');
  }

  bool get ambitionAchieved {
    switch (ambition) {
      case 'wealth':
        return balance >= 150000 || stats.money >= 90;
      case 'fame':
        return stats.reputation >= 85;
      case 'knowledge':
        return stats.smarts >= 85 && stats.skill >= 70;
      case 'family':
        return traits.contains('married') && childrenCount >= 2;
      case 'travel':
        return traits.contains('traveler') && stats.social >= 70;
      default:
        return false;
    }
  }

  int get lifeScore {
    final avg = (stats.health +
            stats.happiness +
            stats.smarts +
            stats.money +
            stats.social +
            stats.skill +
            stats.reputation) ~/
        7;
    return age +
        avg +
        achievements.length * 8 +
        (ambitionAchieved ? 30 : 0) +
        (balance >= 100000 ? 10 : 0);
  }

  void nextEvent() {
    lastChoice = null;
    if (!isDead) currentEvent = pickNextEvent();
  }

  String storyText() {
    final b = StringBuffer();
    b.writeln('حياة ${person.fullName} (${person.flag} ${person.country})');
    b.writeln('وُلد سنة ${person.birthYear} في ${person.familyClass}.');
    b.writeln('عاش حتى عمر $age سنة. سبب الوفاة: ${deathCause ?? '—'}.');
    if (ambition != null) {
      b.writeln('طموحه: ${ambitionLabels[ambition]} — ${ambitionAchieved ? 'تحقق ✓' : 'لم يتحقق'}');
    }
    b.writeln('نقاط الحياة: $lifeScore. الإنجازات: ${achievements.length}.');
    b.writeln();
    for (final entry in log) {
      b.writeln('• عمر ${entry.age}: ${entry.title}');
      b.writeln('  قرار: ${entry.choice}');
      b.writeln('  ${entry.outcome}');
    }
    return b.toString();
  }

  Map<String, dynamic> toJson() => {
        'person': person.toJson(),
        'stats': stats.toJson(),
        'age': age,
        'lifespan': lifespan,
        'traits': traits.toList(),
        'usedEvents': usedEvents.toList(),
        'log': log.map((e) => e.toJson()).toList(),
        'isDead': isDead,
        'deathCause': deathCause,
        'balance': balance,
        'jobTitle': jobTitle,
        'jobSalary': jobSalary,
        'skillPoints': skillPoints,
        'childrenCount': childrenCount,
        'ambition': ambition,
        'achievements': achievements.toList(),
        'lastWorldAge': lastWorldAge,
        'pendingNextId': pendingNextId,
        'yearlyTurn': yearlyTurn,
        'relationships': relationships.values.map((r) => r.toJson()).toList(),
        'currentEventId': currentEvent?.id,
      };

  factory GameEngine.fromJson(Map<String, dynamic> j) {
    final engine = GameEngine();
    engine.person = Person.fromJson(Map<String, dynamic>.from(j['person'] as Map));
    engine.stats = Stats.fromJson(Map<String, dynamic>.from(j['stats'] as Map));
    engine.age = (j['age'] as num).toInt();
    engine.lifespan = (j['lifespan'] as num).toInt();
    engine.traits.addAll((j['traits'] as List).map((e) => e as String));
    engine.usedEvents.addAll((j['usedEvents'] as List).map((e) => e as String));
    engine.log.addAll((j['log'] as List).map(
        (e) => LogEntry.fromJson(Map<String, dynamic>.from(e as Map))));
    engine.isDead = j['isDead'] as bool;
    engine.deathCause = j['deathCause'] as String?;
    engine.balance = (j['balance'] as num).toInt();
    engine.jobTitle = j['jobTitle'] as String?;
    engine.jobSalary = (j['jobSalary'] as num).toInt();
    engine.skillPoints = (j['skillPoints'] as num?)?.toInt() ?? 0;
    engine.childrenCount = (j['childrenCount'] as num).toInt();
    engine.ambition = j['ambition'] as String?;
    engine.achievements
        .addAll((j['achievements'] as List).map((e) => e as String));
    engine.lastWorldAge = (j['lastWorldAge'] as num).toInt();
    engine.pendingNextId = j['pendingNextId'] as String?;
    engine.yearlyTurn = j['yearlyTurn'] as bool? ?? false;
    final rels = j['relationships'] as List?;
    if (rels != null) {
      for (final r in rels) {
        final rel = Relationship.fromJson(Map<String, dynamic>.from(r as Map));
        engine.relationships[rel.id] = rel;
      }
    }
    final eventId = j['currentEventId'] as String?;
    if (eventId != null && !engine.isDead) {
      engine.currentEvent = eventId.startsWith('yearly_')
          ? yearlyEventForAge(engine.age)
          : engine._findEvent(eventId);
    }
    return engine;
  }
}
