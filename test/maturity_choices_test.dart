import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';
import 'package:life_8_billion/models.dart';

/// البند 5 (استمرار، أحداث النضج): الأحداث الأربعة التي كانت
/// باختيارين فقط (بيت العمر، احتراق وظيفي، تحذير الطبيب، والداك
/// يكبران) صارت بثلاثة خيارات مميزة، كل خيار يغيّر شيئا مرئيا،
/// ولا يتطابق خياران في أثرهما، والخيار الوسط يقدم مسارا وسطا
/// لا يقدمه الخياران المتطرفان.
void main() {
  // المحرك يجمع allEvents وlaterEvents في حوض واحد، فالاختبار
  // يبحث فيهما معا كما يفعل المحرك.
  LifeEvent byId(String id) =>
      [...allEvents, ...laterEvents].firstWhere((e) => e.id == id);

  test('أحداث النضج الأربعة بثلاثة خيارات مميزة على الأقل', () {
    for (final id in ['buy_house', 'burnout', 'doctor_warning', 'parents_care']) {
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

  test('الخيار الوسط لكل حدث نضج يقدم مسارا وسطا مميزا', () {
    // بيت العمر: الوسط شقة أصغر بقرض أقصر، ماله وسعادته بين
    // الشراء الكامل والإيجار.
    final house = byId('buy_house');
    expect(house.choices[1].effect.money,
        greaterThan(house.choices[0].effect.money));
    expect(house.choices[1].effect.money,
        lessThan(house.choices[2].effect.money));
    expect(house.choices[1].effect.happiness,
        lessThan(house.choices[0].effect.happiness));
    expect(house.choices[1].effect.happiness,
        greaterThan(house.choices[2].effect.happiness));
    // احتراق وظيفي: الوسط تخفيف ساعات، صحته وسعادته وماله بين
    // الإجازة الكاملة وتجاهل التعب.
    final burnout = byId('burnout');
    expect(burnout.choices[1].effect.health,
        lessThan(burnout.choices[0].effect.health));
    expect(burnout.choices[1].effect.health,
        greaterThan(burnout.choices[2].effect.health));
    expect(burnout.choices[1].effect.happiness,
        lessThan(burnout.choices[0].effect.happiness));
    expect(burnout.choices[1].effect.happiness,
        greaterThan(burnout.choices[2].effect.happiness));
    expect(burnout.choices[1].effect.money,
        greaterThan(burnout.choices[0].effect.money));
    expect(burnout.choices[1].effect.money,
        lessThan(burnout.choices[2].effect.money));
    // تحذير الطبيب: الوسط مشي يومي، صحته بين التغيير الكامل
    // والتجاهل، ودون سمة المزمن التي يضيفها التجاهل.
    final doctor = byId('doctor_warning');
    expect(doctor.choices[1].effect.health,
        lessThan(doctor.choices[0].effect.health));
    expect(doctor.choices[1].effect.health,
        greaterThan(doctor.choices[2].effect.health));
    expect(doctor.choices[1].addTraits, isNot(contains('chronic')));
    // والداك يكبران: الوسط رعاية مشتركة مع العائلة، كل محاوره
    // بين الرعاية الذاتية الكاملة والتوظيف: سعادة بينهما،
    // وعلاقات بينهما، وصحة ومال بينهما.
    final parents = byId('parents_care');
    expect(parents.choices[1].effect.happiness,
        lessThan(parents.choices[0].effect.happiness));
    expect(parents.choices[1].effect.happiness,
        greaterThan(parents.choices[2].effect.happiness));
    expect(parents.choices[1].effect.social,
        lessThan(parents.choices[0].effect.social));
    expect(parents.choices[1].effect.social,
        greaterThan(parents.choices[2].effect.social));
    expect(parents.choices[1].effect.health,
        greaterThan(parents.choices[0].effect.health));
    expect(parents.choices[1].effect.health,
        lessThan(parents.choices[2].effect.health));
    expect(parents.choices[1].effect.money,
        lessThan(parents.choices[0].effect.money));
    expect(parents.choices[1].effect.money,
        greaterThan(parents.choices[2].effect.money));
  });
}
