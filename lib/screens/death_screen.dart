import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game_engine.dart';
import '../models.dart';
import '../widgets/stat_bar.dart';
import 'game_screen.dart' show formatMoney;

/// شاشة النهاية: ملخص الحياة، إحصاءاتها الأخيرة، وقصتها الكاملة للنسخ.
class DeathScreen extends StatelessWidget {
  final GameEngine engine;
  final VoidCallback onNewLife;
  final VoidCallback onHome;

  const DeathScreen({
    super.key,
    required this.engine,
    required this.onNewLife,
    required this.onHome,
  });

  Future<void> _copyStory(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: engine.storyText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نُسخت قصة الحياة، يمكنك لصقها في أي مكان')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = engine.person;
    final traits = engine.traits
        .map((t) => traitLabels[t] ?? t)
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🕯️', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  const Text('انتهت الحياة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    '${person.fullName} ${person.flag}\n'
                    'من ${person.country}، عاش ${engine.age} سنة\n'
                    '(${person.birthYear} – ${person.birthYear + engine.age})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.7),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سبب الوفاة: ${engine.deathCause ?? '—'}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('عدد القرارات: ${engine.log.length}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('🏆 نقاط الحياة: ${engine.lifeScore}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('💰 الرصيد النهائي: ${formatMoney(engine.balance)}',
                              style: const TextStyle(fontSize: 16)),
                          if (engine.childrenCount > 0) ...[
                            const SizedBox(height: 6),
                            Text('👶 عدد الأطفال: ${engine.childrenCount}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                          if (engine.ambition != null) ...[
                            const SizedBox(height: 6),
                            Text(
                                '🎯 ${ambitionLabels[engine.ambition]}: ${engine.ambitionAchieved ? 'تحقق ✓' : 'لم يتحقق'}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                          if (engine.achievements.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: engine.achievements
                                  .map((a) => Chip(
                                      label: Text(achievementLabels[a] ?? a),
                                      backgroundColor: Colors.amber.shade100))
                                  .toList(),
                            ),
                          ],
                          if (traits.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: traits
                                  .map((label) => Chip(label: Text(label)))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('الحالة الأخيرة',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          for (final s in engine.stats.asList())
                            StatBar(icon: s.$2, label: s.$1, value: s.$3),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('📖 قصة الحياة كاملة',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final entry in engine.log)
                    Card(
                      child: ListTile(
                        title: Text('عمر ${entry.age}: ${entry.title}'),
                        subtitle:
                            Text('قرار: ${entry.choice}\n${entry.outcome}'),
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onNewLife,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17)),
                    child: const Text('حياة جديدة 🎲',
                        style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _copyStory(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text('نسخ القصة ومشاركتها 📋',
                        style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: onHome, child: const Text('العودة للبداية')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
