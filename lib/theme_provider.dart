import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, midnightBloom }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  AppTheme _currentTheme = AppTheme.light;
  SharedPreferences? _prefs;

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppTheme.dark;
  bool get isMidnightBloom => _currentTheme == AppTheme.midnightBloom;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs?.getInt(_themeKey) ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _prefs?.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    // Legacy support - cycles through themes
    switch (_currentTheme) {
      case AppTheme.light:
        await setTheme(AppTheme.dark);
        break;
      case AppTheme.dark:
        await setTheme(AppTheme.midnightBloom);
        break;
      case AppTheme.midnightBloom:
        await setTheme(AppTheme.light);
        break;
    }
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

  // Midnight Bloom Theme - Deep purple/pink gradient theme
  static ThemeData get midnightBloomTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE91E63), // Deep pink
        secondary: Color(0xFF9C27B0), // Purple
        surface: Color(0xFF1A0E2E), // Deep purple surface
        background: Color(0xFF0D0520), // Very deep purple background
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF8BBD9), // Light pink text
        onBackground: Color(0xFFF8BBD9),
      ),
      scaffoldBackgroundColor: const Color(
        0xFF0D0520,
      ), // Deep purple background
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A0E2E),
        foregroundColor: Color(0xFFF8BBD9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1A0E2E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }

  // Get current theme data
  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return lightTheme;
      case AppTheme.dark:
        return darkTheme;
      case AppTheme.midnightBloom:
        return midnightBloomTheme;
    }
  }

  // Theme-aware colors that can be used throughout the app
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.background == const Color(0xFF0D0520)) {
      return const Color(0xFF0D0520); // Midnight Bloom
    }

    return brightness == Brightness.dark
        ? const Color(0xFF000000) // Dark theme
        : const Color(0xFFF2F2F7); // Light theme
  }

  static Color getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.surface == const Color(0xFF1A0E2E)) {
      return const Color(0xFF1A0E2E); // Midnight Bloom
    }

    return brightness == Brightness.dark
        ? const Color(0xFF1C1C1E) // Dark theme
        : Colors.white; // Light theme
  }

  static Color getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.onSurface == const Color(0xFFF8BBD9)) {
      return const Color(0xFFF8BBD9); // Midnight Bloom
    }

    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFFFFF) // Dark theme
        : const Color(0xFF1C1C1E); // Light theme
  }

  static Color getSecondaryTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.onSurface == const Color(0xFFF8BBD9)) {
      return const Color(0xFFF8BBD9).withOpacity(0.7); // Midnight Bloom
    }

    return const Color(0xFF8E8E93); // Same for light and dark
  }

  static Color getSeparatorColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.surface == const Color(0xFF1A0E2E)) {
      return const Color(0xFF9C27B0).withOpacity(0.3); // Midnight Bloom
    }

    return brightness == Brightness.dark
        ? const Color(0xFF38383A) // Dark theme
        : const Color(0xFFE5E5EA); // Light theme
  }

  static Color getChipBackgroundColor(Color baseColor, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.surface == const Color(0xFF1A0E2E)) {
      return baseColor.withOpacity(
        0.15,
      ); // Midnight Bloom - slightly more opacity
    }

    return baseColor.withOpacity(
      Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1,
    );
  }

  static Color getChipBorderColor(Color baseColor, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (colorScheme.surface == const Color(0xFF1A0E2E)) {
      return baseColor.withOpacity(
        0.5,
      ); // Midnight Bloom - more prominent borders
    }

    return baseColor.withOpacity(
      Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.3,
    );
  }

  // Get theme display name
  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.midnightBloom:
        return 'Midnight Bloom';
    }
  }

  // Get theme icon
  static IconData getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.midnightBloom:
        return Icons.nightlight_round;
    }
  }
}
