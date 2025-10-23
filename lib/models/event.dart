import 'package:flutter/material.dart';
import 'priority.dart';

/// Repetition pattern for recurring events
enum RepetitionPattern {
  none,
  daily,
  weekly,
  custom; // For custom weekly patterns (e.g., Mon, Wed, Fri)

  String get displayName {
    switch (this) {
      case RepetitionPattern.none:
        return 'No Repeat';
      case RepetitionPattern.daily:
        return 'Daily';
      case RepetitionPattern.weekly:
        return 'Weekly';
      case RepetitionPattern.custom:
        return 'Custom';
    }
  }
}

/// Event model with all required properties
class Event {
  final String? id;
  final String title;
  final List<String> categoryIds; // Can belong to multiple categories
  final EventPriority priority;

  // Date and time properties
  final DateTime startDate;
  final DateTime? endDate; // For multi-day events
  final bool isAllDay;
  final TimeOfDay? startTime; // Only if not all-day
  final int? durationMinutes; // Duration in minutes

  // Repetition properties
  final RepetitionPattern repetitionPattern;
  final List<int>? customWeekdays; // 1=Monday, 7=Sunday for custom pattern

  // Visual and metadata
  final IconData icon;
  final String iconCodePoint; // Store for database
  final String? iconFontFamily;

  // Status and notes
  final EventRemark remark;
  final String? notes;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    this.id,
    required this.title,
    required this.categoryIds,
    required this.priority,
    required this.startDate,
    this.endDate,
    required this.isAllDay,
    this.startTime,
    this.durationMinutes,
    required this.repetitionPattern,
    this.customWeekdays,
    required this.icon,
    String? iconCodePoint,
    this.iconFontFamily,
    required this.remark,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : iconCodePoint = iconCodePoint ?? icon.codePoint.toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Check if event occurs on a specific date
  bool occursOnDate(DateTime date) {
    final eventDate = DateTime(startDate.year, startDate.month, startDate.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    // Check if it's a single-day event
    if (repetitionPattern == RepetitionPattern.none) {
      if (endDate == null) {
        return eventDate.isAtSameMomentAs(checkDate);
      } else {
        // Multi-day event
        final eventEndDate = DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
        );
        return (checkDate.isAtSameMomentAs(eventDate) ||
                checkDate.isAfter(eventDate)) &&
            (checkDate.isAtSameMomentAs(eventEndDate) ||
                checkDate.isBefore(eventEndDate));
      }
    }

    // For repeating events, check if date is after start date
    if (checkDate.isBefore(eventDate)) {
      return false;
    }

    // Check repetition pattern
    switch (repetitionPattern) {
      case RepetitionPattern.daily:
        return true;

      case RepetitionPattern.weekly:
        return checkDate.weekday == eventDate.weekday;

      case RepetitionPattern.custom:
        if (customWeekdays == null || customWeekdays!.isEmpty) {
          return false;
        }
        return customWeekdays!.contains(checkDate.weekday);

      case RepetitionPattern.none:
        return false;
    }
  }

  /// Get display time string
  String getTimeString() {
    if (isAllDay) {
      return 'All Day';
    }
    if (startTime == null) {
      return 'No time set';
    }
    final start =
        '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    if (durationMinutes != null && durationMinutes! > 0) {
      final endTime = _addMinutesToTime(startTime!, durationMinutes!);
      final end =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      return '$start - $end';
    }
    return start;
  }

  /// Helper to add minutes to TimeOfDay
  TimeOfDay _addMinutesToTime(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  /// Check if event is happening now
  bool isHappeningNow() {
    final now = DateTime.now();

    if (!occursOnDate(now)) {
      return false;
    }

    if (isAllDay) {
      return true;
    }

    if (startTime == null) {
      return false;
    }

    final currentTime = TimeOfDay.now();
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime!.hour * 60 + startTime!.minute;

    if (durationMinutes != null && durationMinutes! > 0) {
      final endMinutes = startMinutes + durationMinutes!;
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }

    return currentMinutes >= startMinutes;
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categoryIds': categoryIds.join(','),
      'priority': priority.value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isAllDay': isAllDay ? 1 : 0,
      'startTimeHour': startTime?.hour,
      'startTimeMinute': startTime?.minute,
      'durationMinutes': durationMinutes,
      'repetitionPattern': repetitionPattern.index,
      'customWeekdays': customWeekdays?.join(','),
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily ?? 'MaterialIcons',
      'remark': remark.value,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Event.fromMap(Map<String, dynamic> map) {
    TimeOfDay? startTime;
    if (map['startTimeHour'] != null && map['startTimeMinute'] != null) {
      startTime = TimeOfDay(
        hour: map['startTimeHour'] as int,
        minute: map['startTimeMinute'] as int,
      );
    }

    final iconCode = int.tryParse(map['iconCodePoint']?.toString() ?? '');
    final icon = iconCode != null
        ? IconData(
            iconCode,
            fontFamily: map['iconFontFamily'] ?? 'MaterialIcons',
          )
        : Icons.event;

    return Event(
      id: map['id'],
      title: map['title'],
      categoryIds: (map['categoryIds'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      priority: EventPriority.fromValue(map['priority']),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isAllDay: map['isAllDay'] == 1,
      startTime: startTime,
      durationMinutes: map['durationMinutes'],
      repetitionPattern: RepetitionPattern.values[map['repetitionPattern']],
      customWeekdays: map['customWeekdays'] != null
          ? (map['customWeekdays'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .map((s) => int.parse(s))
                .toList()
          : null,
      icon: icon,
      iconCodePoint: map['iconCodePoint'],
      iconFontFamily: map['iconFontFamily'],
      remark: EventRemark.fromValue(map['remark']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Create a copy with updated fields
  Event copyWith({
    String? id,
    String? title,
    List<String>? categoryIds,
    EventPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    TimeOfDay? startTime,
    int? durationMinutes,
    RepetitionPattern? repetitionPattern,
    List<int>? customWeekdays,
    IconData? icon,
    String? iconCodePoint,
    String? iconFontFamily,
    EventRemark? remark,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryIds: categoryIds ?? this.categoryIds,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAllDay: isAllDay ?? this.isAllDay,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      repetitionPattern: repetitionPattern ?? this.repetitionPattern,
      customWeekdays: customWeekdays ?? this.customWeekdays,
      icon: icon ?? this.icon,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      remark: remark ?? this.remark,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
