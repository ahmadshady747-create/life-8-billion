import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';

/// البند 5 (جزئي، للأحداث العامة المتكررة): الحدث العام يظهر كلما
/// نفدت الأحداث المناسبة، لذلك لا يجوز أن يبقى بخيارين فقط.
/// كل حدث عام يجب أن يقدم ثلاثة خيارات على الأقل، كل خيار منها
/// يغيّر شيئا مرئيا، ولا يتطابق خياران في أثرهما الإحصائي.
void main() {
  test('الأحداث العامة الأربعة بثلاثة خيارات مميزة على الأقل', () {
    for (final age in [5, 20, 40, 75]) {
      final event = genericEvent(age);
      expect(event.choices.length, greaterThanOrEqualTo(3),
          reason: 'الحدث العام عند عمر $age يجب أن يكون بثلاثة خيارات');
      final seenEffects = <String>{};
      for (final choice in event.choices) {
        // كل خيار يغيّر شيئا: أثر إحصائي، أو نقد، أو سمة، أو وظيفة،
        // أو طموح، أو موت، أو فصل تالٍ — لا خيار ميت تماما.
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
            reason: 'خيار "${choice.text}" في ${event.id} لا يغيّر شيئا');
        // لا خياران متطابقان في الأثر الإحصائي كاملا.
        final signature = choice.effect.describe();
        expect(seenEffects.contains(signature), isFalse,
            reason: 'خياران متطابقان الأثر في ${event.id}: $signature');
        seenEffects.add(signature);
      }
      // الخيار الثالث الجديد محور مختلف: لا يكفي أن يكون موجودا،
      // بل يجب أن يضيف قيمة لا يقدمها الخياران الأولان مجتمعين.
      final third = event.choices[2];
      expect(third.effect.isEmpty, isFalse);
    }
  });

  test('الخيار الثالث لكل حدث عام يمنح محورا لا يمنحه غيره', () {
    // طفولة: الصحة فقط في الخيار الثالث.
    final child = genericEvent(5);
    expect(child.choices[2].effect.health, greaterThan(0));
    expect(child.choices[0].effect.health, 0);
    expect(child.choices[1].effect.health, 0);
    // شباب: السمعة فقط في الخيار الثالث.
    final youth = genericEvent(20);
    expect(youth.choices[2].effect.reputation, greaterThan(0));
    expect(youth.choices[0].effect.reputation, 0);
    expect(youth.choices[1].effect.reputation, 0);
    // نضج: المهارة فقط في الخيار الثالث.
    final adult = genericEvent(40);
    expect(adult.choices[2].effect.skill, greaterThan(0));
    expect(adult.choices[0].effect.skill, 0);
    expect(adult.choices[1].effect.skill, 0);
    // شيخوخة: الصحة فقط في الخيار الثالث.
    final old = genericEvent(75);
    expect(old.choices[2].effect.health, greaterThan(0));
    expect(old.choices[0].effect.health, 0);
    expect(old.choices[1].effect.health, 0);
  });
}
