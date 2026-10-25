import 'package:flutter/material.dart';

/// شاشة البداية: تُفهم من أول نظرة، دون شرح طويل.
/// زر بدء واحد واضح، واستئناف ثانوي للحياة المحفوظة، وشريط من ثلاث
/// خطوات يلخّص دورة اللعب كلها: تولد، تختار، تُروى قصتك.
class StartScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback? onManagement;
  final VoidCallback? onContinue;
  final String? savedName;
  final int? savedAge;
  final int livesPlayed;

  const StartScreen({
    super.key,
    required this.onStart,
    this.onManagement,
    this.onContinue,
    this.savedName,
    this.savedAge,
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
                  const Text('🌍',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text(
                    'واحد من 8 مليارات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'حياة واحدة. قراراتك أنت. وقصة تُروى حتى النهاية.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.7),
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    children: [
                      Expanded(child: _Step(icon: '🎲', label: 'تولد')),
                      SizedBox(width: 8),
                      Text('›', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Expanded(child: _Step(icon: '🧭', label: 'تختار')),
                      SizedBox(width: 8),
                      Text('›', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Expanded(child: _Step(icon: '📖', label: 'تُروى قصتك')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'كل قرار له ثمن، وكل حياة تنتهي بسؤال واحد: كيف عشتها؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.7),
                  ),
                  const SizedBox(height: 36),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('ابدأ حياة جديدة 🎲'),
                  ),
                  if (onManagement != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onManagement,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('لوحة إدارة الحياة الجديدة 🧭'),
                    ),
                  ],
                  if (onContinue != null && savedName != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onContinue,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                          'واصل حياة $savedName (عمر ${savedAge ?? 0}) ▶️'),
                    ),
                  ],
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
                    'تعمل دون إنترنت، ولا تجمع أي بيانات.',
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

class _Step extends StatelessWidget {
  final String icon;
  final String label;

  const _Step({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
