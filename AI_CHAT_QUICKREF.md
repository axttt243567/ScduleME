# AI Chat Event Creator - Quick Reference

## Quick Start

### Navigate to AI Chat
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AiEventCreatorPageNew(),
  ),
);
```

## Key Components Summary

### 📦 Models (`ai_chat_models.dart`)
- `AiChatMessage` - Main message class
- `ChipGroup` - Collection of interactive chips
- `ChipOption` - Individual chip
- `EventTypeCard` - Visual category card
- `EventCreationStep` - Progress step

### 🤖 AI Service (`ai_event_service.dart`)
```dart
// Generate AI response
final response = await AiEventService.generateEventCreationResponse(
  apiKey: apiKey,
  userMessage: userMessage,
  conversationContext: context,
  currentDate: DateTime.now(),
  existingCategories: categories,
);
```

### 🎨 Widgets

#### Interactive Chips
```dart
InteractiveChipWidget(
  chipGroup: chipGroup,
  onChipsSelected: (selected) {
    // Handle selection
  },
)
```

**Selection Modes:**
- `single` - Auto-submit on tap
- `multiple` - Select many, manual submit
- `toggle` - Yes/No style
- `singleWithConfirm` - Select one, manual submit

#### Date/Time Pickers
```dart
// Date picker
InlineDatePicker(
  initialDate: DateTime.now(),
  onDateSelected: (date) { },
)

