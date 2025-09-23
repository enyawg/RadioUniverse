import 'package:flutter/material.dart';

enum AppTheme { dark, light, pastel }

class AppThemes {
  // Dark Theme (Default)
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1F1F1F),
        indicatorColor: Colors.deepPurple.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Colors.deepPurple, fontSize: 12);
          }
          return const TextStyle(color: Colors.white70, fontSize: 12);
        }),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.deepPurple.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Colors.deepPurple, fontSize: 12);
          }
          return const TextStyle(color: Colors.black54, fontSize: 12);
        }),
      ),
    );
  }

  // Pastel Theme
  static ThemeData get pastelTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9C88FF), // Pastel purple
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F6FF), // Very light pastel purple
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE8E0FF), // Light pastel purple
        foregroundColor: Color(0xFF4A4A4A),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF0ECFF), // Pastel purple-white
        elevation: 1,
        shadowColor: const Color(0xFF9C88FF).withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFE8E0FF),
        indicatorColor: const Color(0xFF9C88FF).withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Color(0xFF7B68EE), fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF6A6A6A), fontSize: 12);
        }),
      ),
      // Custom colors for pastel theme
      primaryColor: const Color(0xFF9C88FF),
      dividerColor: const Color(0xFFD0C4FF),
    );
  }

  // Get theme by enum
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return darkTheme;
      case AppTheme.light:
        return lightTheme;
      case AppTheme.pastel:
        return pastelTheme;
    }
  }

  // Get theme name
  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.light:
        return 'Light';
      case AppTheme.pastel:
        return 'Pastel';
    }
  }

  // Get theme icon
  static IconData getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.pastel:
        return Icons.palette;
    }
  }
}