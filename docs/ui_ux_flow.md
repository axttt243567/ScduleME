# UI and UX Flow — ScheduleMe Prototype

Last updated: 2025-10-19

This document captures the intended UI structure and interaction flow for the first prototype, reflecting your preferences: Material 3 Expressive, dark mode by default, compact density in some areas, cozy in others, rounded “floating chip” components, and bottom sheets for focused tasks.

## Global patterns
- Material 3 (useMaterial3), dark mode default, dynamic color optional later
- Stadium-shaped chips (rounded/circular), small size preference where feasible
- Bottom sheets with drag handle and rounded top corners for workflows
- Compact density on data-heavy screens; cozy on reading/editor screens
- Reusable “Universal Widgets” (described below)

## Navigation
- Bottom navigation: Today • Notes • Schedule • AI
- Optional onboarding route shown on first launch (3–4 mini-stages)

## Onboarding (3–4 mini-stages)
- Stage 1: Welcome + permission context (no requests yet)
- Stage 2: Universal components demo — tap chips to change state
- Stage 3: Attendance flow preview — one-tap check-in
- Stage 4: Notes flow preview — editor, AI chips, publish view

## Universal reusable widgets (low-cost customization)
1) Floating Chips Dock
   - Draggable/choreographed stack of small chips for AI suggestions, filters, or quick select actions.
   - Modes: suggest (AI), filter, selection.
2) Smart Bottom Sheet
   - Standardized sheet with title, action row, content area, and preset chip row.
3) Section Header
   - Title, optional subtitle, and actions (chips/buttons) with consistent spacing.
4) Data Card
   - Compact list card with icon/avatar, title, sub, and trailing action.
5) Timeline Item
   - For daily timeline entries (class, study hours, yoga, notes), with status chip.
6) Inline Tag Chips
   - Small chips for tags/labels that can toggle; used across Notes and Schedule.

## Screen flows

### Today
- Header: Next class + quick chips (Check in, I\'m late, Add note, Streak)
- Sessions list: list of Data Cards; each opens Smart Bottom Sheet for check-in
- Footer: link to Daily Timeline

### Notes
- Filter chips at top (All, Lectures, Highlights, Flashcards)
- Notes list (Data Cards); FAB opens editor
- Create bottom sheet with action chips: From Link, PDF, YouTube, Audio
- Note Editor: toolbar chips, AI bottom sheet, body text area; Publish (read view) later

### Schedule
- Quick chips: Pre-class reminder, Recurring, Skip holidays
- Weekly overview (placeholder) + Data Cards for classes
- Bottom sheet: define course, days (chips), times; save

### AI Assist
- Quick suggestion chips; personalization filter chips
- Start -> bottom sheet to paste link/pick file (mock in prototype)

### Daily Timeline (upcoming in prototype)
- Chronological view for the day combining: classes, attendance, study hours, yoga, notes
- Add entry via Floating Chips Dock (e.g., +Study 25m, +Yoga 15m)

## Density & spacing rules
- Today/Schedule lists: compact
- Notes Editor/Reader: cozy
- Bottom sheets: compact header, cozy content
- Chip size: small by default; keep Stadium shape

## Future Android widgets
- Today quick check-in
- Study timer and streaks
- Upcoming classes

