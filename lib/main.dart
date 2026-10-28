import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/life_management_screen.dart';

void main() {
  runApp(const LifeApp());
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
