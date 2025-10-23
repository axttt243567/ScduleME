import 'package:flutter/material.dart';

/// Event priority levels
enum EventPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case EventPriority.low:
        return 'Low';
      case EventPriority.medium:
        return 'Medium';
      case EventPriority.high:
        return 'High';
      case EventPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case EventPriority.low:
        return const Color(0xFF26DE81); // Green
      case EventPriority.medium:
        return const Color(0xFFFFA502); // Orange
      case EventPriority.high:
        return const Color(0xFFFF6B9D); // Pink
      case EventPriority.urgent:
        return const Color(0xFFFF4757); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case EventPriority.low:
        return Icons.arrow_downward;
      case EventPriority.medium:
        return Icons.remove;
      case EventPriority.high:
        return Icons.arrow_upward;
      case EventPriority.urgent:
        return Icons.priority_high;
    }
  }

  int get value {
    switch (this) {
      case EventPriority.low:
        return 0;
      case EventPriority.medium:
        return 1;
      case EventPriority.high:
        return 2;
      case EventPriority.urgent:
        return 3;
    }
  }

  static EventPriority fromValue(int value) {
    switch (value) {
      case 0:
        return EventPriority.low;
      case 1:
        return EventPriority.medium;
      case 2:
        return EventPriority.high;
      case 3:
        return EventPriority.urgent;
      default:
        return EventPriority.medium;
    }
  }
}

/// Event remark status
enum EventRemark {
  none,
  done,
  skip,
  missed;

  String get displayName {
    switch (this) {
      case EventRemark.none:
        return 'None';
      case EventRemark.done:
        return 'Done';
      case EventRemark.skip:
        return 'Skip';
      case EventRemark.missed:
        return 'Missed';
    }
  }

  Color get color {
    switch (this) {
      case EventRemark.none:
        return const Color(0xFF747D8C); // Gray
      case EventRemark.done:
        return const Color(0xFF26DE81); // Green
      case EventRemark.skip:
        return const Color(0xFFFFA502); // Orange
      case EventRemark.missed:
        return const Color(0xFFFF4757); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case EventRemark.none:
        return Icons.radio_button_unchecked;
      case EventRemark.done:
        return Icons.check_circle;
      case EventRemark.skip:
        return Icons.skip_next;
      case EventRemark.missed:
        return Icons.cancel;
    }
  }

  int get value {
    switch (this) {
      case EventRemark.none:
        return 0;
      case EventRemark.done:
        return 1;
      case EventRemark.skip:
        return 2;
      case EventRemark.missed:
        return 3;
    }
  }

  static EventRemark fromValue(int value) {
    switch (value) {
      case 0:
        return EventRemark.none;
      case 1:
        return EventRemark.done;
      case 2:
        return EventRemark.skip;
      case 3:
        return EventRemark.missed;
      default:
        return EventRemark.none;
    }
  }
}
