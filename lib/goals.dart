import 'package:flutter/material.dart';

import 'game_feel.dart';

/// المرحلة 3 — أهداف ومكافآت مشتقة من أرقام إدارة الحياة نفسها
/// فقط. لا يضيف هذا الملف أي رقم إدارة جديد ولا يغيّر توازنا:
/// التحديات عتبات على الأرقام الحقيقية وتتجدد كل 3 أشهر،
/// والإنجازات تُفتح عند بلوغ عتبات حقيقية، والمستوى مجموع
/// نقاط من الصحة والمهارة والعلاقات والمشاريع المنجزة.
/// لحظات الفوز: إنجاز كبير (توازن الحياة، عام كامل، ادخار
/// قوي) بعرض بصري واضح؛ ولحظة الخطر: نقد سالب أو صحة
/// متدهورة، بعرض تحذيري واضح لا بسطر تقرير فقط.
class GoalItem {
  final String title;
  final int current;
  final int target;
  final bool unlocked;

  const GoalItem({
    required this.title,
    required this.current,
    required this.target,
    required this.unlocked,
  });

  double get progress =>
      target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
  bool get done => current >= target;
}

int monthBlock(int months) => months ~/ 3;

List<GoalItem> monthlyChallenges({
  required int months,
  required int health,
  required int skill,
  required int relationships,
  required int savings,
}) {
  final block = monthBlock(months);
  return [
    GoalItem(
      title: 'تحدي الشهر: الصحة',
      current: health,
      target: 70,
      unlocked: health >= 70,
    ),
    GoalItem(
      title: 'تحدي الشهر: المهارة',
      current: skill,
      target: (30 + block * 10).clamp(30, 90),
      unlocked: skill >= (30 + block * 10).clamp(30, 90),
    ),
    GoalItem(
      title: 'تحدي الشهر: العلاقات',
      current: relationships,
      target: 60,
      unlocked: relationships >= 60,
    ),
    GoalItem(
      title: 'تحدي الشهر: الادخار',
      current: savings,
      target: 1000 + months * 100,
      unlocked: savings >= 1000 + months * 100,
    ),
  ];
}

List<GoalItem> quarterlyChallenges({
  required int months,
  required int health,
  required int skill,
  required int relationships,
  required int completedProjectCount,
}) {
  final block = monthBlock(months);
  return [
    GoalItem(
      title: 'تحدي الربع: مشاريع منجزة',
      current: completedProjectCount,
      target: (block + 1).clamp(1, 5),
      unlocked: completedProjectCount >= (block + 1).clamp(1, 5),
    ),
    GoalItem(
      title: 'تحدي الربع: توازن الحياة',
      current: (health >= 70 ? 1 : 0) +
          (skill >= 70 ? 1 : 0) +
          (relationships >= 70 ? 1 : 0),
      target: 3,
      unlocked: health >= 70 && skill >= 70 && relationships >= 70,
    ),
  ];
}

List<GoalItem> achievements({
  required int months,
  required int health,
  required int skill,
  required int relationships,
  required int savings,
  required int completedProjectCount,
}) {
  return [
    GoalItem(
        title: 'صحة 80',
        current: health,
        target: 80,
        unlocked: health >= 80),
    GoalItem(
        title: 'مهارة 80',
        current: skill,
        target: 80,
        unlocked: skill >= 80),
    GoalItem(
        title: 'علاقات 80',
        current: relationships,
        target: 80,
        unlocked: relationships >= 80),
    GoalItem(
        title: 'توازن الحياة: الثلاثة فوق 70',
        current: (health >= 70 ? 1 : 0) +
            (skill >= 70 ? 1 : 0) +
            (relationships >= 70 ? 1 : 0),
        target: 3,
        unlocked: health >= 70 && skill >= 70 && relationships >= 70),
    GoalItem(
        title: 'ادخار 5000',
        current: savings,
        target: 5000,
        unlocked: savings >= 5000),
    GoalItem(
        title: 'ادخار 20000',
        current: savings,
        target: 20000,
        unlocked: savings >= 20000),
    GoalItem(
        title: 'أول مشروع منجز',
        current: completedProjectCount,
        target: 1,
        unlocked: completedProjectCount >= 1),
    GoalItem(
        title: 'عام كامل من الإدارة',
        current: months,
        target: 12,
        unlocked: months >= 12),
    GoalItem(
        title: 'خمس سنوات من الإدارة',
        current: months,
        target: 60,
        unlocked: months >= 60),
  ];
}

