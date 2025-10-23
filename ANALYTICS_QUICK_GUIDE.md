# Quick Reference Guide - Analytics Features

## 🎯 Quick Access

### From Profile Page:
```
Profile → Analytics           (View analytics dashboard)
Profile → Manage Analytics    (Filter and delete events)
Profile → Category Management (Manage categories and bulk delete)
```

---

## 📊 Analytics Page Features

### Tab 1: Overview
```
┌─────────────────────────────────────────┐
│         Analytics Dashboard             │
├─────────────────────────────────────────┤
│  [Total] [Completed] [Upcoming] [Missed]│
│                                         │
│  Overall Completion Rate: 75% ████░░    │
│                                         │
│  Priority Distribution:                 │
│  • Urgent:  ████░░░░ 30 events         │
│  • High:    ██████░░ 45 events         │
│  • Medium:  ████████ 60 events         │
│  • Low:     ██░░░░░░ 15 events         │
│                                         │
│  Recent Activity:                       │
│  📚 Study Session     [Done]           │
│  💪 Gym Workout       [Missed]         │
│  👥 Team Meeting      [Pending]        │
└─────────────────────────────────────────┘
```

### Tab 2: Categories
```
┌─────────────────────────────────────────┐
│    Tap any category for details →      │
├─────────────────────────────────────────┤
│  📚 Academic          75% ████████░░    │
│     25 events • 20 completed            │
│                                         │
│  💼 Work              60% ██████░░░░    │
│     15 events • 9 completed             │
│                                         │
│  💪 Fitness           90% █████████░    │
│     10 events • 9 completed             │
└─────────────────────────────────────────┘
```

### Tab 3: Reports
```
┌─────────────────────────────────────────┐
│     ◄  October 2025  ►                 │
├─────────────────────────────────────────┤
│  Monthly Summary:                       │
│  Total: 50  Done: 35  Skipped: 5       │
│  Missed: 10  Completion: 70% ███████░   │
│                                         │
│  Category Breakdown:                    │
│  📚 Academic  20/25  ████████░░  80%   │
│  💼 Work      9/15   ██████░░░░  60%   │
│  💪 Fitness   6/10   ██████░░░░  60%   │
└─────────────────────────────────────────┘
```

---

## 🎛️ Manage Analytics Page

### Filter Structure:
```
┌─────────────────────────────────────────┐
│      Manage Analytics                   │
├─────────────────────────────────────────┤
│  Action Type:                           │
│  [All] [Completed] [Pending] [Skip] [Missed]
│                                         │
│  Time Period:                           │
│  [All] [Today] [Last 3 Days] [This Week]│
│  [Last Week] [This Month] [Last Month]  │
│                                         │
│  Categories:        [Select All ↓]      │
│  [📚 Academic] [💼 Work] [💪 Fitness]  │
│  [🎨 Creative] [👥 Social] [⚙️ Other]  │
├─────────────────────────────────────────┤
│  45 events found         [Select All]   │
├─────────────────────────────────────────┤
│  □ 📚 Study Session      [Done]        │
│  □ 💪 Gym Workout        [Missed]      │
│  ☑ 👥 Team Meeting       [Pending]     │
│                                         │
│            [Delete Selected]            │
└─────────────────────────────────────────┘
```

### Filter Examples:
- **Action**: Completed → Shows only done events
- **Time**: This Week → Shows events from current week
- **Category**: Academic + Work → Shows events from both

---

## 📁 Manage Categories Page

### Normal Mode:
```
┌─────────────────────────────────────────┐
│  Manage Categories          [⋮ Menu]   │
├─────────────────────────────────────────┤
│  ℹ View your categories and events      │
├─────────────────────────────────────────┤
│  📚 Academic              [25]  →      │
│     25 events                           │
│                                         │
│  💼 Work                  [15]  →      │
│     15 events                           │
│                                         │
│  💪 Fitness               [10]  →      │
│     10 events                           │
└─────────────────────────────────────────┘

Menu Options:
• Create Category (placeholder)
• Select Categories
```

### Selection Mode:
```
┌─────────────────────────────────────────┐
│  2 selected         [🗑️ Delete] [✕]    │
├─────────────────────────────────────────┤
│  ☑ 📚 Academic             [25]        │
│                                         │
│  □ 💼 Work                 [15]        │
│                                         │
│  ☑ 💪 Fitness              [10]        │
└─────────────────────────────────────────┘

Delete Flow:
1. Select categories
2. Tap delete icon
3. Confirm deletion
4. All events in selected categories deleted
```

---

## 🎨 Visual Indicators

### Remark Badges:
- **Done**: 🟢 Green circle
- **Pending**: ⚪ Gray circle  
- **Skipped**: 🟡 Orange skip icon
- **Missed**: 🔴 Red X icon

### Progress Bars:
- **75%+**: 🟢 Green (Good)
- **50-74%**: 🟡 Orange (Fair)
- **<50%**: 🔴 Red (Needs attention)

### Selection States:
- **Selected**: Blue/Primary color background
- **Unselected**: Default gray background

---

## ⚡ Quick Actions

### View Category Details:
`Analytics → Categories → Tap Category`

### Filter Events:
`Manage Analytics → Set Filters → View Results`

### Bulk Delete:
`Manage Analytics → Select Events → Delete`
or
`Category Management → Select Categories → Delete`

### Monthly Report:
`Analytics → Reports → Select Month`

---

## 💡 Tips

1. **Use Time Filters**: Quickly find today's or this week's events
2. **Category View**: Best for comparing performance across categories
3. **Reports Tab**: Best for monthly reviews and planning
4. **Bulk Operations**: Save time by selecting multiple items
5. **Empty States**: Use "Reset Filters" if no results appear

---

## 🔄 Data Updates

All pages use **real-time data** via Provider:
- Changes reflect immediately
- No manual refresh needed
- Consistent across all views

---

## ⚠️ Important Notes

1. **Deletion is permanent**: Confirm before deleting
2. **Category creation**: Currently placeholder (future update)
3. **Selection mode**: Exit by tapping ✕ or back button
4. **Filters persist**: Until changed or reset

---

## 📞 Common Use Cases

### Weekly Review:
1. Go to Reports tab
2. Check this week's completion rate
3. Review category breakdown

### Clean Up Old Events:
1. Go to Manage Analytics
2. Set time filter (e.g., Last Month)
3. Set action filter (e.g., Missed)
4. Select and delete

### Category Performance:
1. Go to Categories tab
2. Tap underperforming category
3. Review monthly trends
4. Check priority distribution

---

Happy analyzing! 📊✨
