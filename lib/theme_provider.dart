import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  bool _isDarkMode = false;
  SharedPreferences? _prefs;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF007AFF), // iOS blue
        secondary: Color(0xFF5856D6), // iOS purple
        surface: Color(0xFFF2F2F7), // iOS light gray
        background: Color(0xFFFFFFFF), // Pure white
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1C1C1E), // iOS dark text
        onBackground: Color(0xFF1C1C1E),
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS background
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        foregroundColor: Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A84FF), // iOS blue (dark variant)
        secondary: Color(0xFF5E5CE6), // iOS purple (dark variant)
        surface: Color(0xFF1C1C1E), // iOS dark surface
        background: Color(0xFF000000), // Pure black
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFFFFFFF), // White text on dark
        onBackground: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000), // iOS dark background
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }

  // Theme-aware colors that can be used throughout the app
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1C1C1E)
        : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1C1C1E);
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF8E8E93);
  }

  static Color getSeparatorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF38383A)
        : const Color(0xFFE5E5EA);
  }

  static Color getChipBackgroundColor(Color baseColor, BuildContext context) {
    return baseColor.withOpacity(
      Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1,
    );
  }

  static Color getChipBorderColor(Color baseColor, BuildContext context) {
    return baseColor.withOpacity(
      Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.3,
    );
  }
}
