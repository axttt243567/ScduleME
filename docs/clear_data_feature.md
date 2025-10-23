# Clear All Data Feature

## Overview
The "Clear All Data" feature provides users with the ability to completely wipe all app data and start fresh. This is a destructive operation that permanently removes all events, notes, and resets the app to its initial state.

## Implementation Details

### 1. Database Layer (`database_helper.dart`)

#### New Method: `clearAllData()`
```dart
Future<void> clearAllData() async
```

**Purpose**: Completely removes the SQLite database file and resets the database instance.

**Process**:
1. Closes the current database connection if open
2. Sets the database instance to null
3. Deletes the physical database file (`events.db`) from device storage
4. Falls back to deleting all records if file deletion fails

**Location**: `lib/database/database_helper.dart`

### 2. Provider Layer (`event_provider.dart`)

#### New Method: `clearAllData()`
```dart
Future<void> clearAllData() async
```

**Purpose**: Coordinates data clearing and updates the provider state.

**Process**:
1. Sets loading state
2. Calls database helper's `clearAllData()`
3. Clears in-memory events list
4. Notifies listeners of state change
5. Handles errors appropriately

**Location**: `lib/providers/event_provider.dart`

### 3. UI Layer (`account_settings_page.dart`)

#### Updated Methods:
- `_showClearDataDialog()` - Shows confirmation dialog
- `_confirmClearData()` - New method that handles the clearing process

**User Flow**:
1. User taps "Clear All Data" in Account Settings
2. Confirmation dialog appears with warning message
3. User confirms by tapping "Clear All" button
4. Loading dialog shows "Clearing all data..." with progress indicator
5. Database is cleared and app state is reset
6. User is navigated back to home screen
7. Success message shows via SnackBar
8. Welcome dialog will appear on next app interaction (if events are empty)

**Location**: `lib/pages/account_settings_page.dart`

## Features

### Safety Measures
1. **Two-step confirmation**: Users must explicitly confirm before data is cleared
2. **Warning icon and message**: Clear visual indicators of destructive action
3. **Error handling**: Graceful error handling with user feedback
4. **Non-dismissible loading**: Prevents accidental interruption during clearing

### User Experience
1. **Clear visual feedback**: 
   - Red warning icon in confirmation dialog
   - Loading indicator during operation
   - Success/error message after completion

2. **Navigation**:
   - Returns to home screen after clearing
   - App state fully reset
   - Welcome dialog will appear when app detects no events

3. **Error Recovery**:
   - If database deletion fails, attempts to delete all records
   - Shows error message to user if operation fails
   - App remains usable even if clearing partially fails

## What Gets Cleared

1. **Database**:
   - All event records
   - Database file deleted from storage
   
2. **In-Memory State**:
   - Events list in provider
   - All cached data

3. **App Behavior**:
   - App resets to "first launch" state
   - Welcome dialog will show again
   - User can add sample data or start fresh

## What Doesn't Get Cleared

Currently, the following are NOT cleared (as they're not implemented yet):
- SharedPreferences (no settings stored yet)
- Cached images or files
- App theme preferences (if implemented in future)

## Usage

### Accessing the Feature
1. Navigate to Profile page (4th tab)
2. Tap "Account Settings"
3. Scroll to "Data Management" section
4. Tap "Clear All Data"

### Example Dialog Flow
```
[Confirmation Dialog]
⚠️ Clear All Data

This will permanently delete all your events, 
categories, notes, and settings. This action 
cannot be undone.

Are you sure you want to continue?

[Cancel]  [Clear All]

↓ (User taps Clear All)

[Loading Dialog]
🔄 Clearing all data...
Please wait

↓ (Clearing complete)

[Returns to Home]
✅ All data has been cleared successfully!
```

## Technical Notes

### Database Deletion
- Uses `deleteDatabase()` from sqflite package
- Database file: `events.db`
- Location: Platform-specific databases directory
- Automatically recreated on next database operation

### Provider State
- Events list cleared immediately
- Loading state properly managed
- Listeners notified of changes
- Error state handled

### Navigation
- Uses `popUntil((route) => route.isFirst)` to return to root
- Ensures clean navigation stack
- Prevents back button issues

## Testing Checklist

- [ ] Clear data with events present
- [ ] Clear data with empty database
- [ ] Check welcome dialog appears after clearing
- [ ] Verify database file is deleted
- [ ] Test error handling (simulate failure)
- [ ] Check loading dialog appears
- [ ] Verify success message shows
- [ ] Test back button during loading (should be blocked)
- [ ] Confirm app state is fully reset
- [ ] Test creating new events after clearing

## Future Enhancements

1. **Export Before Clear**: Option to export data before clearing
2. **Selective Clear**: Clear only events, or only specific categories
3. **Clear Settings**: Add SharedPreferences clearing when settings are implemented
4. **Backup Reminder**: Remind users to backup before clearing
5. **Undo Option**: Implement a grace period with undo capability
6. **Clear Statistics**: Add clearing of analytics/usage data if implemented

## Related Files

- `lib/database/database_helper.dart` - Database operations
- `lib/providers/event_provider.dart` - State management
- `lib/pages/account_settings_page.dart` - UI implementation
- `lib/widgets/welcome_dialog.dart` - First launch experience

## API Reference

### DatabaseHelper.clearAllData()
```dart
/// Clear all data - delete database file and reset instance
Future<void> clearAllData() async
```
Throws exception if deletion fails completely.

### EventProvider.clearAllData()
```dart
/// Clear all data - wipe everything and reset to fresh state
Future<void> clearAllData() async
```
Updates loading and error states, notifies listeners.

### AccountSettingsPage._confirmClearData()
```dart
Future<void> _confirmClearData() async
```
Private method handling the UI flow for data clearing.
