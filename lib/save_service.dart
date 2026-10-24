import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_engine.dart';

/// حفظ الحياة الحالية محليا على الجهاز فقط، لاستئنافها بعد إغلاق التطبيق.
/// لا يُرسل شيء إلى أي خادم.
class SaveService {
  static const _key = 'saved_life_v2';

  static Future<void> save(GameEngine engine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(engine.toJson()));
  }

  static Future<GameEngine?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final engine = GameEngine.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
      if (engine.isDead) return null;
      return engine;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
