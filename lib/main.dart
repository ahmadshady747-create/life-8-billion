import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game_engine.dart';
import 'screens/death_screen.dart';
import 'screens/game_screen.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const LifeApp());
}

enum _Screen { start, game, death }

/// التطبيق كله عربي وباتجاه يمين إلى يسار، بتصميم Material 3 هادئ.
/// لا توجد أي حزمة خارجية: كل شيء من Flutter نفسه، ليعمل دون إنترنت
/// ويُبنى بسهولة على أندرويد.
class LifeApp extends StatefulWidget {
  const LifeApp({super.key});

  @override
  State<LifeApp> createState() => _LifeAppState();
}

class _LifeAppState extends State<LifeApp> {
  final GameEngine _engine = GameEngine();
  _Screen _screen = _Screen.start;
  int _livesPlayed = 0;

  void _startNewLife() {
    setState(() {
      _engine.newLife();
      _livesPlayed++;
      _screen = _Screen.game;
    });
  }

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
      home: switch (_screen) {
        _Screen.start => StartScreen(
            onStart: _startNewLife,
            livesPlayed: _livesPlayed,
          ),
        _Screen.game => GameScreen(
            // مفتاح جديد لكل حياة، ليعيد شاشة اللعب حالتها (بطاقة الولادة).
            key: ValueKey(_livesPlayed),
            engine: _engine,
            onNewLife: _startNewLife,
            onFinish: () => setState(() => _screen = _Screen.death),
          ),
        _Screen.death => DeathScreen(
            engine: _engine,
            onNewLife: _startNewLife,
            onHome: () => setState(() => _screen = _Screen.start),
          ),
      },
    );
  }
}
