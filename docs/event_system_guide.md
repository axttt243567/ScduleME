# Event Management System - Implementation Guide

## Overview
This document describes the comprehensive event management system implemented for the ScheduleMe app, including database integration, calendar views, and timeline functionality.

## Features Implemented

### 1. Database System
- **Local SQLite Database** using `sqflite` package
- **Event Storage** with full CRUD operations
- **Automatic Schema Management** with migrations support
- **Efficient Querying** with indexes on key fields

### 2. Event Model
Complete event data structure with:
- ✅ **Title** and **Icon** (customizable from icon picker)
- ✅ **Categories** (multiple categories per event)
- ✅ **Priority Levels** (Low, Medium, High, Urgent)
- ✅ **Date/Time Options**:
  - Single day or multi-day events
  - All-day events
  - Specific time with duration
  - Flexible duration (15 min - 8 hours)
- ✅ **Repetition Patterns**:
  - No repeat (one-time event)
  - Daily repetition
  - Weekly repetition
  - Custom weekly days (e.g., Mon/Wed/Fri)
- ✅ **Remarks** (None, Done, Skip, Missed)
- ✅ **Hashtags** for categorization and search
- ✅ **Notes** field for additional details

### 3. Today Page (Timeline View)
**Location**: `lib/pages/today_page.dart`

Features:
- **Timeline View** showing all events for selected day
- **Day Navigation** in app bar (Today + next 6 days)
- **Current Event Highlighting** - events happening now are visually emphasized
- **Quick Day Selection** with chips in header
- **Return to Today** by tapping "Today" text
- **Event Cards** showing:
  - Time and duration
  - Event icon and title
  - Categories (color-coded)
  - Priority (for high/urgent)
  - Current status badge ("NOW" for active events)
- **Tap Event** to view full details
- **FAB** to create new event

### 4. Calendar Page
**Location**: `lib/pages/calendar_page.dart`

Features:
- **Multiple View Modes**:
  - Month View (default)
  - 2-Week View
  - Week View
- **Event Markers** on calendar dates
- **Day Selection** to view events
- **Event List** below calendar for selected day
- **Quick Navigation**:
  - Jump to today with button
  - Swipe between months/weeks
- **Visual Indicators**:
  - Today highlighted in primary color
  - Selected day in darker primary
  - Dots showing events on dates

### 5. Create/Edit Event Page
**Location**: `lib/pages/create_event_page.dart`

Comprehensive event creation with:
- **Title Input** with validation
- **Icon Picker** (24 common icons in bottom sheet)
- **Category Selector** (multi-select with chips)
  - 10 predefined categories with colors and icons
  - Visual chip display of selected categories
- **Priority Selector** with choice chips
- **Date & Time Section**:
  - Start date picker
  - End date picker (for multi-day)
  - All-day toggle
  - Time picker (when not all-day)
  - Duration slider (15-480 minutes)
- **Repetition Section**:
  - Pattern selector (None, Daily, Weekly, Custom)
  - Custom weekday picker for flexible schedules
- **Hashtag Manager**:
  - Add hashtags with # prefix
  - Visual chip display
  - Remove individual tags
- **Notes Field** (optional)

### 6. Event Detail Page
**Location**: `lib/pages/event_detail_page.dart`

Features:
- **Event Header** with icon, title, and color-coded category
- **Details Display**:
  - Priority with color and icon
  - Full date/time information
  - Repetition pattern details
- **Categories Section** with chips
- **Hashtags Section** with chips
- **Notes Editor** (editable text field)
- **Quick Action Buttons**:
  - Mark as Done
  - Mark as Skip
  - Mark as Missed
  - Clear status
- **Delete Event** option in app bar

## Data Models

### Event Categories (Predefined)
1. **Academic** - School/University work (Cyan)
2. **Assignment** - Homework and assignments (Pink)
3. **Exam** - Tests and examinations (Red)
4. **Project** - Project work (Orange)
5. **Study** - Study sessions (Purple)
6. **Personal** - Personal tasks (Green)
7. **Health** - Health and fitness (Magenta)
8. **Social** - Social activities (Yellow)
9. **Work** - Work-related (Purple)
10. **Other** - Miscellaneous (Gray)