int levelPoints({
  required int health,
  required int skill,
  required int relationships,
  required int completedProjectCount,
  required int months,
}) =>
    health ~/ 10 +
    skill ~/ 10 +
    relationships ~/ 10 +
    completedProjectCount * 3 +
    months ~/ 12;

int levelFromPoints(int points) => 1 + points ~/ 5;

double levelProgress(int points) => (points % 5) / 5;

class GoalsPanel extends StatelessWidget {
  final int months;
  final int health;
  final int skill;
  final int relationships;
  final int cash;
  final int savings;
  final int completedProjectCount;
  final int streakMonths;

  const GoalsPanel({
    super.key,
    required this.months,
    required this.health,
    required this.skill,
    required this.relationships,
    required this.cash,
    required this.savings,
    required this.completedProjectCount,
    required this.streakMonths,
  });

  @override
  Widget build(BuildContext context) {
    final points = levelPoints(
      health: health,
      skill: skill,
      relationships: relationships,
      completedProjectCount: completedProjectCount,
      months: months,
    );
    final level = levelFromPoints(points);
    final monthly = monthlyChallenges(
        months: months,
        health: health,
        skill: skill,
        relationships: relationships,
        savings: savings);
    final quarterly = quarterlyChallenges(
        months: months,
        health: health,
        skill: skill,
        relationships: relationships,
        completedProjectCount: completedProjectCount);
    final all = achievements(
      months: months,
      health: health,
      skill: skill,
      relationships: relationships,
      savings: savings,
      completedProjectCount: completedProjectCount,
    );
    final unlockedCount = all.where((g) => g.unlocked).length;
    final balanced =
        health >= 70 && skill >= 70 && relationships >= 70;
    final inDanger = cash < 0 || health < 30;
    return Column(
      key: const Key('goals-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (balanced)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'لحظة فوز: توازن الحياة! صحتك ومهارتك وعلاقاتك كلها فوق 70.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
        if (inDanger)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Text(
              cash < 0
                  ? 'لحظة خطر: نقدك سالب ودينك يكبر بفائدة كل شهر. راجع ميزانية المال قبل التقدم.'
                  : 'لحظة خطر: صحتك تحت 30. الراحة والرياضة قبل أي تقدم جديد.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
            ),
          ),
        if (balanced || inDanger) const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('مستواك: $level — سلسلة أشهر: $streakMonths',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                AnimatedBar(
                  label: 'تقدمك نحو المستوى ${level + 1}',
                  fraction: levelProgress(points),
                  color: Colors.amber.shade700,
                ),
                Text('إنجازات مفتوحة: $unlockedCount من ${all.length}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('تحديات الشهر (تتجدد كل 3 أشهر)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final g in monthly) _GoalRow(goal: g),
        const SizedBox(height: 12),
        const Text('تحديات الربع',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final g in quarterly) _GoalRow(goal: g),
        const SizedBox(height: 12),
        const Text('الإنجازات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        for (final g in all) _GoalRow(goal: g),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final GoalItem goal;

  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: goal.unlocked ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  goal.unlocked ? Icons.emoji_events : Icons.lock_outline,
                  color: goal.unlocked ? Colors.amber.shade800 : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                Text('${goal.current} / ${goal.target}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedBar(
              label: goal.unlocked ? 'مكتمل' : 'التقدم',
              fraction: goal.progress,
              color: goal.unlocked ? Colors.green : Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
