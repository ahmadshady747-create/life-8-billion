import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';
import 'package:life_8_billion/models.dart';

/// البند 5 (استمرار، أحداث الطفولة): الأحداث الخمسة التي كانت
/// باختيارين فقط في الطفولة صارت بثلاثة خيارات مميزة، كل خيار
/// يغيّر شيئا مرئيا، ولا يتطابق خياران في أثرهما، والخيار الثالث
/// يقدم مسارا وسطا أو محورا لا يقدمه الخياران الأولان.
void main() {
  LifeEvent byId(String id) => allEvents.firstWhere((e) => e.id == id);

  test('أحداث الطفولة الخمسة بثلاثة خيارات مميزة على الأقل', () {
    for (final id in [
      'first_friend',
      'first_school',
      'move_city',
      'child_illness',
      'friend_leaves',
    ]) {
      final event = byId(id);
      expect(event.choices.length, greaterThanOrEqualTo(3),
          reason: 'الحدث $id يجب أن يكون بثلاثة خيارات');
      final seenEffects = <String>{};
      for (final choice in event.choices) {
        final hasVisibleChange = !choice.effect.isEmpty ||
            choice.cash != 0 ||
            choice.addTraits.isNotEmpty ||
            choice.removeTraits.isNotEmpty ||
            choice.job != null ||
            choice.ambition != null ||
            choice.deathCause != null ||
            choice.nextId != null ||
            choice.skillPoints != 0 ||
            choice.relId != null;
        expect(hasVisibleChange, isTrue,
            reason: 'خيار "${choice.text}" في $id لا يغيّر شيئا');
        final signature = choice.effect.describe();
        expect(seenEffects.contains(signature), isFalse,
            reason: 'خياران متطابقان الأثر في $id: $signature');
        seenEffects.add(signature);
      }
    }
  });

  test('الخيار الثالث لكل حدث طفولة يقدم مسارا مميزا', () {
    // أول صديق: مسار وسط إيجابي، لا انغماس كامل ولا تجاهل.
    final friend = byId('first_friend');
    expect(friend.choices[2].effect.happiness, greaterThan(0));
    expect(friend.choices[1].effect.happiness, lessThan(0));
    // أول يوم مدرسة: الخيار الثالث ذكاء دون سعادة أو حزن.
    final school = byId('first_school');
    expect(school.choices[2].effect.smarts, greaterThan(0));
    expect(school.choices[2].effect.happiness, 0);
    // الانتقال: الخيار الثالث يحفظ العلاقات رغم الحزن.
    final move = byId('move_city');
    expect(move.choices[2].effect.social, greaterThan(0));
    expect(move.choices[2].effect.happiness, lessThan(0));
    // المرض: الخيار الثالث ذكاء أعلى من الصحة، عكس الالتزام الصرف.
    final illness = byId('child_illness');
    expect(illness.choices[2].effect.smarts,
        greaterThan(illness.choices[2].effect.health));
    // رحيل الصديق: الخيار الثالث أعلى علاقات من الخيارين الأولين.
    final leaves = byId('friend_leaves');
    expect(leaves.choices[2].effect.social,
        greaterThan(leaves.choices[0].effect.social));
    expect(leaves.choices[2].effect.social,
        greaterThan(leaves.choices[1].effect.social));
  });
}
