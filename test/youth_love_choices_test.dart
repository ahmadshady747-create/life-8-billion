import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';
import 'package:life_8_billion/models.dart';

/// البند 5 (استمرار، أحداث الشباب العاطفية/العائلية): الأحداث
/// الأربعة التي كانت باختيارين فقط (حب جدي، فرصة في الخارج،
/// عرض زواج، طفل أول) صارت بثلاثة خيارات مميزة، كل خيار يغيّر
/// شيئا مرئيا، ولا يتطابق خياران في أثرهما، والخيار الوسط
/// يقدم مسارا وسطا لا يقدمه الخياران المتطرفان.
void main() {
  // المحرك يجمع allEvents وlaterEvents في حوض واحد، فالاختبار
  // يبحث فيهما معا كما يفعل المحرك.
  LifeEvent byId(String id) =>
      [...allEvents, ...laterEvents].firstWhere((e) => e.id == id);

  test('أحداث الشباب العاطفية/العائلية بثلاثة خيارات مميزة على الأقل',
      () {
    for (final id in ['serious_love', 'abroad', 'marriage', 'first_child']) {
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

  test('الخيار الوسط لكل حدث عاطفي/عائلي يقدم مسارا وسطا مميزا', () {
    // حب جدي: الوسط سعادة وعلاقات بين الالتزام الكامل والتردد،
    // ودون سمة الشريك، فيبقى باب الزواج مغلقا حتى يلتزم اللاعب.
    final love = byId('serious_love');
    expect(love.choices[1].addTraits, isNot(contains('partner')));
    expect(love.choices[1].effect.happiness,
        greaterThan(love.choices[2].effect.happiness));
    expect(love.choices[1].effect.happiness,
        lessThan(love.choices[0].effect.happiness));
    // فرصة في الخارج: الوسط عقد قصير، ماله بين الرفض والاغتراب
    // الكامل، ودون سمة المسافر.
    final abroad = byId('abroad');
    expect(abroad.choices[1].addTraits, isNot(contains('traveler')));
    expect(abroad.choices[1].effect.money,
        greaterThan(abroad.choices[2].effect.money));
    expect(abroad.choices[1].effect.money,
        lessThan(abroad.choices[0].effect.money));
    // عرض زواج: الوسط عيش مشترك دون زواج رسمي، سعادته بين
    // الرفض والقبول، ويبقي سمة الشريك دون أن يضيف سمة الزواج.
    final marriage = byId('marriage');
    expect(marriage.choices[1].addTraits, isNot(contains('married')));
    expect(marriage.choices[1].removeTraits, isNot(contains('partner')));
    expect(marriage.choices[1].effect.happiness,
        greaterThan(marriage.choices[2].effect.happiness));
    expect(marriage.choices[1].effect.happiness,
        lessThan(marriage.choices[0].effect.happiness));
    // طفل أول: الوسط رعاية مشتركة مع العائلة، سعادته بين الخوف
    // والفرح الكامل، وعلاقاته أعلى من الخيارين الآخرين، مع سمة
    // الوالد كما فيهما.
    final child = byId('first_child');
    expect(child.choices[1].addTraits, contains('parent'));
    expect(child.choices[1].effect.happiness,
        greaterThan(child.choices[2].effect.happiness));
    expect(child.choices[1].effect.happiness,
        lessThan(child.choices[0].effect.happiness));
    expect(child.choices[1].effect.social,
        greaterThan(child.choices[0].effect.social));
    expect(child.choices[1].effect.social,
        greaterThan(child.choices[2].effect.social));
  });
}
