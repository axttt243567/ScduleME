# AI Event Creator - Quick Reference

## 🚀 Quick Start

### Access
```
Profile → AI Assistant → Create Events with AI
```

### Basic Usage
1. Describe what you want to schedule
2. Answer AI's clarifying questions
3. Review event preview cards
4. Approve or reject each event

---

## 💬 Example Prompts

### Single Events
```
"Schedule a team meeting tomorrow at 2 PM"
"I have a dentist appointment on Friday at 10 AM"
"Create a study session for tonight from 7 to 9 PM"
```

### Multiple Events
```
"Schedule my gym sessions for this week, MWF at 6 AM"
"I need daily study sessions next week from 4 to 6 PM"
"Create 5 project work sessions this month"
```

### Detailed Events
```
"I have a final exam on November 1st, help me schedule study sessions"
"Schedule my weekly team meetings every Monday at 9 AM"
"Create a multi-day event for my vacation from Dec 20-27"
```

---

## 📋 Event Fields

### Required
- **Title**: Event name
- **Date**: Start date (YYYY-MM-DD)
- **Category**: One of 10 predefined categories
- **Priority**: Low, Medium, High, or Urgent

### Optional
- **Time**: Start time (HH:MM in 24-hour format)
- **Duration**: In minutes
- **All Day**: Boolean flag
- **Repetition**: None, Daily, Weekly, Custom
- **Notes**: Additional details
- **Icon**: From 24+ available icons

---

## 🏷️ Categories

| Category | ID | Color |
|----------|-----|-------|
| Academic | `academic` | Cyan |
| Assignment | `assignment` | Pink |
| Exam | `exam` | Red |
| Project | `project` | Orange |
| Study | `study` | Purple |
| Personal | `personal` | Green |
| Health | `health` | Magenta |
| Social | `social` | Yellow |
| Work | `work` | Purple |
| Other | `other` | Gray |

---

## ⚡ Priority Levels

| Priority | ID | Description |
|----------|-----|-------------|
| 🔴 Urgent | `urgent` | Needs immediate attention |
| 🟠 High | `high` | Important, do soon |
| 🟡 Medium | `medium` | Normal priority |
| 🟢 Low | `low` | Can be done later |

---

## 🎨 Available Icons

```
event, school, assignment, quiz, book, person, favorite, people, 
work, home, fitness_center, restaurant, flight, shopping_cart, 
music_note, movie, sports, computer, phone, mail, calendar_today, 
chat, photo, videocam
```

---

## 🔄 Repetition Patterns

| Pattern | Description |
|---------|-------------|
| None | One-time event |
| Daily | Repeats every day |
| Weekly | Repeats same day each week |
| Custom | Specific weekdays (e.g., MWF) |

---

## ✅ Approval Workflow

1. **Preview**: AI shows event in card format
2. **Review**: Check all details carefully
3. **Approve**: Tap green "Approve" button
   - Event saved to database
   - Appears in Today/Calendar views
   - Shows ✓ confirmation
4. **Reject**: Tap red "Reject" button
   - Event discarded
   - Shows ✗ confirmation

---

## 🎯 Tips for Best Results

### ✅ DO:
- Be specific about dates and times
- Mention duration if not 1 hour
- Specify priority for important events
- Review previews carefully
- Approve/reject each event individually

### ❌ DON'T:
- Use vague time references ("later", "soon")
- Skip confirmation when AI asks
- Approve without reviewing details
- Forget to set priority for urgent items

---

## 📝 JSON Response Format

When AI creates events, it uses this format:

```json
{
  "action": "create_events",
  "events": [
    {
      "title": "Study Session",
      "categoryId": "study",
      "priority": "high",
      "startDate": "2025-10-25",
      "startTime": "18:00",
      "durationMinutes": 120,
      "isAllDay": false,
      "repetitionPattern": "none",
      "notes": "Focus on chapters 4-6",
      "icon": "book"
    }
  ]
}
```

---

## 🔧 Common Actions

### Clear Chat
1. Tap ⋮ menu (top right)
2. Select "Clear Chat"
3. Confirm

### Create Multiple Events
Just describe multiple events:
```
"Create a study session tomorrow and a gym session on Friday"
```

### Modify After Creation
Rejected events can be recreated with new details:
```
"Actually, make that study session 2 hours instead"
```

---

## ⚠️ Requirements

- ✅ Active Gemini API key
- ✅ Internet connection
- ✅ Valid event details

### No API Key?
Go to: `Profile → Account Settings → Gemini API Keys → Add New Key`

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "No API Key" error | Add API key in settings |
| AI not creating events | Confirm intent explicitly |
| Wrong event details | Reject and provide new details |
| JSON error | Clear chat and restart |
| Events not appearing | Check Today/Calendar views |

---

## 💡 Pro Tips

1. **Batch Similar Events**: Ask for multiple at once
   ```
   "Schedule 5 workout sessions this week"
   ```

2. **Be Specific About Time**:
   ```
   "Meeting at 2:30 PM" (not "in the afternoon")
   ```

3. **Include Duration**:
   ```
   "2-hour study session" (not just "study session")
   ```

4. **Specify Category**:
   ```
   "Academic event: Lecture on Monday"
   ```

5. **Set Priority Early**:
   ```
   "Urgent: Submit assignment by Friday"
   ```

---

## 📱 Event Preview Card

```
┌─────────────────────────────────┐
│ 📚 Study Session                │
│ [Study] [High]                  │
│                                 │
│ 📅 Tomorrow                     │
│ ⏰ 6:00 PM (120 min)           │
│                                 │
│ "Focus on chapters 4-6"         │
│                                 │
│ [Reject]        [Approve ✓]    │
└─────────────────────────────────┘
```

---

## 🎓 Example Conversations

### Quick Event
```
You: "Dentist tomorrow at 3 PM"
AI:  "Creating dentist appointment..." [Shows preview]
You: [Approve]
```

### Multiple Events
```
You: "Study sessions Mon-Fri next week, 7-9 PM"
AI:  "I'll create 5 study sessions..." [Shows 5 previews]
You: [Approve each one]
```

### Detailed Event
```
You: "Help me prepare for my exam on Nov 1"
AI:  "When do you want to start?"
You: "This weekend"
AI:  "How many sessions?"
You: "One session per day, 2 hours each"
AI:  "Creating study plan..." [Shows multiple previews]
```

---

## 📚 Related Features

- **Event Management**: Edit/delete events
- **Today View**: Timeline of today's events
- **Calendar**: Month/week views
- **Analytics**: Track event completion
- **AI Assist**: General scheduling help

---

**Quick Help**: Profile → AI Assistant → Create Events with AI

**Documentation**: `docs/AI_EVENT_CREATOR_GUIDE.md`
