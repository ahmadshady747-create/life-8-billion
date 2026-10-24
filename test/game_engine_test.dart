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

  test('عدة حيوات مختلفة على الأقل في الأسماء أو الدول', () {
    final seen = <String>{};
    for (var i = 0; i < 20; i++) {
      final engine = GameEngine()..newLife();
      seen.add('${engine.person.fullName}-${engine.person.country}');
    }
    expect(seen.length, greaterThan(1));
  });
}