// Time picker
InlineTimePicker(
  initialTime: TimeOfDay.now(),
  onTimeSelected: (time) { },
)
```

#### Event Type Cards
```dart
EventTypeCardsWidget(
  cards: eventTypeCards,
  onCardSelected: (card) { },
  allowMultipleSelection: false,
)
```

#### Chat Bubble
```dart
AiChatBubble(
  message: message,
  onChipsSelected: handleChips,
  onDateSelected: handleDate,
  onTimeSelected: handleTime,
  onEventTypeSelected: handleCard,
  onQuickAction: handleAction,
)
```

#### Progress Tracker
```dart
EventCreationProgressTracker(
  steps: steps,
  currentStepIndex: currentIndex,
  onStepTap: (index) { },
  isCompact: true,  // For header
)
```

#### Event Preview
```dart
EventPreviewScreen(
  event: event,
  onConfirm: () { },
  onEdit: () { },
)
```

## AI Response Formats

### Text Response
```json
{
  "responseType": "text",
  "text": "Your message here"
}
```

### Chips Response
```json
{
  "responseType": "chips",
  "text": "Choose an option:",
  "chipGroup": {
    "id": "choice_1",
    "question": "What type?",
    "options": [
      {"id": "opt1", "label": "Option 1", "value": "val1", "icon": "check"}
    ],
    "selectionMode": "single",
    "showSubmitButton": false
  }
}
```

### Event Cards Response
```json
{
  "responseType": "eventTypeCards",
  "text": "Select event type:",
  "eventTypeCards": [
    {
      "id": "academic",
      "name": "Academic",
      "icon": "school",
      "color": "0xFF00D9FF",
      "description": "Classes and lectures"
    }
  ]
}
```

### Date/Time Picker Response
```json
{
  "responseType": "dateTimePicker",
  "text": "When is this event?",
  "requiresDatePicker": true,
  "requiresTimePicker": true
}
```

## Chip Templates

### Quick Actions
```dart
AiEventService.getQuickActionChips()
// Returns: Retry, Bad Response, Shorter
```

### Date Suggestions
```dart
AiEventService.getDateSuggestionChips(DateTime.now())
// Returns: Today, Tomorrow, Next Week, Custom
```

### Repetition
```dart
AiEventService.getRepetitionChips()
// Returns: None, Daily, Weekly, Custom
```

### Priority
```dart
AiEventService.getPriorityChips()
// Returns: Low, Medium, High, Urgent
```

## Event Creation Steps

Default 6-step flow:
1. **Purpose** - What's the event about?
2. **Type** - Category selection
3. **Date & Time** - When does it occur?
4. **Repetition** - Does it repeat?
5. **Priority** - How important?
6. **Details** - Additional notes

## Common Patterns

### Handle Chip Selection
```dart
void _handleChipsSelected(List<ChipOption> chips) {
  final values = chips.map((c) => c.value).toList();
  _sendMessage(text: chips.map((c) => c.label).join(', '));
  
  // Store data
  for (var chip in chips) {
    _eventData[chip.id] = chip.value;
  }
}
```

### Handle Quick Actions
```dart
void _handleQuickAction(String action) {
  switch (action) {
    case 'retry':
      _sendMessage(text: 'Can you try again?');
      break;
    case 'bad_response':
      _sendMessage(text: 'That wasn\'t helpful');
      break;
    case 'shorter':
      _sendMessage(text: 'Make it shorter');
      break;
  }
}
```

### Update Progress
```dart
void _updateProgress() {
  setState(() {
    // Update step based on collected data
    if (_eventData.containsKey('category')) {
      _steps[1] = _steps[1].copyWith(
        value: _eventData['category'],
        isCompleted: true,
      );
    }
    
    // Move to next step
    _currentStepIndex = _steps.indexWhere((s) => !s.isCompleted);
  });
}
```

### Create Event from Data
```dart
Event _createEvent() {
  return Event(
    title: _eventData['title'] ?? 'Event',
    categoryIds: [_eventData['category'] ?? 'other'],
    priority: _parsePriority(_eventData['priority']),
    startDate: DateTime.parse(_eventData['date']),
    startTime: _parseTime(_eventData['time']),
    // ... other fields
  );
}
```

## Icon Names for Chips

Common icons that can be used in JSON responses:
- `check` - Checkmark
- `close` - X mark
- `event` - Calendar
- `today` - Today
- `calendar` - Calendar month
- `alarm` - Clock
- `repeat` - Repeat arrows
- `star` - Star
- `flag` - Flag
- `school` - School building
- `work` - Briefcase
- `person` - Person icon
- `people` - Multiple people
- `favorite` - Heart

## Animation Durations

- Chip selection: 200ms
- Message fade-in: 300ms
- Loading pulse: 1500ms (repeat)
- Scroll to bottom: 300ms
- Progress update: Instant with smooth animation

## Error Handling

```dart
try {
  final response = await AiEventService.generate...();
  _handleResponse(response);
} catch (e) {
  setState(() {
    _messages.add(AiChatMessage(
      type: ChatMessageType.error,
      errorMessage: e.toString(),
      // ...
    ));
  });
}
```

## Testing Quick Commands

Users can test with these example messages:
- "Create a study session for tomorrow"
- "I have an exam next week"
- "Schedule my gym routine"
- "Add a meeting at 2 PM"
- "Create a project deadline"

## Customization Points

1. **Chip appearance**: Modify `_buildChip()` in `InteractiveChipWidget`
2. **AI behavior**: Update system prompt in `AiEventService`
3. **Progress steps**: Change `EventCreationSteps.getDefaultSteps()`
4. **Event cards**: Use `EventTypeCardHelper` for custom cards
5. **Colors/themes**: All widgets use theme colors automatically

## Performance Tips

- Limit conversation history to last 10 messages
- Use `isCompact` for progress tracker in header
- Implement pagination for long chat histories
- Cache event type cards
- Debounce text input if needed

## Common Issues

### API Key Not Working
- Check key is active in ApiKeyProvider
- Verify key format with `GeminiService.isValidKeyFormat()`
- Test with simple validation call

### Chips Not Showing
- Verify JSON response format
- Check `ChipGroup.fromJson()` parsing
- Ensure icons are valid

### Date Picker Issues
- Verify `initialDate` is valid
- Check date range constraints
- Ensure date format is ISO 8601

### Progress Not Updating
- Call `_updateProgress()` after data changes
- Verify step IDs match event data keys
- Check `setState()` is called

## Debug Mode

Add logging to track conversation:
```dart
void _sendMessage({String? text}) {
  print('User: $text');
  print('Context: $_conversationContext');
  print('Event Data: $_eventData');
  // ...
}
```

## Resources

- Main guide: `AI_CHAT_INTERFACE_GUIDE.md`
- Gemini API docs: https://ai.google.dev/docs
- Material Design: https://m3.material.io/
- Flutter docs: https://flutter.dev/docs

---

**Last Updated:** October 23, 2025
**Version:** 1.0.0
