import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  static const String _key = 'app_locale';
  static const String en = 'en';
  static const String hi = 'hi';

  final ValueNotifier<String> locale = ValueNotifier<String>(en);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? en;
    locale.value = saved;
  }

  Future<void> setLocale(String lang) async {
    locale.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang);
  }

  Future<void> toggle() async {
    final next = locale.value == en ? hi : en;
    await setLocale(next);
  }

  bool get isHindi => locale.value == hi;
  bool get isEnglish => locale.value == en;
}
