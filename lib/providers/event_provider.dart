import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/priority.dart';
import '../database/database_helper.dart';

/// Provider for managing event state across the app
class EventProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all events from database
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _dbHelper.readAllEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    return _events.where((event) => event.occursOnDate(date)).toList()
      ..sort((a, b) {
        // Sort by all-day first, then by time
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;

        if (!a.isAllDay &&
            !b.isAllDay &&
            a.startTime != null &&
            b.startTime != null) {
          final aMinutes = a.startTime!.hour * 60 + a.startTime!.minute;
          final bMinutes = b.startTime!.hour * 60 + b.startTime!.minute;
          return aMinutes.compareTo(bMinutes);
        }

        return 0;
      });
  }

  /// Get events for a date range
  List<Event> getEventsForDateRange(DateTime start, DateTime end) {
    final eventsInRange = <Event>[];

    for (
      var date = start;
      date.isBefore(end) || date.isAtSameMomentAs(end);
      date = date.add(const Duration(days: 1))
    ) {
      for (var event in _events) {
        if (event.occursOnDate(date) && !eventsInRange.contains(event)) {
          eventsInRange.add(event);
        }
      }
    }

    return eventsInRange;
  }

  /// Get events by category
  List<Event> getEventsByCategory(String categoryId) {
    return _events
        .where((event) => event.categoryIds.contains(categoryId))
        .toList();
  }

  /// Get current happening events
  List<Event> getCurrentEvents() {
    return _events.where((event) => event.isHappeningNow()).toList();
  }

  /// Create a new event
  Future<void> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEvent = await _dbHelper.createEvent(event);
      _events.add(newEvent);
      _events.sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing event
  Future<void> updateEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.updateEvent(event);
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
        _events.sort((a, b) => b.startDate.compareTo(a.startDate));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.deleteEvent(id);
      _events.removeWhere((event) => event.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search events
  Future<List<Event>> searchEvents(String query) async {
    try {
      return await _dbHelper.searchEvents(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Update event remark status
  Future<void> updateEventRemark(
    String eventId,
    EventRemark remark, {
    String? notes,
  }) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    final updatedEvent = event.copyWith(
      remark: remark,
      notes: notes ?? event.notes,
    );
    await updateEvent(updatedEvent);
  }

  /// Clear all data - wipe everything and reset to fresh state
  Future<void> clearAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear database
      await _dbHelper.clearAllData();

      // Clear in-memory events
      _events.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
