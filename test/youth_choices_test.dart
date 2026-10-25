import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';
import 'package:life_8_billion/models.dart';

/// البند 5 (استمرار، أحداث الشباب الجامعية/العملية): الأحداث الأربعة
/// التي كانت باختيارين فقط (سنة جامعية صعبة، أصدقاء الجامعة، أول
/// مقابلة عمل، رحلة بحقيبة ظهر) صارت بثلاثة خيارات مميزة، كل خيار
/// يغيّر شيئا مرئيا، ولا يتطابق خياران في أثرهما، والخيار الوسط
/// يقدم مسارا وسطا لا يقدمه الخياران المتطرفان.
void main() {
  // المحرك يجمع allEvents وlaterEvents في حوض واحد، فالاختبار
  // يبحث فيهما معا كما يفعل المحرك.
  LifeEvent byId(String id) =>
      [...allEvents, ...laterEvents].firstWhere((e) => e.id == id);

  test('أحداث الشباب الجامعية/العملية بثلاثة خيارات مميزة على الأقل', () {
    for (final id in ['uni_hard', 'uni_friends', 'first_job', 'backpack']) {
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

  test('الخيار الوسط لكل حدث شباب يقدم مسارا وسطا مميزا', () {
    // سنة جامعية صعبة: الوسط ذكاء أقل من المذاكرة الليلية، لكن
    // علاقات أعلى منها، ودون ترك الجامعة.
    final uniHard = byId('uni_hard');
    expect(uniHard.choices[1].effect.smarts,
        lessThan(uniHard.choices[0].effect.smarts));
    expect(uniHard.choices[1].effect.social,
        greaterThan(uniHard.choices[0].effect.social));
    expect(uniHard.choices[2].addTraits, contains('employed'),
        reason: 'ترك الجامعة يجب أن يبقي خيار العمل كما كان');
    // أصدقاء الجامعة: الوسط علاقات بين الصداقة العميقة والعزلة،
    // وذكاء موجب دون تفوق العزلة.
    final uniFriends = byId('uni_friends');
    expect(uniFriends.choices[1].effect.social,
        lessThan(uniFriends.choices[0].effect.social));
    expect(uniFriends.choices[1].effect.social,
        greaterThan(uniFriends.choices[2].effect.social));
    // أول مقابلة عمل: الوسط يكسب مالا دون أن يغلق باب الوظيفة
    // بسمة موظف، وماله أقل من القبول الكامل.
    final firstJob = byId('first_job');
    expect(firstJob.choices[1].addTraits, isNot(contains('employed')),
        reason: 'العمل الحر المؤقت يجب ألا يغلق باب الوظيفة');
    expect(firstJob.choices[1].effect.money,
        greaterThan(0));
    expect(firstJob.choices[1].effect.money,
        lessThan(firstJob.choices[0].effect.money));
    // رحلة بحقيبة ظهر: الوسط رحلة قصيرة، مالها أفضل من الرحلة
    // الطويلة وأسوأ من الادخار، ودون سمة المسافر.
    final backpack = byId('backpack');
    expect(backpack.choices[1].addTraits, isNot(contains('traveler')));
    expect(backpack.choices[1].effect.money,
        greaterThan(backpack.choices[0].effect.money));
    expect(backpack.choices[1].effect.money,
        lessThan(backpack.choices[2].effect.money));
  });
}
