# Clear All Data - Quick Reference

## What It Does
Completely wipes all app data and resets the app to a fresh state, as if it was just installed.

## User Flow
1. Profile → Account Settings → Data Management → Clear All Data
2. Confirmation dialog with warning appears
3. User confirms → Loading screen shows
4. Data is cleared → Returns to home
5. Success message displays
6. Welcome dialog will show on next interaction

## What Gets Deleted
✅ All events  
✅ All event notes  
✅ All event data  
✅ Database file  
✅ In-memory cache  

## What Stays
❌ App settings (none implemented yet)  
❌ Theme preferences (uses default)  
❌ App installation  

## Code Changes

### 1. DatabaseHelper (`lib/database/database_helper.dart`)
```dart
Future<void> clearAllData() async {
  // Closes DB, deletes file, resets instance
}
```

### 2. EventProvider (`lib/providers/event_provider.dart`)
```dart
Future<void> clearAllData() async {
  // Clears DB + in-memory events
}
```

### 3. AccountSettingsPage (`lib/pages/account_settings_page.dart`)
```dart
void _showClearDataDialog() { /* Shows confirmation */ }
Future<void> _confirmClearData() async { /* Executes clearing */ }
```

## Safety Features
- ⚠️ Two-step confirmation required
- 🚫 Cannot dismiss loading dialog
- 🔴 Red warning colors throughout
- ✅ Error handling with user feedback
- 🏠 Auto-navigation to home after completion

## Testing
```bash
# Run the app
flutter run

# Navigate to: Profile > Account Settings > Clear All Data
# Test: Confirm and verify all events are deleted
# Test: Welcome dialog shows after clearing
# Test: Can create new events after clearing
```

## Key Files Modified
1. `lib/database/database_helper.dart` - Added `clearAllData()` method
2. `lib/providers/event_provider.dart` - Added `clearAllData()` method  
3. `lib/pages/account_settings_page.dart` - Updated `_showClearDataDialog()` and added `_confirmClearData()`
4. Added imports: `provider` and `event_provider` to account_settings_page

## After Clearing
- App shows empty state
- Welcome dialog appears (offers sample data)
- Can start adding events immediately
- Database recreated automatically on first event

## Error Handling
If clearing fails:
- Error message shown to user
- App remains functional
- Can retry clearing
- Fallback: Deletes all records if file deletion fails
