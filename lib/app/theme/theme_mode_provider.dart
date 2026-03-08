import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/core/services/storage/user_session_service.dart';

const _themeModeKey = 'theme_mode';
const _manualDarkOverrideKey = 'manual_dark_override';

final manualDarkOverrideProvider = StateProvider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool(_manualDarkOverrideKey) ?? false;
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref) : super(ThemeMode.light) {
    _loadFromPrefs();
  }

  final Ref _ref;

  void _loadFromPrefs() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_themeModeKey) ?? 'light';

    switch (raw) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
      default:
        state = ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = _ref.read(sharedPreferencesProvider);
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_themeModeKey, value);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setManualDarkOverride(bool enabled) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(_manualDarkOverrideKey, enabled);
    _ref.read(manualDarkOverrideProvider.notifier).state = enabled;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});
