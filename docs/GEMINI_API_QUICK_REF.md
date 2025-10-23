# Gemini API - Quick Reference Card

## 🚀 Quick Start

### 1. Check for Active Key
```dart
final provider = context.read<ApiKeyProvider>();
if (!provider.hasActiveKey) {
  // Navigate to API Configuration
  Navigator.push(context, 
    MaterialPageRoute(builder: (_) => ApiConfigurationPage()));
  return;
}
```

### 2. Generate Content
```dart
final activeKey = provider.activeApiKey!;
final response = await GeminiService.generateContent(
  apiKey: activeKey.keyValue,
  prompt: 'Summarize: $text',
);
```

### 3. Update Usage
```dart
await provider.updateLastUsed(activeKey.id!);
```

---

## 📦 Common Patterns

### Pattern 1: Simple Text Generation
```dart
Future<String?> generateSummary(String text) async {
  final provider = context.read<ApiKeyProvider>();
  if (!provider.hasActiveKey) return null;
  
  try {
    final key = provider.activeApiKey!;
    final result = await GeminiService.generateContent(
      apiKey: key.keyValue,
      prompt: 'Summarize this in 3 sentences: $text',
    );
    await provider.updateLastUsed(key.id!);
    return result;
  } catch (e) {
    showError(GeminiService.getErrorMessage(e));
    return null;
  }
}
```

### Pattern 2: Streaming Response
```dart
Future<void> streamGeneration(String prompt) async {
  final provider = context.read<ApiKeyProvider>();
  if (!provider.hasActiveKey) return;
  
  final key = provider.activeApiKey!;
  final stream = GeminiService.generateContentStream(
    apiKey: key.keyValue,
    prompt: prompt,
  );
  
  await for (final chunk in stream) {
    setState(() => _text += chunk);
  }
  
  await provider.updateLastUsed(key.id!);
}
```

### Pattern 3: Chat Conversation
```dart
ChatSession? _chat;

Future<void> startChatSession() async {
  final provider = context.read<ApiKeyProvider>();
  if (!provider.hasActiveKey) return;
  
  final key = provider.activeApiKey!;
  _chat = await GeminiService.startChat(apiKey: key.keyValue);
}

Future<String?> sendMessage(String message) async {
  if (_chat == null) return null;
  
  final response = await _chat!.sendMessage(Content.text(message));
  return response.text;
}
```

### Pattern 4: With Error Handling
```dart
Future<String?> generateWithRetry(String prompt, {int retries = 2}) async {
  final provider = context.read<ApiKeyProvider>();
  if (!provider.hasActiveKey) return null;
  
  for (int i = 0; i <= retries; i++) {
    try {
      final key = provider.activeApiKey!;
      final result = await GeminiService.generateContent(
        apiKey: key.keyValue,
        prompt: prompt,
      );
      await provider.updateLastUsed(key.id!);
      return result;
    } catch (e) {
      if (i == retries) {
        showError(GeminiService.getErrorMessage(e));
        return null;
      }
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }
  return null;
}
```

---

## 🎯 Provider Methods

### Check Status
```dart
provider.hasActiveKey              // bool
provider.activeApiKey              // ApiKey?
provider.totalKeys                 // int
provider.validKeysCount            // int
```

### Load & Manage
```dart
await provider.loadApiKeys()
await provider.addApiKey(name: 'Key', keyValue: 'xxx')
await provider.setActiveKey(id)
await provider.deleteApiKey(id)
```

### Update Status
```dart
await provider.updateValidationStatus(id: id, isValid: true)
await provider.updateLastUsed(id)
```

---

## 🔧 GeminiService Methods

### Validation
```dart
final isValid = await GeminiService.validateApiKey(apiKey);
final isValidFormat = GeminiService.isValidKeyFormat(apiKey);
```

### Generation
```dart
// Simple
final text = await GeminiService.generateContent(
  apiKey: key,
  prompt: 'prompt',
  model: 'gemini-pro', // optional
);

// Stream
final stream = GeminiService.generateContentStream(
  apiKey: key,
  prompt: 'prompt',
);
```

### Chat
```dart
final chat = await GeminiService.startChat(
  apiKey: key,
  history: previousMessages, // optional
);

final response = await chat.sendMessage(Content.text('message'));
```

