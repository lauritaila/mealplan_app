import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageCodeKey = 'app_language_code';

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale?>((
  ref,
) {
  return AppLocaleNotifier();
});

class AppLocaleNotifier extends StateNotifier<Locale?> {
  AppLocaleNotifier() : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString(_languageCodeKey);
    if (storedCode == null || storedCode.isEmpty) return;
    state = Locale(storedCode);
  }

  Future<void> setLanguageCode(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  Future<void> syncFromRemote(String? remoteLanguageCode) async {
    if (remoteLanguageCode == null || remoteLanguageCode.isEmpty) {
      return;
    }
    await setLanguageCode(remoteLanguageCode);
  }
}
