import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/life_management_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  // حماية تشخيصية لإصلاح الانهيار 2026-10-28: لم يُثبت سبب Dart محدد
  // لانهيار الحياة عند الفتح (المانيفست وdex ومسار الإقلاع سليمة على الورق)،
  // فإذا هرب خطأ Dart غير معالج من التطبيق، تُعرض شاشة خطأ بنص الخطأ
  // بدل الإغلاق الصامت، ولا يُخفى الخطأ ولا يُتجاهل.
  // هذا لا يصلح انهيارا أصليا (Native) إن كان هو السبب، ولا يُدعى إصلاحا له.
  runZonedGuarded(
    () {
      runApp(const LifeApp());
    },
    (error, stack) {
      runApp(
        StartupErrorApp(error: error.toString(), stack: stack.toString()),
      );
    },
  );
}

/// شاشة تشخيص بدء التشغيل: تظهر نص الخطأ غير المعالج فقط، مع زر
/// إعادة محاولة يفتح التطبيق من جديد. تُستخدم فقط عند هروب خطأ Dart.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    required this.stack,
  });

  final String error;
  final String stack;

  @override
  Widget build(BuildContext context) {
    final shortStack = stack.length > 800 ? stack.substring(0, 800) : stack;
    return MaterialApp(
      title: 'واحد من 8 مليارات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppBar(title: const Text('خطأ عند بدء اللعبة')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'حدث خطأ عند بدء اللعبة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(error),
              const SizedBox(height: 12),
              Text(shortStack),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => runApp(const LifeApp()),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// التطبيق كله عربي وباتجاه يمين إلى يسار، بتصميم Material 3 هادئ.
/// الحفظ محلي فقط عبر shared_preferences، ولا يحتاج إنترنت.
/// المرحلة 1 من هدف الإنهاء: لوحة إدارة الحياة هي الشاشة الرئيسية مباشرة.
/// محرك الخيارات القديم لم يعد في مسار اللعب الرئيسي: ملفاته ما زالت
/// في المستودع وفي تاريخ GitHub، لكن لا شاشة بداية ولا زر يوصله،
/// ولا يُحمَّل حفظه عند فتح التطبيق. حفظ الإدارة (life_management_v1)
/// هو الحفظ الوحيد الذي يُستأنف، وتستأنفه لوحة الإدارة نفسها عند فتحها.
class LifeApp extends StatelessWidget {
  const LifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'واحد من 8 مليارات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: null,
        scaffoldBackgroundColor: const Color(0xFFF6F1E8),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFE5DDD0)),
          ),
        ),
      ),
      home: const LifeManagementScreen(),
    );
  }
}
