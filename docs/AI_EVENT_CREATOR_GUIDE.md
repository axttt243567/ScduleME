# AI Event Creator Feature Documentation

## Overview
The AI Event Creator is a conversational interface that allows users to create events using natural language with the help of Gemini AI. The assistant guides users through the event creation process, asks clarifying questions, confirms details, and presents events in a card-style preview for approval.

## Feature Location
**Navigation**: Profile → AI Assistant → Create Events with AI

## Key Features

### 1. **Conversational Interface**
- Natural language interaction with Gemini AI
- AI asks clarifying questions about event details
- Confirms user intent before creating events
- Maintains conversation context throughout the session

### 2. **Multiple Event Creation**
- Can create multiple events in a single conversation
- AI can generate related events (e.g., study sessions for a week)
- Each event is presented separately for individual approval

### 3. **Event Preview Cards**
- Beautiful card-style preview of each suggested event
- Shows all event details:
  - Title and icon
  - Category badge (with color)
  - Priority badge (with color)
  - Date and time information
  - Duration
  - Notes (if any)

### 4. **Approval Mechanism**
- Each event must be approved individually
- Approve button: Adds event to schedule
- Reject button: Dismisses the event
- Visual feedback for approved/rejected events
- Real-time database updates on approval

### 5. **Smart AI Context**
The AI assistant has knowledge of:
- Available categories (Academic, Assignment, Exam, Project, Study, Personal, Health, Social, Work, Other)
- Priority levels (Low, Medium, High, Urgent)
- 24+ available icons for events
- Date and time formatting requirements
- Repetition patterns (None, Daily, Weekly, Custom)

## Usage Flow

### Step 1: Navigate to Feature
1. Open the app
2. Go to Profile tab
3. Scroll to "AI Assistant" section
4. Tap "Create Events with AI"

### Step 2: Describe Your Event
Tell the AI what you want to schedule, for example:
- "I need to study for my exam next week"
- "Schedule my gym sessions for this month"
- "Create a meeting for tomorrow at 2 PM"
- "I have a project deadline on Friday"

### Step 3: Clarification
The AI will ask clarifying questions if needed:
- Specific date and time
- Duration of the event
- Priority level
- Category
- Any special notes or requirements

### Step 4: Review Event Previews
- AI presents events in card format
- Each card shows complete event details
- Review each event carefully

### Step 5: Approve or Reject
- Tap "Approve" to add the event to your schedule
- Tap "Reject" to dismiss the event
- Approved events are immediately saved to database
- Visual confirmation displayed for each action

## Technical Details

### JSON Format for Event Creation
The AI generates events using this JSON structure:
```json
{
  "action": "create_events",
  "events": [
    {
      "title": "Event Title",
      "categoryId": "academic",
      "priority": "medium",
      "startDate": "2025-10-25",
      "startTime": "14:30",
      "durationMinutes": 60,
      "isAllDay": false,
      "repetitionPattern": "none",
      "notes": "Optional notes",
      "icon": "event"
    }
  ]
}
```

### Valid Values

**Categories:**
- `academic`, `assignment`, `exam`, `project`, `study`, `personal`, `health`, `social`, `work`, `other`

**Priorities:**
- `low`, `medium`, `high`, `urgent`

**Repetition Patterns:**
- `none`, `daily`, `weekly`, `custom`

**Date Format:**
- ISO 8601: `YYYY-MM-DD` (e.g., "2025-10-25")

**Time Format:**
- 24-hour: `HH:MM` (e.g., "14:30")

**Available Icons:**
- `event`, `school`, `assignment`, `quiz`, `book`, `person`, `favorite`, `people`, `work`, `home`, `fitness_center`, `restaurant`, `flight`, `shopping_cart`, `music_note`, `movie`, `sports`, `computer`, `phone`, `mail`, `calendar_today`, `chat`, `photo`, `videocam`

## Features in Detail

