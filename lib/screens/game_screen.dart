import 'package:flutter/material.dart';

import '../game_engine.dart';
import '../models.dart';
import '../widgets/stat_bar.dart';

/// شاشة اللعب: بطاقة الشخصية، الإحصاءات، الحدث الحالي، ونتيجته.
class GameScreen extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback onNewLife;
  final VoidCallback onFinish;

  const GameScreen({
    super.key,
    required this.engine,
    required this.onNewLife,
    required this.onFinish,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showBirth = true;
  bool _showOutcome = false;

  GameEngine get _e => widget.engine;

  void _choose(EventChoice choice) {
    setState(() {
      _e.applyChoice(choice);
      _showOutcome = true;
    });
  }

  void _continue() {
    if (_e.isDead) {
      widget.onFinish();
      return;
    }
    setState(() {
      _e.nextEvent();
      _showOutcome = false;
    });
  }

  Future<void> _confirmRestart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء هذه الحياة؟'),
        content: Text(
            'ستُترك حياة ${_e.person.fullName} دون إكمالها، وتبدأ حياة جديدة عشوائية.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('البقاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حياة جديدة')),
        ],
      ),
    );
    if (ok == true) widget.onNewLife();
  }

  void _showJournal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('📖 سجل حياة ${_e.person.fullName}',
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${_e.log.length} قرارات حتى الآن',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Expanded(
                child: _e.log.isEmpty
                    ? const Center(
                        child: Text('لم تتخذ أي قرار بعد.'))
                    : ListView.builder(
                        controller: controller,
                        itemCount: _e.log.length,
                        itemBuilder: (ctx, i) {
                          final entry = _e.log[i];
                          return Card(
                            child: ListTile(
                              title: Text(
                                  'عمر ${entry.age}: ${entry.title}'),
                              subtitle: Text(
                                  'قرار: ${entry.choice}\n${entry.outcome}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final person = _e.person;
    final event = _e.currentEvent;
    return Scaffold(
      appBar: AppBar(
        title: Text(person.fullName),
        actions: [
          IconButton(
              icon: const Icon(Icons.book_outlined),
              tooltip: 'سجل الحياة',
              onPressed: _showJournal),
          IconButton(
              icon: const Icon(Icons.casino_outlined),
              tooltip: 'حياة جديدة',
              onPressed: _confirmRestart),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileCard(person),
                  const SizedBox(height: 12),
                  _statsCard(),
                  const SizedBox(height: 12),
                  if (_showBirth)
                    _birthCard()
                  else if (_showOutcome)
                    _outcomeCard()
                  else if (event != null)
                    _eventCard(event)
                  else
                    const Card(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('انتهت الأحداث.'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCard(Person person) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: Text(stageEmoji(_e.age, person.isMale),
                  style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.fullName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      '${person.flag} ${person.country} • ${person.genderLabel} • عمر ${_e.age} سنة • ${stageLabel(_e.age)}'),
                  Text(
                      'سنة ${_e.person.birthYear + _e.age} • ${person.familyClass}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsCard() {
    final traits = _e.traits
        .map((t) => traitLabels[t] ?? t)
        .where((label) => label.isNotEmpty)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in _e.stats.asList())
              StatBar(icon: s.$2, label: s.$1, value: s.$3),
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
    );
  }

  Widget _birthCard() {
    final person = _e.person;
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🎉 وُلدتَ للتو!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'أنت ${person.fullName}، ${person.genderLabel} من ${person.country} ${person.flag}. '
              'وُلدتَ سنة ${person.birthYear} في ${person.familyClass}. '
              'لا أحد اختار لك هذا، ولا أنت. هذه هي نقطة بدايتك، '
              'وما سيحدث بعدها يعتمد على قراراتك.',
              style: const TextStyle(fontSize: 17, height: 1.7),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _showBirth = false),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('ابدأ رحلة الحياة 👶',
                  style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(LifeEvent event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Chip(label: Text('عمر ${_e.age}')),
                const SizedBox(width: 8),
                Chip(label: Text(stageLabel(_e.age))),
              ],
            ),
            const SizedBox(height: 12),
            Text(event.title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(event.story,
                style: const TextStyle(fontSize: 17, height: 1.7)),
            const SizedBox(height: 18),
            for (final choice in event.choices) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
                  onPressed: () => _choose(choice),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    alignment: Alignment.centerRight,
                  ),
                  child: Text(choice.text,
                      style: const TextStyle(fontSize: 16, height: 1.5)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _outcomeCard() {
    final choice = _e.lastChoice;
    if (choice == null) return const SizedBox.shrink();
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('✨ ما حدث بعد قرارك',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(choice.outcome,
                style: const TextStyle(fontSize: 17, height: 1.7)),
            if (!choice.effect.isEmpty) ...[
              const SizedBox(height: 12),
              Text('التأثير: ${choice.effect.describe()}',
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _continue,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(_e.isDead ? 'إلى النهاية 🕯️' : 'تابع الحياة ➜',
                  style: const TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
