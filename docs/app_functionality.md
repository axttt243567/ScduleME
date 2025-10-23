# ScheduleMe Student App — Frontend Prototype Functionality

Last updated: 2025-10-19

This document explains what the current frontend-only prototype does. It focuses on Material 3 UI, chips for quick actions, and bottom sheets for focused tasks. No backend or local persistence is implemented yet.

---

## App shell
- Material 3 design with bottom navigation: Today, Notes, Schedule, AI
- Theming: uses a seed color; dark mode support will be added next
- Bottom sheets include a drag handle and rounded top corners for clarity

## Today (Attendance)
- “Next class” header with quick action chips:
  - Check in now → opens Attendance bottom sheet (present/late/absent, note, confirm)
  - Mark late → opens the same sheet prefilled to “Late” (mock)
  - Add note → opens Quick Note bottom sheet (tags + textarea)
  - View streak → opens Streak bottom sheet with simple stats
- “Today’s Sessions” section lists mock classes with “Check in” buttons

## Notes
- Filter chips to switch views (All, Lectures, Highlights, Flashcards — mock)
- Notes list with sample items; tap opens Note Editor
- “Create” bottom sheet with action chips: From Link / From PDF / From YouTube / From Audio (mock)

## Note Editor
- Toolbar chips: H1, H2, Bold, Quote, Image, Callout, Checklist (mock actions)
- AI Suggestions bottom sheet:
  - Summarize, Create Highlights, Rewrite (Clarity), Translate, Generate Flashcards
  - Personalization chips: Concise, Keep citations, Add examples, Preserve structure (mock)
- Text fields for title and body; content is not saved

## Schedule
- Quick chips for reminders, recurring rules, and skipping holidays
- Mock class list; each item can open a bottom sheet with class details
- “Add class” button opens a sheet to enter course, days (chips), and time (no storage)

## AI Assist
- Quick suggestion chips for Summarize from Link/PDF/YouTube and Extract Highlights
- Personalization chips similar to the editor’s AI sheet
- “Start” opens a minimal bottom sheet to paste a link or pick a file (mock)

---

## Limitations (by design in this prototype)
- No database/local storage; all UI is non-persistent
- No authentication or cloud services
- AI actions are placeholders only (no network or model calls)
- Importers (PDF/YouTube/Link) are not implemented; sheet shows placeholders

---

## Next steps we can implement quickly
- Material 3 dark theme with rounded chip shapes across the app
- Split screens into separate files and add a simple router
- In-memory mock state so filter chips actually toggle and reflect changes
- Draft data models (Course, ClassSession, Attendance, Note, ImportSource, AiProfile)
- Prompt templates for AI Summarize/Highlights/Flashcards for later integration

