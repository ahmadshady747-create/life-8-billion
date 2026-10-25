import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game_engine.dart';
import 'save_service.dart';
import 'screens/death_screen.dart';
import 'screens/game_screen.dart';
import 'screens/life_management_screen.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const LifeApp());
}

enum _Screen { start, game, death }

/// التطبيق كله عربي وباتجاه يمين إلى يسار، بتصميم Material 3 هادئ.
/// الحفظ محلي فقط عبر shared_preferences، ولا يحتاج إنترنت.
class LifeApp extends StatefulWidget {
  const LifeApp({super.key});

  @override
  State<LifeApp> createState() => _LifeAppState();
}

class _LifeAppState extends State<LifeApp> {
  GameEngine _engine = GameEngine();
  _Screen _screen = _Screen.start;
  int _livesPlayed = 0;
  GameEngine? _savedLife;
  bool _loadingSaved = true;

  @override
  void initState() {
    super.initState();
    SaveService.load().then((saved) {
      if (mounted) {
        setState(() {
          _savedLife = saved;
          _loadingSaved = false;
        });
      }
    });
  }

  void _startNewLife() {
    setState(() {
      _engine = GameEngine();
      _engine.newLife();
      _livesPlayed++;
      _savedLife = null;
      _screen = _Screen.game;
    });
    SaveService.save(_engine);
  }

  void _continueSaved() {
    final saved = _savedLife;
    if (saved == null) return;
    setState(() {
      _engine = saved;
      _livesPlayed++;
      _screen = _Screen.game;
    });
  }

  Future<void> _onProgress() => SaveService.save(_engine);

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
        _Screen.start => Builder(
            builder: (ctx) => StartScreen(
            onStart: _startNewLife,
            onManagement: () {
              Navigator.of(ctx).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LifeManagementScreen(),
                ),
              );
            },
            onContinue: _loadingSaved ? null : (_savedLife == null ? null : _continueSaved),
            savedName: _savedLife?.person.fullName,
            savedAge: _savedLife?.age,
            livesPlayed: _livesPlayed,
          ),
          ),
        _Screen.game => GameScreen(
            key: ValueKey(_livesPlayed),
            engine: _engine,
            onNewLife: _startNewLife,
            onProgress: _onProgress,
            onFinish: () {
              SaveService.clear();
              setState(() => _screen = _Screen.death);
            },
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
