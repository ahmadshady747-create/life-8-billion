import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/career_events.dart';
import 'package:life_8_billion/data/relationships.dart';
import 'package:life_8_billion/game_engine.dart';

void main() {
  test('حياة كاملة تنتهي بوفاة وسجل غير فارغ', () {
    final engine = GameEngine()..newLife();

    expect(engine.person.fullName.isNotEmpty, isTrue);
    expect(engine.currentEvent, isNotNull);
    expect(engine.age, 0);

    // العب دائما بالخيار الأول غير القاتل، حتى الموت.
    var steps = 0;
    while (!engine.isDead && steps < 200) {
      final event = engine.currentEvent!;
      final choice = event.choices.firstWhere(
        (c) => c.deathCause == null,
        orElse: () => event.choices.first,
      );
      final ageBefore = engine.age;
      engine.applyChoice(choice);
      if (!engine.isDead) {
        expect(engine.age, greaterThan(ageBefore));
        engine.nextEvent();
        expect(engine.currentEvent, isNotNull);
      }
      steps++;
    }

    expect(engine.isDead, isTrue);
    expect(engine.deathCause, isNotNull);
    expect(engine.log, isNotEmpty);
    expect(engine.storyText(), contains(engine.person.fullName));
    // لا يتكرر حدث مكتوب في الحياة الواحدة (الأحداث العامة مستثناة).
    final ids = engine.usedEvents.toList();
    expect(ids.length, ids.toSet().length);
  });

  test('الحفظ والاستئناف يعيدان نفس الحياة', () {
    final engine = GameEngine()..newLife();
    final event = engine.currentEvent!;
    final choice = event.choices.firstWhere(
      (c) => c.deathCause == null,
      orElse: () => event.choices.first,
    );
    engine.applyChoice(choice);
    engine.nextEvent();
    final json = engine.toJson();
    final restored = GameEngine.fromJson(json);
    expect(restored.person.fullName, engine.person.fullName);
    expect(restored.age, engine.age);
    expect(restored.balance, engine.balance);
    expect(restored.log.length, engine.log.length);
    expect(restored.currentEvent, isNotNull);
    expect(restored.lifeScore, greaterThan(0));
  });

  test('القصة المتسلسلة تفرض فصلها التالي والحدث المصيري يتبعه سنة تدبير', () {
    final engine = GameEngine()..newLife();
    engine.pendingNextId = 'arc_startup_2';
    final arc = engine.pickNextEvent();
    expect(arc.id, 'arc_startup_2');
    expect(arc.isArcChapter, isTrue);

    final engine2 = GameEngine()..newLife();
    engine2.age = 30;
    final first = engine2.currentEvent!;
    final choice = first.choices.firstWhere(
      (c) => c.deathCause == null && c.nextId == null,
      orElse: () => first.choices.first,
    );
    engine2.applyChoice(choice);
    if (!engine2.isDead) {
      engine2.nextEvent();
      expect(engine2.currentEvent!.id.startsWith('yearly_'), isTrue);
    }
  });

  test('ذاكرة الشخصيات: علاقات تُولد وتتغير بالقرارات وتُحفظ', () {
    final engine = GameEngine()..newLife();
    expect(engine.relationships.length, 3);
    expect(engine.relationships['friend']!.role, 'صديق الطفولة');

    engine.relationships['friend']!.change(200);
    expect(engine.relationships['friend']!.score, 100);
    engine.relationships['friend']!.change(-300);
    expect(engine.relationships['friend']!.score, -100);

    // خيار يغيّر العلاقة عبر المحرك.
    final engine2 = GameEngine()..newLife();
    final before = engine2.relationships['friend']!.score;
    engine2.currentEvent = relationshipEvents
        .firstWhere((e) => e.id == 'rel_friend_trouble');
    engine2.applyChoice(engine2.currentEvent!.choices.first);
    expect(engine2.relationships['friend']!.score, before + 35);
    expect(engine2.pendingNextId, 'rel_friend_returns');

    final json = engine2.toJson();
    final restored = GameEngine.fromJson(json);
    expect(restored.relationships['friend']!.score,
        engine2.relationships['friend']!.score);
    expect(restored.relationships['friend']!.name,
        engine2.relationships['friend']!.name);
  });

  test('شجرة المهارات: مستويات تفتحها النقاط وترفع الراتب فعليا', () {
    final engine = GameEngine()..newLife();
    engine.traits.add('employed');
    engine.jobTitle = 'موظف';
    engine.jobSalary = 30000;
    engine.stats.reputation = 50;

    expect(engine.careerTier, 'مبتدئ');
    expect(engine.effectiveSalary, 30000);

    engine.skillPoints = 12;
    expect(engine.careerTier, 'محترف');
    expect(engine.effectiveSalary, 37500);

    engine.skillPoints = 35;
    expect(engine.careerTier, 'خبير');
    expect(engine.effectiveSalary, 48000);

    // القائد يشترط السمعة: نقاط كافية لكن سمعة منخفضة تبقيك خبيرا.
    engine.skillPoints = 70;
    engine.stats.reputation = 20;
    expect(engine.careerTier, 'خبير');
    engine.stats.reputation = 50;
    expect(engine.careerTier, 'قائد');
    expect(engine.effectiveSalary, 63000);

    // حدث الترقية يمنح نقاطا، والسنوات العاملة تمنح نقاطا سنوية.
    final engine2 = GameEngine()..newLife();
    engine2.traits.add('employed');
    engine2.jobTitle = 'موظف';
    engine2.jobSalary = 30000;
    engine2.currentEvent =
        careerEvents.firstWhere((e) => e.id == 'career_promotion');
    engine2.applyChoice(engine2.currentEvent!.choices[1]);
    expect(engine2.skillPoints, greaterThanOrEqualTo(14));
    expect(engine2.careerTier, 'محترف');

    // الحفظ والاستئناف يحفظان النقاط.
    final json = engine2.toJson();
    final restored = GameEngine.fromJson(json);
    expect(restored.skillPoints, engine2.skillPoints);
    expect(restored.careerTier, engine2.careerTier);
  });

  test('عدة حيوات مختلفة على الأقل في الأسماء أو الدول', () {
    final seen = <String>{};
    for (var i = 0; i < 20; i++) {
      final engine = GameEngine()..newLife();
      seen.add('${engine.person.fullName}-${engine.person.country}');
    }
    expect(seen.length, greaterThan(1));
  });
}
