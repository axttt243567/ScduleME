// Example: How to Use the Event System

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

// ==========================================
// EXAMPLE 1: Creating a Simple Event
// ==========================================
Future<void> createSimpleEvent(BuildContext context) async {
  final provider = context.read<EventProvider>();

  final event = Event(
    title: 'Math Lecture',
    categoryIds: [Categories.academic.id],
    priority: EventPriority.medium,
    startDate: DateTime.now(),
    isAllDay: false,
    startTime: const TimeOfDay(hour: 10, minute: 0),
    durationMinutes: 90,
    repetitionPattern: RepetitionPattern.none,
    icon: Icons.calculate,
    remark: EventRemark.none,
  );

  await provider.createEvent(event);
}

// ==========================================
// EXAMPLE 2: Creating a Recurring Event
// ==========================================
Future<void> createRecurringEvent(BuildContext context) async {
  final provider = context.read<EventProvider>();

  // Repeats every Monday, Wednesday, Friday
  final event = Event(
    title: 'Morning Workout',
    categoryIds: [Categories.health.id, Categories.personal.id],
    priority: EventPriority.low,
    startDate: DateTime.now(),
    isAllDay: false,
    startTime: const TimeOfDay(hour: 6, minute: 30),
    durationMinutes: 60,
    repetitionPattern: RepetitionPattern.custom,
    customWeekdays: [1, 3, 5], // Mon=1, Wed=3, Fri=5
    icon: Icons.fitness_center,
    remark: EventRemark.none,
    notes: 'Bring water bottle and towel',
  );

  await provider.createEvent(event);
}

// ==========================================
// EXAMPLE 3: Creating an All-Day Event
// ==========================================
Future<void> createAllDayEvent(BuildContext context) async {
  final provider = context.read<EventProvider>();

  final event = Event(
    title: 'Career Fair',
    categoryIds: [Categories.work.id, Categories.academic.id],
    priority: EventPriority.high,
    startDate: DateTime.now().add(const Duration(days: 7)),
    isAllDay: true, // All-day event
    repetitionPattern: RepetitionPattern.none,
    icon: Icons.business_center,
    remark: EventRemark.none,
    notes: 'Dress professionally, bring resume',
  );

  await provider.createEvent(event);
}

// ==========================================
// EXAMPLE 4: Creating a Multi-Day Event
// ==========================================
Future<void> createMultiDayEvent(BuildContext context) async {
  final provider = context.read<EventProvider>();

  final startDate = DateTime.now().add(const Duration(days: 30));
  final endDate = startDate.add(const Duration(days: 7));

  final event = Event(
    title: 'Spring Break Trip',
    categoryIds: [Categories.personal.id],
    priority: EventPriority.low,
    startDate: startDate,
    endDate: endDate, // Multi-day event
    isAllDay: true,
    repetitionPattern: RepetitionPattern.none,
    icon: Icons.flight,
    remark: EventRemark.none,
    notes: 'Beach resort in Miami - Hotel: Seaside Inn',
  );

  await provider.createEvent(event);
}

// ==========================================
// EXAMPLE 5: Getting Events for a Date
// ==========================================
void getEventsForDate(BuildContext context) {
  final provider = context.read<EventProvider>();
  final today = DateTime.now();

  // Get events for today
  final todayEvents = provider.getEventsForDate(today);

  // Get events happening now
  final currentEvents = provider.getCurrentEvents();

  // Get events for next week
  final nextWeek = today.add(const Duration(days: 7));
  final nextWeekEvents = provider.getEventsForDate(nextWeek);
}

// ==========================================
// EXAMPLE 6: Filtering Events
// ==========================================
void filterEvents(BuildContext context) {
  final provider = context.read<EventProvider>();

  // Get all academic events
  final academicEvents = provider.getEventsByCategory(Categories.academic.id);

  // Get events for a date range
  final startDate = DateTime.now();
  final endDate = startDate.add(const Duration(days: 30));
  final rangeEvents = provider.getEventsForDateRange(startDate, endDate);
}

// ==========================================
// EXAMPLE 7: Updating an Event
// ==========================================
Future<void> updateEventStatus(BuildContext context, String eventId) async {
  final provider = context.read<EventProvider>();

  // Mark event as done
  await provider.updateEventRemark(
    eventId,
    EventRemark.done,
    notes: 'Completed successfully!',
  );
}

// ==========================================
// EXAMPLE 8: Deleting an Event
// ==========================================
Future<void> deleteEvent(BuildContext context, String eventId) async {
  final provider = context.read<EventProvider>();
  await provider.deleteEvent(eventId);
}

// ==========================================
// EXAMPLE 9: Searching Events
// ==========================================
Future<void> searchEvents(BuildContext context, String query) async {
  final provider = context.read<EventProvider>();

  // Search in titles, notes, and hashtags
  final results = await provider.searchEvents(query);

  // Example: search for 'math'
  // Will find events with 'math' in title, notes, or hashtags
}

// ==========================================
// EXAMPLE 10: Creating an Exam Event
// ==========================================
Future<void> createExamEvent(BuildContext context) async {
  final provider = context.read<EventProvider>();

  final examDate = DateTime.now().add(const Duration(days: 14));

  final event = Event(
    title: 'Midterm Exam - Computer Science',
    categoryIds: [Categories.exam.id, Categories.academic.id],
    priority: EventPriority.urgent, // High priority!
    startDate: examDate,
    isAllDay: false,
    startTime: const TimeOfDay(hour: 9, minute: 0),
    durationMinutes: 120, // 2 hours
    repetitionPattern: RepetitionPattern.none,
    icon: Icons.quiz,
    remark: EventRemark.none,
    notes: '''
Exam Coverage:
- Data Structures (Arrays, LinkedLists, Trees)
- Algorithms (Sorting, Searching)
- Time Complexity Analysis
- Practice Problems: Chapter 1-6

Materials Needed:
- Student ID
- Calculator
- Pencils

Room: Engineering Building, Room 205
    ''',
  );

  await provider.createEvent(event);
}

// ==========================================
// EXAMPLE 11: Using Events in UI
// ==========================================
class EventListWidget extends StatelessWidget {
  const EventListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CircularProgressIndicator();
        }

        if (provider.error != null) {
          return Text('Error: ${provider.error}');
        }

        final events = provider.getEventsForDate(DateTime.now());

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ListTile(
              leading: Icon(event.icon),
              title: Text(event.title),
              subtitle: Text(event.getTimeString()),
              trailing: event.isHappeningNow()
                  ? const Chip(label: Text('NOW'))
                  : null,
            );
          },
        );
      },
    );
  }
}

// ==========================================
// EXAMPLE 12: Load Events on App Start
// ==========================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // Load events when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EventListWidget());
  }
}

// ==========================================
// EXAMPLE 13: Check if Event Occurs on Date
// ==========================================
void checkEventOccurrence() {
  final event = Event(
    title: 'Weekly Meeting',
    categoryIds: [Categories.work.id],
    priority: EventPriority.medium,
    startDate: DateTime(2025, 10, 20), // Monday
    isAllDay: false,
    startTime: const TimeOfDay(hour: 14, minute: 0),
    durationMinutes: 60,
    repetitionPattern: RepetitionPattern.weekly,
    icon: Icons.meeting_room,
    remark: EventRemark.none,
  );

  // Check if event occurs on a specific date
  final checkDate = DateTime(2025, 10, 27); // Next Monday
  final occurs = event.occursOnDate(checkDate);
  // Returns true because it's a weekly event on Monday
}
