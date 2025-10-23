# Gemini API Configuration Guide

## Overview
The app now includes a comprehensive API Configuration system that allows users to manage multiple Gemini API keys securely. This feature is accessible from the Profile page under Account Settings.

## Features

### 1. **Multiple API Keys**
- Store and manage multiple Gemini API keys
- Add unlimited keys with custom names (e.g., "Personal Key", "Work API")
- Each key is stored securely in the local database

### 2. **Active Key Selection**
- Choose which API key to use as your active key
- Only one key can be active at a time
- Active keys are clearly marked with a star icon and "ACTIVE" badge
- Easily switch between keys with a single tap

### 3. **API Key Validation**
- Quick validation to check if an API key is working
- Validates by making a test request to Gemini AI
- Shows validation status with visual indicators:
  - ✅ Green check for valid keys
  - ❌ Red error for invalid keys
- Displays "Last Validated" timestamp for each key

### 4. **Key Management**
- **Add Keys**: Easy dialog with:
  - Custom name field
  - API key input with show/hide toggle
  - Option to set as active immediately
  - Basic format validation
  - Duplicate name checking
  
- **View Keys**: Each key card shows:
  - Custom name
  - Masked key (shows only last 8 characters)
  - Active status
  - Validation status
  - Last validated timestamp
  - Last used timestamp
  
- **Delete Keys**: 
  - Confirmation dialog before deletion
  - Prevents accidental data loss

### 5. **Statistics Dashboard**
- Total keys count
- Valid keys count
- Active keys count
- Visual stat cards with icons

### 6. **Security**
- Keys are stored in SQLite database
- Masked display (only last 8 characters visible)
- Show/hide toggle when entering keys
- No keys are transmitted outside validation

## How to Use

### Adding Your First API Key

1. **Navigate to API Configuration**:
   - Open the app
   - Go to Profile tab (bottom navigation)
   - Tap on "Account Settings"
   - Find "API Configuration" section
   - Tap on "Gemini API Keys" card

2. **Get a Gemini API Key**:
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Create a new API key (free tier available)
   - Copy the API key

3. **Add the Key**:
   - Tap "Add New API Key" button
   - Enter a memorable name (e.g., "My Personal Key")
   - Paste your API key
   - Toggle "Set as active key" if you want to use it immediately
   - Tap "Add Key"

### Validating an API Key

1. Find the key you want to validate
2. Tap the "Validate" button on the key card
3. Wait for validation (usually 2-5 seconds)
4. Check the result:
   - ✅ "API key is valid!" - Ready to use
   - ❌ "API key is invalid" - Check your key

### Switching Active Keys

1. Find the key you want to activate
2. Tap "Set Active" button
3. The key will be marked as active
4. Previous active key will be automatically deactivated

### Managing Multiple Keys

You can store multiple keys for different purposes:
- **Personal Key**: For personal projects
- **Work Key**: For work-related tasks
- **Backup Key**: As a fallback option
- **Test Key**: For testing purposes

### Deleting a Key

1. Find the key you want to delete
2. Tap the "Delete" button
3. Confirm deletion in the dialog
4. Key will be permanently removed

## Using the API in Your App

The active API key is automatically used throughout the app. Here's how to use it in your code:

```dart
import 'package:provider/provider.dart';
import '../providers/api_key_provider.dart';
import '../utils/gemini_service.dart';

// Get the active API key
final apiKeyProvider = context.read<ApiKeyProvider>();
final activeKey = apiKeyProvider.activeApiKey;

if (activeKey != null) {
  // Use the key with GeminiService
  final response = await GeminiService.generateContent(
    apiKey: activeKey.keyValue,
    prompt: 'Your prompt here',
  );
  
  // Update last used timestamp
  await apiKeyProvider.updateLastUsed(activeKey.id!);
}
```

## GeminiService Methods

### 1. Validate API Key
```dart
final isValid = await GeminiService.validateApiKey(apiKey);
```

### 2. Generate Content
```dart
final response = await GeminiService.generateContent(
  apiKey: apiKey,
  prompt: 'Your prompt',
  model: 'gemini-pro', // optional, default is 'gemini-pro'
);
```

### 3. Generate Content Stream
```dart
final stream = GeminiService.generateContentStream(
  apiKey: apiKey,
  prompt: 'Your prompt',
);

await for (final chunk in stream) {
  print(chunk);
}
```

### 4. Start Chat
```dart
final chat = await GeminiService.startChat(
  apiKey: apiKey,
  model: 'gemini-pro',
);

final response = await chat.sendMessage(Content.text('Hello!'));
```

## Database Schema

The API keys are stored in the `api_keys` table:

```sql
CREATE TABLE api_keys (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  keyValue TEXT NOT NULL,
  isActive INTEGER NOT NULL,
  createdAt TEXT NOT NULL,
  lastUsedAt TEXT,
  lastValidatedAt TEXT,
  isValid INTEGER
)
```

## Provider Methods

### ApiKeyProvider Methods:

- `loadApiKeys()` - Load all keys from database
- `addApiKey()` - Add a new key
- `updateApiKey()` - Update an existing key
- `setActiveKey()` - Set a key as active
- `deleteApiKey()` - Delete a key
- `updateValidationStatus()` - Update validation status
- `updateLastUsed()` - Update last used timestamp
- `getApiKeyById()` - Get a specific key
- `keyNameExists()` - Check if name exists

### Provider Properties:

- `apiKeys` - List of all API keys
- `activeApiKey` - Currently active key
- `isLoading` - Loading state
- `hasActiveKey` - Whether an active key exists
- `totalKeys` - Total number of keys
- `validKeysCount` - Number of valid keys

## Error Handling

The GeminiService includes comprehensive error handling:

```dart
try {
  final response = await GeminiService.generateContent(
    apiKey: apiKey,
    prompt: prompt,
  );
} catch (e) {
  final errorMessage = GeminiService.getErrorMessage(e);
  // Show user-friendly error message
}
```

Common error messages:
- "Invalid API key" - Key is not valid
- "API quota exceeded" - Daily limit reached
- "Request timed out" - Network issues
- "Network error" - Connection problems

## Best Practices

1. **Validate New Keys**: Always validate keys after adding them
2. **Use Descriptive Names**: Name keys clearly (e.g., "Work Key", "Personal")
3. **Keep Backup Keys**: Store multiple keys for redundancy
4. **Monitor Usage**: Check "Last Used" timestamps
5. **Revalidate Periodically**: Keys can expire or be revoked
6. **Clean Up**: Delete unused keys to keep the list organized

## Security Notes

- Keys are stored locally in SQLite database
- Keys are never transmitted except for validation
- Use masked display when showing keys to users
- Consider implementing additional encryption for production apps
- API keys in the database are not encrypted by default

## Troubleshooting

### Key Validation Fails
- Check internet connection
- Verify key is correct (no extra spaces)
- Confirm key hasn't been revoked
- Check Google Cloud Console for key status

### No Active Key
- Add at least one API key
- Tap "Set Active" on a valid key
- Verify key is validated before using

### Key Not Working in App
- Ensure key is set as active
- Validate the key first
- Check if key has necessary permissions
- Verify API quota hasn't been exceeded

## Future Enhancements

Potential features to add:
- Key usage statistics
- API quota tracking
- Key expiration dates
- Key permissions/scopes
- Export/import keys
- Cloud backup of keys
- Multi-user support
- Key rotation automation

## Support

For issues or questions:
1. Check validation status of your keys
2. Verify you're using the latest version
3. Review error messages carefully
4. Check Google AI Studio documentation
5. Ensure your API key has proper permissions
