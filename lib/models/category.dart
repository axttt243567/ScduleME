import 'package:flutter/material.dart';

/// Event category model
class EventCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const EventCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  factory EventCategory.fromMap(Map<String, dynamic> map) {
    return EventCategory(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
    );
  }
}

/// Predefined categories
class Categories {
  static const academic = EventCategory(
    id: 'academic',
    name: 'Academic',
    icon: Icons.school,
    color: Color(0xFF00D9FF),
  );

  static const assignment = EventCategory(
    id: 'assignment',
    name: 'Assignment',
    icon: Icons.assignment,
    color: Color(0xFFFF6B9D),
  );

  static const exam = EventCategory(
    id: 'exam',
    name: 'Exam',
    icon: Icons.quiz,
    color: Color(0xFFFF4757),
  );

  static const project = EventCategory(
    id: 'project',
    name: 'Project',
    icon: Icons.business_center,
    color: Color(0xFFFFA502),
  );

  static const study = EventCategory(
    id: 'study',
    name: 'Study',
    icon: Icons.menu_book,
    color: Color(0xFF7B68EE),
  );

  static const personal = EventCategory(
    id: 'personal',
    name: 'Personal',
    icon: Icons.person,
    color: Color(0xFF26DE81),
  );

  static const health = EventCategory(
    id: 'health',
    name: 'Health',
    icon: Icons.favorite,
    color: Color(0xFFF368E0),
  );

  static const social = EventCategory(
    id: 'social',
    name: 'Social',
    icon: Icons.people,
    color: Color(0xFFFFD32A),
  );

  static const work = EventCategory(
    id: 'work',
    name: 'Work',
    icon: Icons.work,
    color: Color(0xFF5F27CD),
  );

  static const other = EventCategory(
    id: 'other',
    name: 'Other',
    icon: Icons.more_horiz,
    color: Color(0xFF747D8C),
  );

  static List<EventCategory> get all => [
    academic,
    assignment,
    exam,
    project,
    study,
    personal,
    health,
    social,
    work,
    other,
  ];

  static EventCategory getById(String id) {
    return all.firstWhere((category) => category.id == id, orElse: () => other);
  }
}
