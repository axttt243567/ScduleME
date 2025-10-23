import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Super AMOLED Dark Theme
///
/// Expressive & Modern AMOLED-First Dark Theme
///
/// CORE PRINCIPLES:
/// 1. AMOLED-First Design: Optimized for AMOLED screens with pure black (#000000)
///    background and near-black (#101010) surfaces to maximize power efficiency
///    and create stunning visual contrast.
///
/// 2. Monochromatic Focus: Built around a single vibrant blue accent (#64B5F6)
///    with analogous cool grays and complementary blues. This creates a cohesive,
///    modern aesthetic that feels fluid and engaging.
///
/// 3. Expressive Shapes: Modern, varied geometries - 'squircle' shapes (20px radius)
///    for FABs, large soft radii (24px) for Cards. This breaks away from traditional
///    design and adds personality.
///
/// 4. Emphasized Typography: Uses 'Inter' font with bold display/headline styles
///    (w700-w800) for an editorial, confident feel that guides the user's eye.

final ThemeData superAmoledDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // AMOLED-OPTIMIZED COLOR SCHEME
  // Monochromatic blue palette with pure blacks for maximum AMOLED efficiency
  colorScheme: const ColorScheme.dark(
    // PRIMARY: Vibrant Blue - The hero color that defines the brand
    primary: Color(0xFF64B5F6), // Light Blue 300 - vibrant yet readable
    onPrimary: Color(0xFF000000), // Pure black text for maximum contrast
    primaryContainer: Color(0xFF1565C0), // Blue 800 - deep, rich container
    onPrimaryContainer: Color(0xFFBBDEFB), // Light Blue 100 - soft contrast
    // SECONDARY: Analogous Blue - Supports the primary without competing
    secondary: Color(0xFF42A5F5), // Blue 400 - slightly darker than primary
    onSecondary: Color(0xFF000000), // Pure black maintains consistency
    secondaryContainer: Color(0xFF0D47A1), // Blue 900 - very deep blue
    onSecondaryContainer: Color(0xFFE3F2FD), // Blue 50 - almost white blue
    // TERTIARY: Cool Gray - Neutral complement for hierarchy
    tertiary: Color(0xFF90CAF9), // Light Blue 200 - softer blue accent
    onTertiary: Color(0xFF000000), // Pure black for clarity
    tertiaryContainer: Color(0xFF263238), // Blue Gray 900 - dark neutral
    onTertiaryContainer: Color(0xFFCFD8DC), // Blue Gray 100 - light neutral
    // ERROR: Standard red for warnings/errors
    error: Color(0xFFEF5350), // Red 400 - visible but not alarming
    onError: Color(0xFF000000), // Pure black
    errorContainer: Color(0xFFB71C1C), // Red 900 - deep error state
    onErrorContainer: Color(0xFFFFCDD2), // Red 100 - light error text
    // SURFACE HIERARCHY (AMOLED-First)
    // Pure black background saves battery and creates infinite contrast on AMOLED
    surface: Color(0xFF101010), // Near-black for elevated surfaces
    onSurface: Color(0xFFE1E1E1), // Light gray text - easy on the eyes
    // Additional surface variations for subtle elevation
    surfaceContainerLowest: Color(0xFF000000), // Pure black - true background
    surfaceContainerLow: Color(0xFF0A0A0A), // Subtle lift from background
    surfaceContainer: Color(0xFF101010), // Standard surface
    surfaceContainerHigh: Color(0xFF1A1A1A), // More pronounced elevation
    surfaceContainerHighest: Color(0xFF242424), // Highest elevation

    onSurfaceVariant: Color(
      0xFFB0B0B0,
    ), // Muted text for less important content
    outline: Color(0xFF404040), // Subtle borders that don't distract
    outlineVariant: Color(0xFF2A2A2A), // Even more subtle borders
    // Surface tint uses primary blue for Material elevation effects
    surfaceTint: Color(0xFF64B5F6), // Primary blue tint
    // INVERSE COLORS (for reverse contrast scenarios)
    inverseSurface: Color(0xFFE1E1E1), // Light gray for inverse
    onInverseSurface: Color(0xFF101010), // Dark text on light
    inversePrimary: Color(0xFF1565C0), // Deep blue for inverse primary

    shadow: Color(0xFF000000), // Pure black shadows for depth
    scrim: Color(0xFF000000), // Pure black scrim for overlays
  ),

  // EMPHASIZED TYPOGRAPHY - Inter Font Family
  // Uses bold weights (w700-w800) for display and headlines to create
  // an editorial, confident aesthetic that guides user attention
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    // DISPLAY STYLES - Largest, most expressive text
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w800, // Extra bold for maximum impact
      letterSpacing: -0.25,
      color: const Color(0xFFE1E1E1),
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      color: const Color(0xFFE1E1E1),
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w700, // Bold for strong presence
      letterSpacing: 0,
      color: const Color(0xFFE1E1E1),
    ),

    // HEADLINE STYLES - Page titles and section headers
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700, // Bold maintains hierarchy
      letterSpacing: 0,
      color: const Color(0xFFE1E1E1),
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: const Color(0xFFE1E1E1),
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600, // Semi-bold for subtlety
      letterSpacing: 0,
      color: const Color(0xFFE1E1E1),
    ),

    // TITLE STYLES - Card titles, list items
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFFE1E1E1),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: const Color(0xFFE1E1E1),
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500, // Medium for body context
      letterSpacing: 0.1,
      color: const Color(0xFFE1E1E1),
    ),

    // BODY STYLES - Main content
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular for readability
      letterSpacing: 0.5,
      color: const Color(0xFFE1E1E1),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFFE1E1E1),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFFB0B0B0), // Muted for secondary info
    ),

    // LABEL STYLES - Buttons, chips
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600, // Semi-bold for prominence
      letterSpacing: 0.1,
      color: const Color(0xFFE1E1E1),
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: const Color(0xFFE1E1E1),
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: const Color(0xFFB0B0B0),
    ),
  ),

  // FLOATING ACTION BUTTON - 'Squircle' Shape (20px radius)
  // The squircle shape (rounded square) is more expressive than a circle,
  // adding modern personality while remaining familiar and tappable
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF64B5F6), // Primary blue - stands out beautifully
    foregroundColor: Color(0xFF000000), // Pure black for maximum contrast
    elevation: 8, // Higher elevation for prominence on AMOLED
    focusElevation: 10,
    hoverElevation: 10,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)), // Squircle!
    ),
  ),

  // CARD THEME - Large Soft Radius (24px)
  // Large border radius creates a modern, friendly feel. The soft curves
  // make content feel more approachable and less rigid than sharp corners
  cardTheme: CardThemeData(
    color: const Color(0xFF101010), // Near-black surface
    surfaceTintColor: const Color(0xFF64B5F6), // Blue tint for depth
    elevation: 2, // Subtle elevation maintains flatness
    shadowColor: Colors.black.withValues(
      alpha: 0.5,
    ), // Strong shadows on AMOLED
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // Large, soft radius
    ),
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.all(8),
  ),

  // NAVIGATION BAR - Modern, Expressive Shape
  // Uses consistent 20px radius to match FAB, creating visual harmony
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF101010), // Near-black to match cards
    surfaceTintColor: const Color(0xFF64B5F6), // Blue tint
    indicatorColor: const Color(0xFF64B5F6), // Primary blue indicator
    elevation: 0, // Flat design on AMOLED looks cleaner
    height: 80, // Slightly taller for modern proportions
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: Color(0xFF000000), // Black on blue indicator
          size: 24,
        );
      }
      return const IconThemeData(
        color: Color(0xFFB0B0B0), // Muted gray when unselected
        size: 24,
      );
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600, // Bold when selected
          color: const Color(0xFF64B5F6), // Primary blue
        );
      }
      return GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium when unselected
        color: const Color(0xFFB0B0B0), // Muted gray
      );
    }),
  ),

  // INPUT DECORATION THEME - Expressive Shape
  // Rounded inputs (16px) feel more modern and approachable than sharp rectangles
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1A1A), // Slightly elevated from surface
    // Default border - subtle outline
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ), // Expressive curve
      borderSide: const BorderSide(color: Color(0xFF404040), width: 1),
    ),

    // Focused border - primary blue highlight
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(
        color: Color(0xFF64B5F6),
        width: 2,
      ), // Thicker, vibrant
    ),

    // Error border - red highlight
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1),
    ),

    // Focused error border
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
    ),

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

    // Label and hint styling using Inter
    labelStyle: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFB0B0B0),
    ),
    floatingLabelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600, // Bold when floating
      color: const Color(0xFF64B5F6), // Primary blue
    ),
    hintStyle: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF808080),
    ),
  ),

  // APP BAR THEME - Clean and Modern
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF000000), // Pure black for AMOLED
    foregroundColor: const Color(0xFFE1E1E1),
    elevation: 0, // Flat for modern aesthetic
    scrolledUnderElevation: 4, // Subtle elevation when scrolled
    surfaceTintColor: const Color(0xFF64B5F6), // Blue tint on scroll
    centerTitle: false, // Left-aligned for editorial feel
    titleSpacing: 16,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w700, // Bold for emphasis
      color: const Color(0xFFE1E1E1),
    ),
  ),

  // ELEVATED BUTTON - Primary Blue with Expressive Shape
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF64B5F6),
      foregroundColor: const Color(0xFF000000),
      elevation: 4,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Expressive curves
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600, // Semi-bold for labels
        letterSpacing: 0.1,
      ),
    ),
  ),

  // FILLED BUTTON - Primary Blue
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF64B5F6),
      foregroundColor: const Color(0xFF000000),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),

  // TEXT BUTTON - Minimal with Blue Text
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF64B5F6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),

  // DIALOG THEME - Expressive Rounded Corners
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1A1A1A),
    surfaceTintColor: const Color(0xFF64B5F6),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28), // Large, friendly radius
    ),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700, // Bold titles
      color: const Color(0xFFE1E1E1),
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFE1E1E1),
    ),
  ),

  // BOTTOM SHEET THEME - Modern Rounded Top
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: const Color(0xFF1A1A1A),
    surfaceTintColor: const Color(0xFF64B5F6),
    modalBackgroundColor: const Color(0xFF1A1A1A),
    elevation: 8,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28), // Large radius for expressiveness
      ),
    ),
    showDragHandle: true,
    dragHandleColor: const Color(0xFF404040),
  ),

  // CHIP THEME - Rounded Pills
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1A1A1A),
    deleteIconColor: const Color(0xFFB0B0B0),
    disabledColor: const Color(0xFF0A0A0A),
    selectedColor: const Color(0xFF64B5F6),
    secondarySelectedColor: const Color(0xFF42A5F5),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: const StadiumBorder(), // Full rounded pill shape
    labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    side: BorderSide.none,
  ),

  // SNACKBAR THEME - Modern Floating Design
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1A1A1A),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFE1E1E1),
    ),
    actionTextColor: const Color(0xFF64B5F6), // Primary blue for actions
    behavior: SnackBarBehavior.floating,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded for consistency
    ),
  ),

  // ICON THEME - Muted Gray for Visual Balance
  iconTheme: const IconThemeData(
    color: Color(0xFFB0B0B0), // Muted gray
    size: 24,
  ),

  // PRIMARY ICON THEME - Vibrant Blue for Active Icons
  primaryIconTheme: const IconThemeData(
    color: Color(0xFF64B5F6), // Primary blue
    size: 24,
  ),
);
