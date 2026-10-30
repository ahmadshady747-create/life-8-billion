/// المرحلة 4 — التعليم التفاعلي لأول خمس دقائق، منطق خطوات
/// نقي دون واجهة: اللاعب يتخذ أول قرار إداري خلال الدقيقة
/// الأولى (تقدم شهرا)، ثم إجراء إداريا حقيقيا (تفعيل الرياضة
/// أو بدء مشروع)، ثم شهرا ثانيا ليرى أثر قراره، فينتهي بلاعب
/// يفهم اللعب دون قراءة دليل. الخطوة 3 تعني انتهاء التعليم.
/// لا يغيّر هذا الملف أي رقم إدارة؛ هو آلة حالات للخطوات فقط.
enum TutorialEvent { advanced, managementAction, skipped }

int nextTutorialStep(int step, TutorialEvent event) {
  if (step >= 3) return 3;
  switch (event) {
    case TutorialEvent.skipped:
      return 3;
    case TutorialEvent.advanced:
      if (step == 0) return 1;
      if (step == 2) return 3;
      return step;
    case TutorialEvent.managementAction:
      if (step == 1) return 2;
      return step;
  }
}

String tutorialStepTitle(int step) {
  switch (step) {
    case 0:
      return 'الخطوة 1 من 3: أول شهر';
    case 1:
      return 'الخطوة 2 من 3: أول إجراء إداري';
    case 2:
      return 'الخطوة 3 من 3: أثر قرارك';
    default:
      return 'انتهى التعليم';
  }
}

String tutorialStepHint(int step) {
  switch (step) {
    case 0:
      return 'اضغط «تقدم شهرا» بالأعلى — هذه أول قرار: تمرير شهر وترى نتيجته فورا في التقرير والمشهد الحي.';
    case 1:
      return 'اختر أحد الزرين أدناه — تفعيل الرياضة أو بدء مشروع — وسترى أرقامك تتغير فورا. هذا قرار إداري حقيقي، لا خيار سردي.';
    case 2:
      return 'اضغط «تقدم شهرا» مجددا لترى أثر قرارك في التقرير الجديد، ثم تكون قد فهمت اللعب دون قراءة أي دليل.';
    default:
      return 'أحسنت! أنت تفهم اللعب الآن. تابع إدارتك بحرية.';
  }
}
