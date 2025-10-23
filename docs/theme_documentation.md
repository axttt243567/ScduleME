# Expressive & Modern AMOLED-First Dark Theme

## Overview
This theme implements a sophisticated, modern design system optimized for AMOLED displays with a vibrant blue accent color. It follows Material Design 3 principles while adding expressive, personality-driven touches.

## Core Principles

### 1. AMOLED-First Design
- **Pure Black Background**: `#000000` - Maximizes battery efficiency on AMOLED screens
- **Near-Black Surfaces**: `#101010` - Creates subtle elevation while maintaining dark aesthetics
- **Infinite Contrast**: Pure black creates stunning visual depth and contrast

### 2. Monochromatic Focus
- **Primary Color**: `#64B5F6` (Light Blue 300) - The hero color that defines the brand
- **Secondary Color**: `#42A5F5` (Blue 400) - Analogous blue that supports without competing
- **Tertiary Color**: `#90CAF9` (Light Blue 200) - Softer blue accent for hierarchy
- **Cool Grays**: Various shades for text and UI elements

### 3. Expressive Shapes
Modern, varied geometries that break from traditional design:
- **FAB**: 20px border radius ('squircle' shape)
- **Cards**: 24px border radius (large, soft curves)
- **Inputs**: 16px border radius (approachable, modern)
- **Dialogs**: 28px border radius (friendly, inviting)

### 4. Emphasized Typography
Uses **Inter** font family from Google Fonts:
- **Display/Headlines**: FontWeight.w700-w800 (Bold/Extra Bold)
- **Editorial Feel**: Creates confident, eye-catching hierarchy
- **Body Text**: FontWeight.w400 (Regular) for comfortable reading
- **Labels**: FontWeight.w600 (Semi-Bold) for prominence

## Color Palette

### Primary Colors
```dart
Primary: #64B5F6          // Vibrant blue - main brand color
On Primary: #000000        // Pure black for contrast
Primary Container: #1565C0 // Deep blue for containers
On Primary Container: #BBDEFB // Light blue for text
```

### Secondary Colors
```dart
Secondary: #42A5F5         // Slightly darker blue
On Secondary: #000000      // Pure black
Secondary Container: #0D47A1 // Very deep blue
On Secondary Container: #E3F2FD // Almost white blue
```

### Tertiary Colors
```dart
Tertiary: #90CAF9          // Soft blue accent
On Tertiary: #000000       // Pure black
Tertiary Container: #263238 // Dark neutral
On Tertiary Container: #CFD8DC // Light neutral
```

### Surface Hierarchy
```dart
Surface Container Lowest: #000000  // Pure black background
Surface Container Low: #0A0A0A     // Subtle lift
Surface Container: #101010         // Standard surface
Surface Container High: #1A1A1A    // More elevation
Surface Container Highest: #242424 // Highest elevation
```

### Text Colors
```dart
On Surface: #E1E1E1        // Primary text (light gray)
On Surface Variant: #B0B0B0 // Secondary text (muted gray)
Outline: #404040           // Borders and dividers
```

## Component Styling

### Buttons
- **Elevated/Filled**: Primary blue (#64B5F6) with black text
- **Border Radius**: 16px for modern, expressive feel
- **Typography**: Inter Semi-Bold (w600)

### Cards
- **Background**: Near-black (#101010)
- **Border Radius**: 24px (large, soft curves)
- **Elevation**: 2 (subtle shadow)
- **Surface Tint**: Primary blue for depth

### Floating Action Button
- **Shape**: 20px border radius ('squircle')
- **Color**: Primary blue (#64B5F6)
- **Elevation**: 8 (prominent on AMOLED)

### Navigation Bar
- **Background**: Near-black (#101010)
- **Height**: 80px (modern proportions)
- **Indicator**: Primary blue
- **Labels**: Always shown, bold when selected

### Input Fields
- **Background**: #1A1A1A (slightly elevated)
- **Border Radius**: 16px (expressive curve)
- **Focused Border**: 2px primary blue
- **Default Border**: 1px subtle gray

### Dialogs & Bottom Sheets
- **Background**: #1A1A1A
- **Border Radius**: 28px (large, friendly)
- **Elevation**: 8 (floating feel)

## Typography Scale

### Display Styles (Editorial Headlines)
- **Large**: 57px, Extra Bold (w800)
- **Medium**: 45px, Extra Bold (w800)
- **Small**: 36px, Bold (w700)

### Headline Styles (Page Titles)
- **Large**: 32px, Bold (w700)
- **Medium**: 28px, Bold (w700)
- **Small**: 24px, Semi-Bold (w600)

### Title Styles (Cards, Lists)
- **Large**: 22px, Semi-Bold (w600)
- **Medium**: 16px, Semi-Bold (w600)
- **Small**: 14px, Medium (w500)

### Body Styles (Content)
- **Large**: 16px, Regular (w400)
- **Medium**: 14px, Regular (w400)
- **Small**: 12px, Regular (w400), Muted color

### Label Styles (Buttons, Chips)
- **Large**: 14px, Semi-Bold (w600)
- **Medium**: 12px, Semi-Bold (w600)
- **Small**: 11px, Medium (w500)

## Usage Guidelines

### When to Use Primary Blue
- Call-to-action buttons
- Selected navigation items
- Active input fields
- Interactive icons
- Links and actions

### When to Use Black Surfaces
- App background (pure black #000000)
- Cards and containers (#101010)
- Elevated surfaces (#1A1A1A)

### When to Use Bold Typography
- Page titles and headlines
- Important announcements
- Featured content
- Navigation labels (when selected)

### When to Use Regular Typography
- Body text and paragraphs
- Descriptions and details
- Form fields
- Secondary information

## Accessibility Considerations

1. **High Contrast**: Pure black backgrounds create maximum contrast with light text
2. **Color Contrast**: Primary blue (#64B5F6) has excellent contrast against black
3. **Text Hierarchy**: Bold typography creates clear visual hierarchy
4. **Touch Targets**: Generous padding ensures easy tapping
5. **Focus Indicators**: Bright blue borders clearly indicate focus

## Implementation

```dart
import 'package:flutter/material.dart';
import 'theme.dart';

// In your MaterialApp
MaterialApp(
  theme: darkTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.dark,
  home: YourHomePage(),
);
```

## Design Philosophy

This theme embodies a "fluid, engaging, and clean" aesthetic:

- **Fluid**: Smooth curves and consistent border radii create visual flow
- **Engaging**: Bold typography and vibrant blue draw attention
- **Clean**: Monochromatic palette and AMOLED blacks maintain simplicity

The result is a modern, confident design that feels premium and sophisticated while remaining approachable and easy to use.
