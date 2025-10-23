# Super AMOLED Theme - Developer Quick Reference

## Import the Theme
```dart
import 'super_amoled_theme.dart';

// In MaterialApp
MaterialApp(
  theme: superAmoledDarkTheme,
  darkTheme: superAmoledDarkTheme,
  themeMode: ThemeMode.dark,
  home: YourHomePage(),
);
```

## Accessing Theme in Widgets

### Get Theme Data
```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final textTheme = theme.textTheme;
```

## Color Reference

### Primary Colors (Vibrant Blue)
```dart
colorScheme.primary           // #64B5F6 - Main actions, FAB, highlights
colorScheme.onPrimary         // #000000 - Text on primary
colorScheme.primaryContainer  // #1565C0 - Deep blue containers
colorScheme.onPrimaryContainer // #BBDEFB - Text on primary container
```

### Secondary Colors (Analogous Blue)
```dart
colorScheme.secondary         // #42A5F5 - Supporting actions
colorScheme.onSecondary       // #000000 - Text on secondary
colorScheme.secondaryContainer // #0D47A1 - Deep blue container
colorScheme.onSecondaryContainer // #E3F2FD - Text on secondary container
```

### Tertiary Colors (Soft Blue)
```dart
colorScheme.tertiary          // #90CAF9 - Subtle accents
colorScheme.onTertiary        // #000000 - Text on tertiary
colorScheme.tertiaryContainer // #263238 - Dark neutral container
colorScheme.onTertiaryContainer // #CFD8DC - Text on tertiary container
```

### Surface Hierarchy (AMOLED Optimized)
```dart
colorScheme.surfaceContainerLowest  // #000000 - Pure black background
colorScheme.surfaceContainerLow     // #0A0A0A - Subtle lift
colorScheme.surface                 // #101010 - Standard surface
colorScheme.surfaceContainer        // #101010 - Standard container
colorScheme.surfaceContainerHigh    // #1A1A1A - Elevated surface
colorScheme.surfaceContainerHighest // #242424 - Highest elevation

colorScheme.onSurface          // #E1E1E1 - Primary text
colorScheme.onSurfaceVariant   // #B0B0B0 - Secondary text
```

### Outlines & Borders
```dart
colorScheme.outline            // #404040 - Standard borders
colorScheme.outlineVariant     // #2A2A2A - Subtle borders
```

### Error Colors
```dart
colorScheme.error              // #EF5350 - Error states
colorScheme.onError            // #000000 - Text on error
colorScheme.errorContainer     // #B71C1C - Error container
colorScheme.onErrorContainer   // #FFCDD2 - Text on error container
```

## Typography Reference

### Display Styles (Largest Text)
```dart
textTheme.displayLarge   // 57px, w800 (Extra Bold)
textTheme.displayMedium  // 45px, w800
textTheme.displaySmall   // 36px, w700 (Bold)
```

### Headline Styles (Page Titles)
```dart
textTheme.headlineLarge  // 32px, w700 (Bold)
textTheme.headlineMedium // 28px, w700
textTheme.headlineSmall  // 24px, w600 (Semi-Bold)
```

### Title Styles (Card Titles)
```dart
textTheme.titleLarge     // 22px, w600 (Semi-Bold)
textTheme.titleMedium    // 16px, w600
textTheme.titleSmall     // 14px, w500 (Medium)
```

### Body Styles (Main Content)
```dart
textTheme.bodyLarge      // 16px, w400 (Regular)
textTheme.bodyMedium     // 14px, w400
textTheme.bodySmall      // 12px, w400, muted color
```

### Label Styles (Buttons, Chips)
```dart
textTheme.labelLarge     // 14px, w600 (Semi-Bold)
textTheme.labelMedium    // 12px, w600
textTheme.labelSmall     // 11px, w500 (Medium)
```

## Shape Reference

### Border Radii
```dart
// Cards
BorderRadius.circular(24)      // Large, soft curves

// Inputs (TextFields)
BorderRadius.circular(16)      // Modern, approachable

// FAB (Floating Action Button)
BorderRadius.circular(20)      // Squircle shape

// Dialogs & Bottom Sheets
BorderRadius.circular(28)      // Friendly, inviting

// Small elements (icon containers)
BorderRadius.circular(8)       // Subtle rounding
```

## Common Patterns

### Creating a Card
```dart
Card(
  // Uses theme automatically:
  // - 24px border radius
  // - Near-black surface (#101010)
  // - Blue tint for elevation
  child: YourContent(),
)
```

### Creating a TextField
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Your Label',
    hintText: 'Your hint',
    // Uses theme automatically:
    // - 16px border radius
    // - Blue border on focus (#64B5F6)
    // - Proper filled background (#1A1A1A)
  ),
)
```

### Creating Chips
```dart
// FilterChip
FilterChip(
  label: Text('Filter'),
  selected: true,
  onSelected: (value) {},
  // Uses theme automatically:
  // - Stadium border (pill shape)
  // - Primary blue when selected (#64B5F6)
  // - Proper padding and styling
)