### Error Handling
```dart
try {
  // ... gemini call
} catch (e) {
  final message = GeminiService.getErrorMessage(e);
  // Show user-friendly error
}
```

---

## 🎨 UI Integration

### Navigate to API Config
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ApiConfigurationPage()),
);
```

### Show Status in UI
```dart
Consumer<ApiKeyProvider>(
  builder: (context, provider, _) {
    if (!provider.hasActiveKey) {
      return Text('No API key configured');
    }
    return Text('Using: ${provider.activeApiKey!.name}');
  },
)
```

### Conditional Features
```dart
final hasKey = context.watch<ApiKeyProvider>().hasActiveKey;

FilledButton(
  onPressed: hasKey ? _generateContent : _promptAddKey,
  child: Text(hasKey ? 'Generate' : 'Add API Key'),
)
```

---

## ⚡ Performance Tips

1. **Cache Active Key**
   ```dart
   // Don't
   for (var item in items) {
     final key = provider.activeApiKey; // Called N times
   }
   
   // Do
   final key = provider.activeApiKey;
   for (var item in items) {
     // Use key
   }
   ```

2. **Use Read vs Watch**
   ```dart
   // For one-time read (doesn't rebuild)
   context.read<ApiKeyProvider>()
   
   // For reactive updates (rebuilds on change)
   context.watch<ApiKeyProvider>()
   ```

3. **Validate Once**
   ```dart
   // Validate after adding, not on every use
   await provider.addApiKey(...);
   await GeminiService.validateApiKey(key);
   ```

---

## 🐛 Common Issues

### Issue: "No active key"
```dart
// Check before using
if (!provider.hasActiveKey) {
  // Guide user to add key
  return;
}
```

### Issue: "Invalid API key"
```dart
// Validate after adding
final isValid = await GeminiService.validateApiKey(key);
if (!isValid) {
  showError('Please check your API key');
}
```

### Issue: "Quota exceeded"
```dart
// Catch and handle quota errors
try {
  // ... API call
} catch (e) {
  if (e.toString().contains('quota')) {
    showError('API quota exceeded. Try another key.');
  }
}
```

---

## 📱 Example: Complete Feature

```dart
class AiSummaryButton extends StatefulWidget {
  final String text;
  const AiSummaryButton({required this.text});
  
  @override
  State<AiSummaryButton> createState() => _AiSummaryButtonState();
}

class _AiSummaryButtonState extends State<AiSummaryButton> {
  bool _loading = false;
  String? _summary;
  
  Future<void> _generateSummary() async {
    final provider = context.read<ApiKeyProvider>();
    
    // Check for active key
    if (!provider.hasActiveKey) {
      _promptAddKey();
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      final key = provider.activeApiKey!;
      
      // Generate summary
      final result = await GeminiService.generateContent(
        apiKey: key.keyValue,
        prompt: 'Summarize in 2-3 sentences: ${widget.text}',
      );
      
      // Update usage
      await provider.updateLastUsed(key.id!);
      
      setState(() {
        _summary = result;
        _loading = false;
      });
      
      _showSummary();
    } catch (e) {
      setState(() => _loading = false);
      _showError(GeminiService.getErrorMessage(e));
    }
  }
  
  void _promptAddKey() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('API Key Required'),
        content: Text('Please add a Gemini API key to use AI features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ApiConfigurationPage()),
              );
            },
            child: Text('Add Key'),
          ),
        ],
      ),
    );
  }
  
  void _showSummary() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('AI Summary'),
        content: Text(_summary ?? ''),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : _generateSummary,
      icon: _loading 
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(Icons.auto_awesome),
      label: Text(_loading ? 'Generating...' : 'AI Summary'),
    );
  }
}
```

---

## 🔗 Quick Links

- User Guide: `docs/GEMINI_API_GUIDE.md`
- Full Summary: `docs/API_CONFIGURATION_SUMMARY.md`
- Get API Key: https://makersuite.google.com/app/apikey
- Gemini Docs: https://ai.google.dev/docs

---

## 💡 Pro Tips

1. Always check `hasActiveKey` before using API
2. Update `lastUsed` after successful calls
3. Use `Consumer` for reactive UI updates
4. Handle errors with user-friendly messages
5. Validate keys after adding them
6. Cache the active key for multiple calls
7. Use streaming for long responses
8. Implement retry logic for network issues
