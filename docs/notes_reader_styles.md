# Notes Reader Styles — Upcoming Feature

Last updated: 2025-10-19

Goal: Support additional “Reader” layouts for notes, inspired by Material 3 Expressive, to present study content more like magazines or textbooks.

## Target layouts
- Magazine style
  - Cover image area, standout title, deck/summary
  - Multi-size headings, pull quotes, accent color callouts
  - Image grids with captions, full-bleed imagery in reader view
  - Emphasis on rhythm/contrast and reading flow
- Textbook style
  - Strict hierarchy (H1–H3), numbered sections
  - Definition boxes, theorem/proof blocks (callouts)
  - Figure and table numbering with cross-references
  - Side notes/marginals (tablet/desktop), practice questions

## Components to reuse
- Heading block (levels, numbering optional)
- Callouts (info/warn/tip/definition)
- Figure with caption and anchors
- Quote/PullQuote block
- TOC (auto-generated from headings) and page anchors

## Accessibility and print/export
- Print-friendly export theme (PDF/MD/HTML)
- Screen reader friendly heading order
- High contrast option while keeping M3 styling

## Status
- Scheduled as an upcoming feature (not in current prototype)
- Dependencies: rich editor blocks and reader view pages
