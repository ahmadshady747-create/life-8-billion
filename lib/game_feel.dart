import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// طبقة إحساس اللعب (المرحلة 1): عدّادات متحركة وأشرطة متحركة ورد
/// فعل صوتي/لمسي اختياري، دون أي أصول خارجية ودون إنترنت.
/// الصوت يستخدم أصوات النظام المدمجة فقط، وإن فشل لا ينهار التطبيق.
/// لا يغيّر هذا الملف أي رقم من منطق الإدارة؛ هو عرض متحرك للأرقام
/// الحقيقية نفسها.
class AnimatedCountText extends StatelessWidget {
  final String prefix;
  final int value;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedCountText({
    super.key,
    required this.prefix,
    required this.value,
    this.suffix = '',
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      builder: (context, animatedValue, _) {
        return Text(
          '$prefix$animatedValue$suffix',
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final String label;
  final double fraction;
  final Color? color;

  const AnimatedBar({
    super.key,
    required this.label,
    required this.fraction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            AnimatedCountText(
              prefix: '',
              value: (clamped * 100).round(),
              suffix: '%',
            ),
          ],
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: clamped),
          duration: const Duration(milliseconds: 700),
          builder: (context, animatedValue, _) {
            return LinearProgressIndicator(
              value: animatedValue,
              color: color,
              minHeight: 8,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class GameFeel {
  const GameFeel._();

  static void playAction({required bool soundOn}) {
    if (soundOn) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {
        // الصوت اختياري: فشله لا يوقف اللعب أبدا.
      }
    }
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void playImportant({required bool soundOn}) {
    if (soundOn) {
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
