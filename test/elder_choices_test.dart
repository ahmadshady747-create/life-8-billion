import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';
import 'package:life_8_billion/models.dart';

/// البند 5 (استمرار، أحداث منتصف العمر): الأحداث الأربعة التي كانت
/// باختيارين فقط (منتصف الطريق، أزمة مالية، تكريم غير متوقع، عش
/// فارغ) صارت بثلاثة خيارات مميزة، كل خيار يغيّر شيئا مرئيا،
/// ولا يتطابق خياران في أثرهما، والخيار الوسط يقدم مسارا وسطا
/// لا يقدمه الخياران المتطرفان.
void main() {
  // المحرك يجمع allEvents وlaterEvents في حوض واحد، فالاختبار
  // يبحث فيهما معا كما يفعل المحرك.
  LifeEvent byId(String id) =>
      [...allEvents, ...laterEvents].firstWhere((e) => e.id == id);

  test('أحداث منتصف العمر الأربعة بثلاثة خيارات مميزة على الأقل', () {
    for (final id in ['midlife', 'money_crisis', 'award', 'empty_nest']) {
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

  test('الخيار الوسط لكل حدث منتصف عمر يقدم مسارا وسطا مميزا', () {
    // منتصف الطريق: الوسط تغيير صغير بجانب العمل، سعادته وماله
    // وذكاؤه بين التغيير الكامل والقبول الكامل.
    final midlife = byId('midlife');
    expect(midlife.choices[1].effect.happiness,
        lessThan(midlife.choices[0].effect.happiness));
    expect(midlife.choices[1].effect.happiness,
        greaterThan(midlife.choices[2].effect.happiness));
    expect(midlife.choices[1].effect.money,
        greaterThan(midlife.choices[0].effect.money));
    expect(midlife.choices[1].effect.money,
        lessThan(midlife.choices[2].effect.money));
    expect(midlife.choices[1].effect.smarts,
        lessThan(midlife.choices[0].effect.smarts));
    expect(midlife.choices[1].effect.smarts,
        greaterThan(midlife.choices[2].effect.smarts));
    // أزمة مالية: الوسط عمل حر مؤقت، ماله وسعادته وصحته بين
    // البحث عن عمل ثابت والاستدانة وانتظار الفرج.
    final crisis = byId('money_crisis');
    expect(crisis.choices[1].effect.money,
        lessThan(crisis.choices[0].effect.money));
    expect(crisis.choices[1].effect.money,
        greaterThan(crisis.choices[2].effect.money));
    expect(crisis.choices[1].effect.happiness,
        lessThan(crisis.choices[0].effect.happiness));
    expect(crisis.choices[1].effect.happiness,
        greaterThan(crisis.choices[2].effect.happiness));
    expect(crisis.choices[1].effect.health,
        greaterThan(crisis.choices[0].effect.health));
    expect(crisis.choices[1].effect.health,
        lessThan(crisis.choices[2].effect.health));
    // تكريم غير متوقع: الوسط قبول مع رواية القصة للشباب،
    // سعادته وعلاقاته بين القبول المتواضع والإهداء الكامل.
    final award = byId('award');
    expect(award.choices[1].effect.happiness,
        lessThan(award.choices[0].effect.happiness));
    expect(award.choices[1].effect.happiness,
        greaterThan(award.choices[2].effect.happiness));
    expect(award.choices[1].effect.social,
        greaterThan(award.choices[0].effect.social));
    expect(award.choices[1].effect.social,
        lessThan(award.choices[2].effect.social));
    // عش فارغ: الوسط هوايات وأصدقاء مع زيارات منتظمة،
    // سعادته وعلاقاته بين الاستمتاع بالحرية والشعور بالفراغ.
    final nest = byId('empty_nest');
    expect(nest.choices[1].effect.happiness,
        lessThan(nest.choices[0].effect.happiness));
    expect(nest.choices[1].effect.happiness,
        greaterThan(nest.choices[2].effect.happiness));
    expect(nest.choices[1].effect.social,
        greaterThan(nest.choices[0].effect.social));
    expect(nest.choices[1].effect.social,
        lessThan(nest.choices[2].effect.social));
  });
}
