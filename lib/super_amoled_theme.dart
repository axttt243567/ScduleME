import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// X (Twitter) Lights Out Theme
///
/// True Black Mode for Maximum Battery Savings & Minimal Light Emission
///
/// CORE PRINCIPLES (X Twitter Spec):
/// 1. True Black Background (#000000): Main canvas, timeline, headers - OLED power saving
/// 2. Very Dark Gray Cards (#141d26): Tweet cards that lift slightly from background
/// 3. X Blue Accent (#1da1f2): Primary actions, links, highlights
/// 4. Pure White Text (#ffffff): High-emphasis content
/// 5. Medium Gray Text (#8899ac): Secondary text, timestamps, metadata
///
/// TECHNICAL REQUIREMENTS:
/// - Contrast Ratio: Minimum 4.5:1 (WCAG AA)
/// - No elevation shadows (flat design)
/// - Minimal borders (1px subtle gray)
/// - Focus indicators: X Blue for keyboard navigation

final ThemeData superAmoledDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // X LIGHTS OUT COLOR SCHEME (EXACT TWITTER SPEC)
  colorScheme: const ColorScheme.dark(
    // PRIMARY: X Blue - The iconic Twitter blue for actions
    primary: Color(0xFF1DA1F2), // X Blue #1da1f2
    onPrimary: Color(0xFFFFFFFF), // Pure white #ffffff
    primaryContainer: Color(0xFF141D26), // Very Dark Gray for containers
    onPrimaryContainer: Color(0xFFFFFFFF), // Pure white
    // SECONDARY: Engagement colors (retweet green, like pink)
    secondary: Color(0xFF17BF63), // X Green for retweet/success
    onSecondary: Color(0xFFFFFFFF), // Pure white
    secondaryContainer: Color(0xFF141D26), // Very Dark Gray
    onSecondaryContainer: Color(0xFFFFFFFF), // Pure white
    // TERTIARY: Like/favorite pink
    tertiary: Color(0xFFF91880), // X Pink for likes
    onTertiary: Color(0xFFFFFFFF), // Pure white
    tertiaryContainer: Color(0xFF141D26), // Very Dark Gray
    onTertiaryContainer: Color(0xFFFFFFFF), // Pure white
    // ERROR: Destructive actions
    error: Color(0xFFF4212E), // X Red for errors/delete
    onError: Color(0xFFFFFFFF), // Pure white
    errorContainer: Color(0xFF141D26), // Very Dark Gray
    onErrorContainer: Color(0xFFFFFFFF), // Pure white
    // SURFACE HIERARCHY (X LIGHTS OUT SPEC)
    surface: Color(0xFF000000), // True Black #000000 - main background
    onSurface: Color(0xFFFFFFFF), // Pure White #ffffff - primary text
    // Surface variations following X specification
    surfaceContainerLowest: Color(0xFF000000), // True Black - canvas
    surfaceContainerLow: Color(0xFF141D26), // Very Dark Gray - tweet cards
    surfaceContainer: Color(0xFF141D26), // Very Dark Gray - elevated elements
    surfaceContainerHigh: Color(0xFF141D26), // Very Dark Gray - modals
    surfaceContainerHighest: Color(0xFF1F2A36), // Subtle separator color

    onSurfaceVariant: Color(0xFF8899AC), // Medium Gray #8899ac - secondary text
    outline: Color(0xFF1F2A36), // Subtle divider (1px)
    outlineVariant: Color(0xFF141D26), // Very subtle borders
    // Surface tint: No tint in Lights Out (pure flat)
    surfaceTint: Colors.transparent,

    // INVERSE COLORS (for light mode components if needed)
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF1DA1F2),

    shadow: Colors.transparent, // No shadows in Lights Out
    scrim: Color(0xFF000000), // True black overlay
  ),

  // TYPOGRAPHY - X Lights Out Specification
  // Pure White (#ffffff) for primary text, Medium Gray (#8899ac) for secondary
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    // DISPLAY STYLES - Page headers (Pure White)
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800, // Extra bold for headers
      letterSpacing: -0.5,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700, // Bold
      letterSpacing: -0.25,
      color: const Color(0xFFFFFFFF), // Pure White
    ),

    // HEADLINE STYLES - Section headers (Pure White)
    headlineLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w800, // Extra bold like X
      letterSpacing: -0.25,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700, // Bold
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White
    ),

    // TITLE STYLES - Tweet author names, card titles (Pure White)
    titleLarge: GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w700, // Bold like X names
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w700, // Bold
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600, // Semi-bold
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White
    ),

    // BODY STYLES - Tweet content (Pure White)
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400, // Regular - readable
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White for content
      height: 1.4, // Line height for readability
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White
      height: 1.4,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: const Color(0xFF8899AC), // Medium Gray for secondary text
    ),

    // LABEL STYLES - Buttons, timestamps, metadata (Medium Gray)
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700, // Bold for buttons
      letterSpacing: 0,
      color: const Color(0xFFFFFFFF), // Pure White for button text
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600, // Semi-bold
      letterSpacing: 0,
      color: const Color(0xFF8899AC), // Medium Gray for metadata
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0,
      color: const Color(0xFF8899AC), // Medium Gray for timestamps
    ),
  ),

  // FLOATING ACTION BUTTON - X Style (Post Button)
  // Solid X Blue, circular, prominent
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF1DA1F2), // X Blue for "Post" button
    foregroundColor: Color(0xFFFFFFFF), // Pure white icon
    elevation: 0, // No shadow - flat design
    focusElevation: 0,
    hoverElevation: 0,
    highlightElevation: 0,
    shape: CircleBorder(), // Perfect circle like X
  ),

  // CARD THEME - X Lights Out Tweet Cards
  // Very Dark Gray (#141d26) cards on True Black background
  // No borders needed - color difference provides separation
  cardTheme: CardThemeData(
    color: const Color(0xFF141D26), // Very Dark Gray - tweet card color
    surfaceTintColor: Colors.transparent, // No tint in Lights Out
    elevation: 0, // Completely flat - no shadows
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        0,
      ), // No rounding - sharp edges like X
      side: BorderSide.none, // No borders - color separation only
    ),
    clipBehavior: Clip.none,
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  ),

  // NAVIGATION BAR - X Lights Out Bottom Navigation
  // True Black background, X Blue for active state
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF000000), // True Black
    surfaceTintColor: Colors.transparent,
    indicatorColor: Colors.transparent, // No indicator background
    elevation: 0, // Flat
    height: 56, // Compact like X
    labelBehavior:
        NavigationDestinationLabelBehavior.alwaysHide, // Icons only like X
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: Color(0xFFFFFFFF), // Pure White when active
          size: 26,
        );
      }
      return const IconThemeData(
        color: Color(0xFF8899AC), // Medium Gray when inactive
        size: 26,
      );
    }),
  ),

  // INPUT DECORATION THEME - X Lights Out Minimal Inputs
  // Very Dark Gray fill, X Blue focus, minimal 4px radius, 1px borders
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF141D26), // Very Dark Gray
    // Default border - subtle 1px like X Lights Out
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(4), // Minimal 4px rounding
      ),
      borderSide: const BorderSide(color: Color(0xFF1F2A36), width: 1),
    ),

    // Enabled border
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: const BorderSide(color: Color(0xFF1F2A36), width: 1),
    ),

    // Focused border - X Blue, 2px for emphasis
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: const BorderSide(color: Color(0xFF1DA1F2), width: 2),
    ),

    // Error border - X Red
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: const BorderSide(color: Color(0xFFF4212E), width: 1),
    ),

    // Focused error border - X Red, 2px
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      borderSide: const BorderSide(color: Color(0xFFF4212E), width: 2),
    ),

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    // Label styling - Medium Gray for secondary text
    labelStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF8899AC), // Medium Gray
    ),
    floatingLabelStyle: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1DA1F2), // X Blue
    ),
    hintStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF8899AC), // Medium Gray
    ),
  ),

  // APP BAR THEME - X Lights Out Header
  // True Black background, Pure White text
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF000000), // True Black
    foregroundColor: const Color(0xFFFFFFFF), // Pure White
    elevation: 0, // Completely flat
    scrolledUnderElevation: 0, // No elevation on scroll
    surfaceTintColor: Colors.transparent,
    centerTitle: false, // Left-aligned like X
    titleSpacing: 16,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w800, // Extra bold like X
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFFFFFFF), // Pure White icons
      size: 20,
    ),
  ),

  // ELEVATED BUTTON - X Blue "Post" Button Style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1DA1F2), // X Blue
      foregroundColor: const Color(0xFFFFFFFF), // Pure White text
      elevation: 0, // Flat
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      minimumSize: const Size(64, 44), // Minimum tap target
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22), // Fully rounded pill
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700, // Bold
        letterSpacing: 0,
      ),
    ),
  ),

  // FILLED BUTTON - X Blue Primary Actions
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF1DA1F2), // X Blue
      foregroundColor: const Color(0xFFFFFFFF), // Pure White
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      minimumSize: const Size(64, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22), // Fully rounded
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
  ),

  // TEXT BUTTON - Minimal (for secondary actions)
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF1DA1F2), // X Blue
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: const Size(44, 44), // Tap target
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      textStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600, // Semi-bold for text buttons
        letterSpacing: 0,
      ),
    ),
  ),

  // DIALOG THEME - X Lights Out Dialogs
  // Very Dark Gray background on True Black
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF141D26), // Very Dark Gray
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide.none, // No border
    ),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w800, // Extra bold
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFFFFFFF), // Pure White
      height: 1.4,
    ),
  ),

  // BOTTOM SHEET THEME - X Lights Out
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: const Color(0xFF141D26), // Very Dark Gray
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: const Color(0xFF141D26),
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    showDragHandle: true,
    dragHandleColor: const Color(0xFF8899AC), // Medium Gray
  ),

  // CHIP THEME - X Style Pills
  // X Blue when selected, Very Dark Gray when unselected
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF141D26), // Very Dark Gray
    deleteIconColor: const Color(0xFF8899AC), // Medium Gray
    disabledColor: const Color(0xFF000000),
    selectedColor: const Color(0xFF1DA1F2), // X Blue
    secondarySelectedColor: const Color(0xFF1DA1F2),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: const StadiumBorder(), // Full pill shape
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700, // Bold
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFFFFF),
    ),
    side: BorderSide.none, // No border
  ),

  // SNACKBAR THEME - X Lights Out Minimal Notifications
  // Very Dark Gray background, Pure White text, X Blue actions
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF141D26), // Very Dark Gray
    contentTextStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFFFFFFF), // Pure White
    ),
    actionTextColor: const Color(0xFF1DA1F2), // X Blue
    behavior: SnackBarBehavior.floating,
    elevation: 0, // Flat design
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4), // Minimal 4px rounding
      side: const BorderSide(
        color: Color(0xFF1F2A36),
        width: 1,
      ), // Subtle border
    ),
  ),

  // ICON THEME - X Lights Out
  // Medium Gray for inactive/secondary icons
  iconTheme: const IconThemeData(
    color: Color(0xFF8899AC), // Medium Gray
    size: 24,
  ),

  // PRIMARY ICON THEME - Pure White for active icons
  primaryIconTheme: const IconThemeData(
    color: Color(0xFFFFFFFF), // Pure White
    size: 24,
  ),
);
