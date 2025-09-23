import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.dark; // Default to dark
  static const String _themeKey = 'app_theme';

  AppTheme get currentTheme => _currentTheme;
  ThemeData get themeData => AppThemes.getTheme(_currentTheme);

  ThemeProvider() {
    _loadTheme();
  }

  /// Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0; // Default to dark (index 0)
      _currentTheme = AppTheme.values[themeIndex];
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
      _currentTheme = AppTheme.dark;
    }
  }

  /// Change theme and save to SharedPreferences
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return;
    
    _currentTheme = theme;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      print('Theme saved: ${AppThemes.getThemeName(theme)}');
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  /// Cycle through themes (for quick switching)
  Future<void> cycleTheme() async {
    final themes = AppTheme.values;
    final currentIndex = themes.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % themes.length;
    await setTheme(themes[nextIndex]);
  }

  /// Get all available themes with their info
  List<Map<String, dynamic>> get availableThemes {
    return AppTheme.values.map((theme) => {
      'theme': theme,
      'name': AppThemes.getThemeName(theme),
      'icon': AppThemes.getThemeIcon(theme),
      'isSelected': theme == _currentTheme,
    }).toList();
  }
}