### Conversation Context
- Maintains history of recent messages
- AI remembers user preferences within session
- Context-aware follow-up questions
- Can reference previous messages

### Error Handling
- Gracefully handles JSON parsing errors
- Provides fallback conversational responses
- Clear error messages for users
- Validates event data before preview

### Visual Design
- Material Design 3 components
- Category-colored badges
- Priority-colored badges
- Smooth animations
- Consistent with app theme
- Dark mode optimized

### Database Integration
- Events saved immediately on approval
- Full integration with EventProvider
- Persists to SQLite database
- Available immediately in Today/Calendar views
- Includes all event properties (title, category, priority, dates, times, repetition, etc.)

## Example Conversations

### Example 1: Simple Event
**User:** "I have a dentist appointment tomorrow at 3 PM"

**AI:** "I'll create a dentist appointment for you. Let me confirm the details:
- Title: Dentist Appointment
- Date: Tomorrow (October 24)
- Time: 3:00 PM
- Duration: 1 hour
- Category: Personal
- Priority: Medium

Should I create this event?"

**User:** "Yes, please"

**AI:** [Generates event JSON and displays preview card]

### Example 2: Multiple Events
**User:** "Schedule my study sessions for this week, Monday to Friday from 6 PM to 8 PM"

**AI:** "I'll create study sessions for you Monday through Friday. Let me confirm:
- Duration: 2 hours each day
- Time: 6:00 PM to 8:00 PM
- Category: Study
- Priority: High

This will create 5 events. Shall I proceed?"

**User:** "Yes"

**AI:** [Generates 5 event previews, each can be approved individually]

### Example 3: Detailed Event
**User:** "I need to prepare for my final exam in Computer Science"

**AI:** "I'll help you schedule preparation time. Let me ask a few questions:
1. When is your exam?
2. When would you like to start preparing?
3. How many study sessions do you want?
4. What time of day works best for you?"

**User:** "The exam is on November 1st. I want to start this weekend, 2 hours per day in the evening"

**AI:** [Asks for confirmation and generates multiple study session events]

## Best Practices

### For Users:
1. **Be Specific**: Provide date, time, and duration when possible
2. **Confirm Details**: Review event previews carefully before approving
3. **One by One**: Approve or reject each event individually
4. **Clear Intent**: State what you want clearly to minimize clarifications
5. **Use Context**: Reference previous messages in the conversation

### For AI Prompts:
1. Natural language works best
2. Include key details: what, when, duration
3. Mention priority if it's important
4. Specify category if you have a preference
5. Add notes for additional context

## Limitations

1. **API Key Required**: Users must have an active Gemini API key configured
2. **Internet Connection**: Requires active internet for AI responses
3. **JSON Format**: AI must respond with valid JSON for event creation
4. **Single Approval**: Each event must be approved one at a time (by design)
5. **Context Window**: Conversation history limited to recent messages

## Troubleshooting

### "No API Key" Error
**Solution**: Go to Profile → Account Settings → Gemini API Keys → Add a new key

### AI Not Creating Events
**Solution**: Try confirming your intent explicitly (e.g., "Yes, create these events")

### Event Details Incorrect
**Solution**: Reject the event and provide more specific details to the AI

### JSON Parsing Error
**Solution**: Clear the chat and start over with clearer instructions

## Future Enhancements

Potential improvements:
- Batch approve all events at once
- Edit event details before approval
- Save common event templates
- Voice input support
- Smart scheduling (find free time slots)
- Conflict detection
- Integration with external calendars
- Event suggestions based on past patterns

## Related Features

- **Event Management**: Profile → Event Management
- **Today View**: See approved events in timeline
- **Calendar View**: View all events in calendar
- **Event Detail**: Tap any event to see full details
- **AI Assist**: General AI help (Profile → AI Assist)

---

**Version**: 1.0.0  
**Last Updated**: October 23, 2025  
**Author**: ScheduleMe Team
