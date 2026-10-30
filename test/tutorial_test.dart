import 'package:flutter_test/flutter_test.dart';
import 'package:life_8_billion/tutorial.dart';

void main() {
  test('خطوات التعليم تتقدم بالقرارات الحقيقية فقط', () {
    expect(nextTutorialStep(0, TutorialEvent.advanced), 1);
    expect(nextTutorialStep(0, TutorialEvent.managementAction), 0);
    expect(nextTutorialStep(1, TutorialEvent.advanced), 1);
    expect(nextTutorialStep(1, TutorialEvent.managementAction), 2);
    expect(nextTutorialStep(2, TutorialEvent.advanced), 3);
    expect(nextTutorialStep(2, TutorialEvent.managementAction), 2);
    expect(nextTutorialStep(1, TutorialEvent.skipped), 3);
    expect(nextTutorialStep(3, TutorialEvent.advanced), 3);
  });

  test('عناوين وتلميحات التعليم غير فارغة لكل خطوة', () {
    for (var step = 0; step <= 3; step++) {
      expect(tutorialStepTitle(step).isNotEmpty, isTrue);
      expect(tutorialStepHint(step).isNotEmpty, isTrue);
    }
    expect(tutorialStepTitle(0), contains('1 من 3'));
    expect(tutorialStepHint(0), contains('تقدم شهرا'));
  });
}
