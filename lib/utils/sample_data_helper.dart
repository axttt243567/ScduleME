import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

/// Helper class to create sample events for testing
class SampleDataHelper {
  /// Check if sample data already exists
  static Future<bool> hasSampleData(EventProvider provider) async {
    return provider.events.any(
      (event) => event.notes?.contains('SAMPLE_EVENT') ?? false,
    );
  }

  /// Create sample events and add them to the provider
  static Future<void> createSampleEvents(EventProvider provider) async {
    // Check if sample data already exists
    if (await hasSampleData(provider)) {
      return; // Don't add duplicate sample data
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sampleEvents = [
      // Today's events
      Event(
        title: 'Morning Lecture - Computer Science',
        categoryIds: [Categories.academic.id],
        priority: EventPriority.high,
        startDate: today,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 90,
        repetitionPattern: RepetitionPattern.custom,
        customWeekdays: [1, 3, 5], // Mon, Wed, Fri
        icon: Icons.computer,
        remark: EventRemark.none,
        notes: 'Introduction to Data Structures [SAMPLE_EVENT]',
      ),
      Event(
        title: 'Math Assignment Due',
        categoryIds: [Categories.assignment.id, Categories.academic.id],
        priority: EventPriority.urgent,
        startDate: today,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 17, minute: 0),
        durationMinutes: 60,
        repetitionPattern: RepetitionPattern.none,
        icon: Icons.calculate,
        remark: EventRemark.none,
        notes: 'Complete problems 1-25 from Chapter 5 [SAMPLE_EVENT]',
      ),
      Event(
        title: 'Study Session - Library',
        categoryIds: [Categories.study.id],
        priority: EventPriority.medium,
        startDate: today,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        durationMinutes: 120,
        repetitionPattern: RepetitionPattern.daily,
        icon: Icons.menu_book,
        remark: EventRemark.none,
        notes: '[SAMPLE_EVENT]',
      ),
      Event(
        title: 'Gym Workout',
        categoryIds: [Categories.health.id, Categories.personal.id],
        priority: EventPriority.low,
        startDate: today,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 18, minute: 30),
        durationMinutes: 60,
        repetitionPattern: RepetitionPattern.custom,
        customWeekdays: [1, 3, 5], // Mon, Wed, Fri
        icon: Icons.fitness_center,
        remark: EventRemark.none,
        notes: '[SAMPLE_EVENT]',
      ),
      // Tomorrow's events
      Event(
        title: 'Physics Lab',
        categoryIds: [Categories.academic.id],
        priority: EventPriority.high,
        startDate: today.add(const Duration(days: 1)),
        isAllDay: false,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 180,
        repetitionPattern: RepetitionPattern.weekly,
        icon: Icons.science,
        remark: EventRemark.none,
        notes: 'Lab 5: Optics and Lenses [SAMPLE_EVENT]',
      ),
      Event(
        title: 'Group Project Meeting',
        categoryIds: [Categories.project.id, Categories.social.id],
        priority: EventPriority.high,
        startDate: today.add(const Duration(days: 1)),
        isAllDay: false,
        startTime: const TimeOfDay(hour: 15, minute: 0),
        durationMinutes: 90,
        repetitionPattern: RepetitionPattern.none,
        icon: Icons.people,
        remark: EventRemark.none,
        notes: 'Discuss project timeline and assign tasks [SAMPLE_EVENT]',
      ),
      // Upcoming exam
      Event(
        title: 'Midterm Exam - Database Systems',
        categoryIds: [Categories.exam.id, Categories.academic.id],
        priority: EventPriority.urgent,
        startDate: today.add(const Duration(days: 7)),
        isAllDay: false,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 120,
        repetitionPattern: RepetitionPattern.none,
        icon: Icons.quiz,
        remark: EventRemark.none,
        notes: 'Chapters 1-8, SQL queries, normalization [SAMPLE_EVENT]',
      ),
      // Weekend event
      Event(
        title: 'Movie Night with Friends',
        categoryIds: [Categories.social.id, Categories.personal.id],
        priority: EventPriority.low,
        startDate: today.add(Duration(days: (6 - now.weekday) % 7)),
        isAllDay: false,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        durationMinutes: 180,
        repetitionPattern: RepetitionPattern.none,
        icon: Icons.movie,
        remark: EventRemark.none,
        notes: '[SAMPLE_EVENT]',
      ),
      // All-day event
      Event(
        title: 'Career Fair',
        categoryIds: [Categories.work.id, Categories.academic.id],
        priority: EventPriority.medium,
        startDate: today.add(const Duration(days: 3)),
        isAllDay: true,
        repetitionPattern: RepetitionPattern.none,
        icon: Icons.business_center,
        remark: EventRemark.none,
        notes: 'Bring resume copies, dress professionally [SAMPLE_EVENT]',
      ),
      // Multi-day event
      Event(
        title: 'Spring Break Trip',
        categoryIds: [Categories.personal.id],
        priority: EventPriority.low,
        startDate: today.add(const Duration(days: 14)),
        endDate: today.add(const Duration(days: 21)),
        isAllDay: true,
        repetitionPattern: RepetitionPattern.none,
        icon: Icons.flight,
        remark: EventRemark.none,
        notes: 'Beach resort in Miami [SAMPLE_EVENT]',
      ),
    ];

    // Add all sample events
    for (final event in sampleEvents) {
      await provider.createEvent(event);
    }
  }
}
