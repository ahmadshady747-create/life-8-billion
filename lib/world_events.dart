import 'package:flutter/material.dart';

/// المرحلة 5 — مشهد الشهر التفاعلي: يظهر بعد كل شهر يتقدم،
/// لا كسطور تقرير فقط، بل كمشهد يعكس دلتا الشهر الحقيقية
/// (صحة ومهارة وعلاقات ونقد) بأيقونات وألوان، وبقرار إداري
/// للشهر التالي. القرارات الثلاثة كلها مفاتيح إدارة قائمة
/// أصلا، لا خيارات سردية تحسم اللعب: التركيز على الصحة
/// (رياضة وتعافٍ)، أو على العلاقات (لقاء اجتماعي)، أو عدم
/// التغيير. أثر القرار يظهر في الشهر التالي مباشرة، وسلسلة
/// الأشهر المعروضة هنا هي سلسلة الإدارة نفسها من لوحة
/// الأهداف، فالاستمرارية مرئية في المشهد نفسه.
class MonthEventScene extends StatelessWidget {
  final int healthDelta;
  final int skillDelta;
  final int relationshipsDelta;
  final int cashDelta;
  final int streakMonths;
  final bool gymOn;
  final bool socialOn;
  final VoidCallback onFocusHealth;
  final VoidCallback onFocusRelationships;
  final VoidCallback onKeepPlan;

  const MonthEventScene({
    super.key,
    required this.healthDelta,
    required this.skillDelta,
    required this.relationshipsDelta,
    required this.cashDelta,
    required this.streakMonths,
    required this.gymOn,
    required this.socialOn,
    required this.onFocusHealth,
    required this.onFocusRelationships,
    required this.onKeepPlan,
  });

  String _signed(int v) => v >= 0 ? '+$v' : '$v';

  @override
  Widget build(BuildContext context) {
    final healthBad = healthDelta < 0;
    return Card(
      key: const Key('world-event-scene'),
      color: healthBad ? Colors.orange.shade50 : Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: healthBad ? Colors.orange : Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, size: 28, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text('مشهد الشهر',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.home, size: 28, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'نتيجة شهرك: صحة ${_signed(healthDelta)} — مهارة ${_signed(skillDelta)} — علاقات ${_signed(relationshipsDelta)} — نقد ${_signed(cashDelta)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('سلسلة أشهرك: $streakMonths',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'كيف ترد إداريا في الشهر التالي؟ اختر إجراء واحدا:'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onFocusHealth,
              child: Text(gymOn
                  ? 'الرياضة مفعّلة — أضف التعافي للشهر التالي'
                  : 'ركّز على الصحة: فعّل الرياضة والتعافي'),
            ),
            OutlinedButton(
              onPressed: onFocusRelationships,
              child: Text(socialOn
                  ? 'اللقاء الاجتماعي مفعّل — واصل التواصل'
                  : 'ركّز على العلاقات: فعّل اللقاء الاجتماعي'),
            ),
            OutlinedButton(
              onPressed: onKeepPlan,
              child: const Text('لا تغيير: واصل خطتك كما هي'),
            ),
          ],
        ),
      ),
    );
  }
}
