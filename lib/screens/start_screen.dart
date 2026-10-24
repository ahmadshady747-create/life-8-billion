import 'package:flutter/material.dart';

/// شاشة البداية: شرح الفكرة وزر بدء حياة عشوائية.
class StartScreen extends StatelessWidget {
  final VoidCallback onStart;
  final int livesPlayed;

  const StartScreen({
    super.key,
    required this.onStart,
    required this.livesPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🌍', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text(
                    'واحد من 8 مليارات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لن تختار أين تولد، ولا من تكون. في كل جولة تولد شخصا عشوائيا '
                    'في مكان ما من العالم، ثم تتخذ قراراته من طفولته حتى موته، '
                    'وتُبنى قصة حياته من اختياراتك أنت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  const _Point(
                      icon: '🎲',
                      text: 'ولادة عشوائية: اسم ودولة وجنس وطبقة عائلية مختلفة كل مرة'),
                  const _Point(
                      icon: '🧭',
                      text: 'قرارات عمرية: مدرسة، حب، عمل، زواج، أطفال، تقاعد، وإرث'),
                  const _Point(
                      icon: '📖',
                      text: 'سجل حياة كامل: كل قرار ونتيجته يُكتب في قصتك'),
                  const _Point(
                      icon: '🕯️',
                      text: 'نهاية حتمية: كل حياة تنتهي، والسؤال هو: كيف عشتها؟'),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('ابدأ حياة جديدة 🎲'),
                  ),
                  if (livesPlayed > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'عشتَ $livesPlayed ${livesPlayed == 1 ? 'حياة' : 'حيوات'} حتى الآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'لعبة قصصية مجانية، تعمل دون إنترنت، ولا تجمع أي بيانات.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final String icon;
  final String text;

  const _Point({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 16, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
