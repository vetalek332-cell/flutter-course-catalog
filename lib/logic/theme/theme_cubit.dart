import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Дополнительная опция «Тёмная тема»: переключатель внутри приложения,
/// выбор сохраняется после перезапуска (SharedPreferences).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.light);

  static const String _prefsKey = 'themeMode';

  final SharedPreferences _prefs;

  Future<void> load() async {
    final saved = _prefs.getString(_prefsKey);
    if (saved != null) {
      final mode = ThemeMode.values.asNameMap()[saved];
      if (mode != null) emit(mode);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_prefsKey, mode.name);
  }

  void toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