### Priority Levels
- **Low** (Green) - Can be postponed
- **Medium** (Orange) - Standard priority
- **High** (Pink) - Important, should complete soon
- **Urgent** (Red) - Critical, must complete ASAP

### Event Remarks
- **None** - No status set
- **Done** (Green) - Completed successfully
- **Skip** (Orange) - Intentionally skipped
- **Missed** (Red) - Missed/not completed

## File Structure
```
lib/
├── models/
│   ├── event.dart              # Event model with all properties
│   ├── category.dart           # Category definitions
│   └── priority.dart           # Priority and remark enums
├── database/
│   └── database_helper.dart    # SQLite database operations
├── providers/
│   └── event_provider.dart     # State management with ChangeNotifier
├── pages/
│   ├── today_page.dart         # Timeline view for today/selected day
│   ├── calendar_page.dart      # Calendar with multiple views
│   ├── create_event_page.dart  # Create/edit event form
│   └── event_detail_page.dart  # View and manage event details
└── utils/
    └── sample_data_helper.dart # Helper to create sample events
```

## Usage

### Running the App
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

### Testing with Sample Data
When you first open the app and have no events:
1. Look for the small FAB button with chart icon
2. Tap it to populate the database with sample events
3. The button will disappear once you have events

### Creating an Event
1. Tap the + FAB on Today or Calendar page
2. Fill in the event details
3. Select categories (at least one required)
4. Set priority and date/time
5. Configure repetition if needed
6. Add hashtags and notes
7. Tap "Save" in app bar

### Viewing Event Details
1. Tap any event card in Today or Calendar view
2. View all event information
3. Edit notes inline
4. Use quick action buttons to mark status
5. Delete event if needed

### Navigating Days (Today Page)
1. Current day shows as "Today" in header
2. Tap day chips (Mon, Tue, etc.) to view that day
3. Selected day shows in primary container color
4. Tap "Today" text to return to current day
5. Current time period events are highlighted with "NOW" badge

### Using Calendar
1. Tap dates to select and view events
2. Use header arrows to navigate months
3. Tap view icon (top right) to change view format
4. Tap today icon to jump to current date
5. Event dots appear on dates with events

## Technical Details

### Database Schema
```sql
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  categoryIds TEXT NOT NULL,
  priority INTEGER NOT NULL,
  startDate TEXT,
  endDate TEXT,
  isAllDay INTEGER,
  startTimeHour INTEGER,
  startTimeMinute INTEGER,
  durationMinutes INTEGER,
  repetitionPattern INTEGER,
  customWeekdays TEXT,
  iconCodePoint TEXT,
  iconFontFamily TEXT,
  hashtags TEXT,
  remark INTEGER,
  notes TEXT,
  createdAt TEXT,
  updatedAt TEXT
);
```

### State Management
- Uses Provider package with ChangeNotifier
- EventProvider manages all event state
- Automatic UI updates when events change
- Efficient loading and caching

### Event Occurrence Logic
The `occursOnDate()` method handles:
- Single-day events
- Multi-day date ranges
- Daily repetition
- Weekly repetition (same weekday)
- Custom weekly patterns (specific days)

### Time Highlighting
Events are highlighted as "happening now" when:
- Event occurs on current day
- Current time is within event's time range
- For all-day events, true for entire day

## Future Enhancements
Possible additions:
- Event reminders/notifications
- Search and filter functionality
- Export/import events
- Event templates
- Color themes per category
- Statistics and insights
- Sync across devices
- Recurring event exceptions
- Event attachments

## Dependencies
- `flutter` - Core framework
- `provider` - State management
- `sqflite` - Local database
- `path_provider` - File system access
- `intl` - Date/time formatting
- `table_calendar` - Calendar widget

## Testing
The app includes sample data helper for quick testing. Sample events include:
- Daily recurring study sessions
- Weekly lectures (Mon/Wed/Fri pattern)
- Upcoming exams with high priority
- Multi-day vacation event
- All-day career fair
- Various time slots throughout the day

---

**Note**: The old TodayScreen and CalendarScreen classes in main.dart are preserved but not used. The new pages (TodayPage and CalendarPage) are integrated with the event system.
