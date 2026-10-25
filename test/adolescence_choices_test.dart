import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/data/events.dart';
import 'package:life_8_billion/models.dart';

/// البند 5 (استمرار، أحداث المراهقة): الحدثان اللذان كانا
/// باختيارين فقط في المراهقة صارا بثلاثة خيارات مميزة، كل خيار
/// يغيّر شيئا مرئيا، ولا يتطابق خياران في أثرهما، والخيار الثالث
/// يقدم مسارا وسطا لا يقدمه الخياران الأولان.
void main() {
  LifeEvent byId(String id) => allEvents.firstWhere((e) => e.id == id);

  test('حدثا المراهقة الثنائيان بثلاثة خيارات مميزة على الأقل', () {
    for (final id in ['team_tryout', 'motorbike']) {
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

  test('الخيار الثالث لكل حدث مراهقة يقدم مسارا مميزا', () {
    // اختبار الفريق: الخيار الثالث علاقات أعلى من الالتحاق الكامل،
    // وصحة أقل منه — انتماء للفريق دون التشكيلة الأساسية.
    final team = byId('team_tryout');
    expect(team.choices[2].effect.social,
        greaterThan(team.choices[0].effect.social));
    expect(team.choices[2].effect.health,
        lessThan(team.choices[0].effect.health));
    // سباق الدراجات: الخيار الثالث لا يقتل، وصحة أعلى من الرفض الصرف.
    final bike = byId('motorbike');
    expect(bike.choices[2].deathCause, isNull);
    expect(bike.choices[2].effect.health,
        greaterThan(bike.choices[0].effect.health));
    expect(bike.choices[1].deathCause, isNotNull,
        reason: 'خيار السباق المتهور يجب أن يبقى قاتلا كما كان');
  });
}
