import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box('settings');
    final isDark = box.get('isDarkMode', defaultValue: false) as bool;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final box = Hive.box('settings');
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      box.put('isDarkMode', true);
    } else {
      state = ThemeMode.light;
      box.put('isDarkMode', false);
    }
  }

  bool get isDark => state == ThemeMode.dark;
}
