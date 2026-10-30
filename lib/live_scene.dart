import 'package:flutter/material.dart';

import 'game_feel.dart';

/// المرحلة 2 — مشهد الحياة الحي: مرسوم بأدوات Flutter الأصلية
/// فقط، دون أي أصول خارجية، وكل عنصر فيه يعكس رقما حقيقيا من
/// إدارة الحياة نفسها، لا زخرفة منفصلة عن الأرقام:
/// - لون الشخص يعكس الصحة الحقيقية (أخضر مرتفعة، برتقالي
///   متوسطة، أحمر منخفضة).
/// - عدد وجوه الجيران يعكس العلاقات الحقيقية.
/// - شريطا المهارة والادخار يعكسان الرقمين الحقيقيين.
/// - لون البيت يعكس الادخار (أخضر عند ادخار قوي، رمادي عند
///   ضعفه)، فالمشهد يتحرك كلما تحركت أرقامك.
double statFraction(int value) => (value / 100).clamp(0.0, 1.0);

int neighbourFaces(int relationships) =>
    (relationships ~/ 20).clamp(0, 5);

Color healthColor(int health) =>
    health >= 70 ? Colors.green : health >= 40 ? Colors.orange : Colors.red;

class LifeLiveScene extends StatelessWidget {
  final int health;
  final int skill;
  final int relationships;
  final int cash;
  final int savings;
  final int ageYears;
  final int months;

  const LifeLiveScene({
    super.key,
    required this.health,
    required this.skill,
    required this.relationships,
    required this.cash,
    required this.savings,
    required this.ageYears,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    final faces = neighbourFaces(relationships);
    final color = healthColor(health);
    return Card(
      key: const Key('live-scene'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مشهد حياتك الحي',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('عمرك $ageYears سنة — مرّ $months شهرا',
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.6, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, _) => Opacity(
                        opacity: value,
                        child: Icon(Icons.home,
                            size: 56,
                            color: savings >= 5000
                                ? Colors.green
                                : Colors.grey),
                      ),
                    ),
                    const Text('بيتك', style: TextStyle(fontSize: 12)),
                    Text('الادخار: $savings',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.person, size: 56, color: color),
                    const Text('أنت', style: TextStyle(fontSize: 12)),
                    Text('الصحة: $health / 100',
                        style: TextStyle(fontSize: 12, color: color)),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < faces; i++)
                          const Icon(Icons.face,
                              size: 22, color: Colors.teal),
                        if (faces == 0)
                          const Icon(Icons.face,
                              size: 22, color: Colors.grey),
                      ],
                    ),
                    const Text('جيرانك وأصدقاؤك',
                        style: TextStyle(fontSize: 12)),
                    Text('العلاقات: $relationships / 100',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBar(
              label: 'المهارة ($skill / 100)',
              fraction: statFraction(skill),
              color: Colors.blue,
            ),
            AnimatedBar(
              label: 'الصحة ($health / 100)',
              fraction: statFraction(health),
              color: color,
            ),
            AnimatedBar(
              label: 'العلاقات ($relationships / 100)',
              fraction: statFraction(relationships),
              color: Colors.teal,
            ),
            Text('النقد: $cash — كل وجه يعكس 20 نقطة علاقات حقيقية',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
