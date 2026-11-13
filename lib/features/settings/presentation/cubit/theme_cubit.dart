import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit responsible for managing and persisting the application's [ThemeMode].
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePrefKey = 'roadlink_theme_mode';
  final SharedPreferences? _prefs;

  ThemeCubit({SharedPreferences? prefs})
      : _prefs = prefs,
        super(_loadInitialTheme(prefs));

  static ThemeMode _loadInitialTheme(SharedPreferences? prefs) {
    final saved = prefs?.getString(_themePrefKey);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  /// Returns true when the active theme mode is dark.
  bool get isDarkMode => state == ThemeMode.dark;

  /// Toggles directly between [ThemeMode.light] and [ThemeMode.dark].
  Future<void> toggleTheme([bool? isDark]) async {
    final targetMode = (isDark ?? (state != ThemeMode.dark))
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(targetMode);
  }

  /// Sets a specific [ThemeMode] and persists it locally.
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _prefs?.setString(_themePrefKey, mode.name);
  }
}