// ActionChip
ActionChip(
  label: Text('Action'),
  onPressed: () {},
  // Uses theme automatically
)

// InputChip
InputChip(
  label: Text('Input'),
  // Uses theme automatically
)
```

### Creating Buttons
```dart
// FilledButton (primary action)
FilledButton(
  onPressed: () {},
  child: Text('Save'),
  // Uses theme:
  // - Primary blue background (#64B5F6)
  // - Black text (#000000)
  // - 16px border radius
)

// FilledButton with icon
FilledButton.icon(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('Add'),
  // Uses theme automatically
)

// TextButton (secondary action)
TextButton(
  onPressed: () {},
  child: Text('Cancel'),
  // Uses theme:
  // - Primary blue text (#64B5F6)
  // - No background
)
```

### Creating a FAB
```dart
FloatingActionButton.extended(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('New'),
  // Uses theme:
  // - 20px squircle radius
  // - Primary blue background (#64B5F6)
  // - Black text/icon (#000000)
)
```

## Best Practices

### ✅ DO: Use Theme Colors
```dart
// Good
Container(
  color: colorScheme.surfaceContainerHigh,
)

// Good
Text(
  'Hello',
  style: textTheme.titleMedium,
)
```

### ❌ DON'T: Hardcode Values
```dart
// Bad
Container(
  color: Color(0xFF1A1A1A),
)

// Bad
Text(
  'Hello',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
)
```

### ✅ DO: Use Theme Shapes
```dart
// Good - Let Card use its theme
Card(
  child: YourContent(),
)

// Good - Let TextField use its theme
TextField(
  decoration: InputDecoration(
    labelText: 'Name',
  ),
)
```

### ❌ DON'T: Override Theme Styles
```dart
// Bad
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // Don't override
  ),
)

// Bad
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(), // Don't override
  ),
)
```

### ✅ DO: Use Surface Hierarchy
```dart
// Good - Clear hierarchy
Scaffold(
  backgroundColor: colorScheme.surface, // #101010
  body: Column(
    children: [
      Container(
        color: colorScheme.surfaceContainerHigh, // #1A1A1A (elevated)
        child: YourElevatedContent(),
      ),
      Container(
        color: colorScheme.surfaceContainerLow, // #0A0A0A (subtle)
        child: YourSubtleContent(),
      ),
    ],
  ),
)
```

## Testing Your Changes

### Verify Theme Application
```dart
// In any widget
final theme = Theme.of(context);
print('Card radius: ${(theme.cardTheme.shape as RoundedRectangleBorder).borderRadius}');
// Should print: 24.0

print('Primary color: ${theme.colorScheme.primary}');
// Should print: Color(0xff64b5f6)
```

### Visual Inspection Checklist
- [ ] All cards have 24px rounded corners
- [ ] All text fields have 16px rounded corners
- [ ] FAB has squircle (20px) shape
- [ ] Colors are consistent across screens
- [ ] Selected chips show primary blue (#64B5F6)
- [ ] Typography uses Inter font
- [ ] Headlines are bold (w700-w800)
- [ ] Background is pure black (#000000)

## Common Issues & Solutions

### Issue: Widget not using theme styling
**Solution**: Remove any hardcoded `color`, `shape`, or `style` parameters and let the widget use its theme.

### Issue: Text field border not rounded
**Solution**: Remove `border: OutlineInputBorder()` from InputDecoration. The theme handles it.

### Issue: Card corners not rounded enough
**Solution**: Remove `shape` parameter from Card. The theme provides 24px radius.

### Issue: Colors look different on different screens
**Solution**: Check if you're using theme colors consistently. Search for hardcoded `Color(0x` or `Colors.` in your code.

## Quick Find & Replace Patterns

If you find hardcoded values, here's how to replace them:

```dart
// Find: Color(0xFF64B5F6)
// Replace: colorScheme.primary

// Find: Color(0xFF000000)
// Replace: colorScheme.surfaceContainerLowest

// Find: Color(0xFF101010)
// Replace: colorScheme.surface

// Find: BorderRadius.circular(12)
// Replace: (Remove and use theme's default)

// Find: border: OutlineInputBorder()
// Replace: (Remove - theme handles it)

// Find: .withOpacity(
// Replace: Use appropriate surface color from theme
```

## Summary

Remember: **The theme is your single source of truth**. When in doubt:
1. Check `super_amoled_theme.dart` for the value
2. Use `Theme.of(context)` to access it
3. Never hardcode colors, radii, or typography
4. Let components use their theme automatically

Happy theming! 🎨✨
