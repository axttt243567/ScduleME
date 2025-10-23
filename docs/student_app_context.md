# Student App – Product Context and Decisions

Last updated: 2025-10-19

This document captures your product intent, decisions, and open questions so another LLM or teammate can continue with consistent context.

---

## Summary
You want a student productivity app focused on:
- Self attendance tracking
- Notes management with a strict, blog-style reading experience
- AI-generated notes/summaries from multiple sources (links, PDFs, YouTube)
- Offline-first launch on Android
- Daily class schedule support

We asked initial questions (Q1–Q5) and follow-ups (Q6–Q10). Your selected answers are recorded below, along with our interpretation and next steps.

---

## Decisions from Q1–Q5 (User selections + interpretation)

### Q1) Top MVP goals
User answer (normalized from free text):
- A) Self attendance tracking
- B) Notes management
- C) AI-generated summaries/notes on given resources (links, PDFs, YouTube)
- E) Timetable/schedule planner
- F) Course/class management

Interpretation:
- MVP should include attendance, rich notes, AI ingestion/summarization from URLs/PDFs/YouTube, a daily/weekly schedule, and course entities tying everything together.

### Q2) Self-attendance workflow
User answer:
- A) Manual one-tap check-in
- Plus: "daily class schedules" context

Interpretation:
- Primary flow: user taps to check in for the current/next scheduled class. Optional enhancements later (geo/QR/NFC) can be future work.

### Q3) Notes capture/organization style
User answer:
- "Internet blog style" notes with photos + text and strict formats
- Ability to read uploaded PDFs

Interpretation:
- A structured, opinionated rich text editor with headings/callouts, images with captions, and a clean publish/read view. PDF viewer + import pipeline.

### Q4) AI features priorities
User answer (normalized):
- A) Summarize notes into concise bullets
- B) Generate flashcards from notes
- Also: "create highlighted notes on the existing notes"
- "User can create custom notes based on user preference in 10 different personalized parameters"

Interpretation:
- AI should support summaries, flashcards, highlight extraction, and a personalization system with up to 10 parameters (e.g., tone, length, citations, examples, etc.).

### Q5) Launch strategy and data approach
User answer:
- A) Android-only, offline-first (no account)

Interpretation:
- Initial release is a local-first Android app; future optional sync can be planned behind a feature flag.

---

## Follow-up Question Bank (Q6–Q10)
Use these to refine scope with the next LLM. The user has not answered these yet.

### Q6) Notes editor and “blog-style” format (pick up to 4)
- A) Block-based editor (Notion-like blocks)
- B) Enforced headings hierarchy (H1–H6, outline)
- C) Rich media: images with captions/alt text
- D) Callouts, quotes, and info/warning blocks
- E) Tables and side-by-side columns
- F) Checklists and inline tasks
- G) Code blocks with syntax highlighting
- H) Math formulas (LaTeX/KaTeX)
- I) Read-only “publish view” with clean theme
- J) Version history with compare/rollback

### Q7) Content you want to import and parse (pick up to 5)
- A) PDFs (text + images) with page anchors
- B) Images (OCR for slides/whiteboard)
- C) YouTube links (auto-captions + timestamps)
- D) Web articles (reader mode extraction)
- E) DOCX (Word) import
- F) PPT/PPTX slides import
- G) Google Drive picker
- H) OneDrive picker
- I) Audio recordings with transcription
- J) Camera scanner for handouts (auto-crop)

### Q8) Your 10 AI personalization parameters (pick up to 10)
- A) Reading level (simple, academic, technical)
- B) Tone (concise, explanatory, step-by-step)
- C) Summary length (brief/medium/detailed)
- D) Keep citations with page/time stamps
- E) Emphasize key terms/definitions
- F) Include examples/analogies
- G) Add study tips/action items
- H) Generate flashcards alongside notes
- I) Preserve original structure/formatting
- J) Language preference and translation

### Q9) Daily class schedule and reminders (pick up to 4)
- A) Manual recurring classes builder
- B) Import from calendar/ICS (optional)
- C) Pre-class reminders (5/10/15 mins)
- D) Smart reminders (travel time aware)
- E) Semester/term boundaries and weeks
- F) Holiday/exception skip rules
- G) Home-screen widget quick check-in
- H) Conflicts detector and resolver
- I) Attendance streaks and analytics
- J) Color-coding and icons per course

### Q10) Offline-first privacy, storage, and export (pick up to 4)
- A) Local encryption at rest
- B) Biometric/app lock
- C) Local backup/restore file
- D) Export notes to Markdown
- E) Export notes to PDF
- F) Share read-only HTML bundle (offline)
- G) Opt-in usage analytics (privacy-first)
- H) Accessibility: large fonts, screen reader
- I) Theming: light/dark/AMOLED/custom colors
- J) Future optional sync (toggle off by default)

---

## Initial Feature Spec (Draft)

### Core Data Model (local-only, SQLite via Drift/Hive suggested)
- Course { id, name, code, color }
- ClassSession { id, courseId, startTime, endTime, location, recurrence }
- Attendance { id, sessionId, timestamp, status, note }
- Note { id, courseId, title, contentRich, createdAt, updatedAt, tags[] }
- ImportSource { id, type[url/pdf/yt/docx], meta { citation, page/timestamp }, rawPath }
- AiProfile { id, parameters[10], presets[] }

### Flows
- Attendance: Today view -> current session -> One-tap Check In -> streaks analytics.
- Notes: Editor with strict styles -> images and text -> publish view -> PDF reader -> "Create Highlights" -> "Summarize" -> "Generate Flashcards".
- Imports: Add source (URL/PDF/YouTube) -> extract -> attach to note -> AI summarize with chosen profile.
- Schedule: Weekly planner -> recurring classes -> reminders.

### AI Contracts (model-agnostic; other LLM can implement)
Inputs:
- sources: [urls|pdfs|youtubeIds]
- note_body: rich text/markdown
- ai_profile: { reading_level, tone, length, citations, emphasize_terms, examples, study_tips, flashcards, preserve_structure, language }
Outputs:
- summary: bullets + sections
- highlights: key quotes with source anchors
- flashcards: [ { q, a, tag } ]
- rewritten_note: formatted rich text

### Edge cases
- Large PDFs without text layer -> OCR fallback
- YouTube without captions -> transcript via ASR
- Offline mode -> queue AI jobs until online (if cloud is used later)
- Duplicated imports -> de-dup by URL hash

---

## Open Decisions / To Confirm
- Exact picks for Q6–Q10
- Which on-device vs cloud AI approach for v1 (given offline-first)
- Storage engine choice (Drift vs Hive vs Isar)
- PDF import pipeline and OCR library
- Theming and accessibility requirements

---

## Next Steps
1) Provide selections for Q6–Q10 in this doc.
2) We’ll update this context and generate:
   - Data model schema
   - Minimal UI wireframes
   - Task breakdown for Flutter implementation
   - Optional: prompt templates for AI features
