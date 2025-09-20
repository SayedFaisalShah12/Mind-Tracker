import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  static ThemeMode _themeMode = ThemeMode.system;
  static Color _primaryColor = Colors.blue;

  static ThemeMode get themeMode => _themeMode;
  static Color get primaryColor => _primaryColor;

  static final Map<String, Color> _availableColors = {
    'blue': Colors.blue,
    'green': Colors.green,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Colors.pink,
    'teal': Colors.teal,
    'red': Colors.red,
    'indigo': Colors.indigo,
  };

  static List<String> get availableColorNames => _availableColors.keys.toList();
  static Map<String, Color> get availableColors => _availableColors;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);

    // Load primary color
    final colorName = prefs.getString(_primaryColorKey) ?? 'blue';
    _primaryColor = _availableColors[colorName] ?? Colors.blue;
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
  }

  static Future<void> setPrimaryColor(String colorName) async {
    final color = _availableColors[colorName];
    if (color != null) {
      _primaryColor = color;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_primaryColorKey, colorName);
    }
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor.withOpacity(0.1),
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor.withOpacity(0.1),
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[800],
      ),
    );
  }

  static String getCurrentColorName() {
    for (final entry in _availableColors.entries) {
      if (entry.value.value == _primaryColor.value) {
        return entry.key;
      }
    }
    return 'blue';
  }

  static String getCurrentThemeModeName() {
    return _themeModeToString(_themeMode);
  }
}
