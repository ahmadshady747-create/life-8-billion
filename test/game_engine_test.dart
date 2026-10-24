import 'package:flutter_test/flutter_test.dart';
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

  test('عدة حيوات مختلفة على الأقل في الأسماء أو الدول', () {
    final seen = <String>{};
    for (var i = 0; i < 20; i++) {
      final engine = GameEngine()..newLife();
      seen.add('${engine.person.fullName}-${engine.person.country}');
    }
    expect(seen.length, greaterThan(1));
  });
}
