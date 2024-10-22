import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  SharedPreferences? instance;

  init() async {
    instance = await SharedPreferences.getInstance();
  }

  FutureOr _initIfNot() async {
    if (instance == null) await init();
  }

  Future<Locale?> readLocalePreference() async {
    await _initIfNot();
    final String? locale = instance!.getString("locale");
    if (locale != null) return Locale(locale);
    return null;
  }

  writeLocalePreference(String value) async {
    await _initIfNot();
    await instance!.setString("locale", value);
  }
}
