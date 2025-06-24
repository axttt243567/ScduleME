import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'schedule_section.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'schedule.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        color INTEGER NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        weeklySchedule TEXT NOT NULL,
        percentage INTEGER NOT NULL DEFAULT 0,
        cardDisplayState TEXT NOT NULL DEFAULT 'compact',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // Convert ScheduleItem to Map
  Map<String, dynamic> _routineToMap(ScheduleItem routine) {
    return {
      'id': routine.id,
      'title': routine.title,
      'startTime': routine.startTime,
      'endTime': routine.endTime,
      'color': routine.color.value,
      'description': routine.description,
      'type': routine.type.toString(),
      'isCompleted': routine.isCompleted ? 1 : 0,
      'weeklySchedule': routine.weeklySchedule.join(','),
      'percentage': routine.percentage,
      'cardDisplayState': routine.cardDisplayState.toString(),
      'createdAt':
          routine.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Convert Map to ScheduleItem
  ScheduleItem _mapToRoutine(Map<String, dynamic> map) {
    return ScheduleItem(
      map['title'],
      map['startTime'],
      map['endTime'],
      Color(map['color']),
      map['description'],
      ScheduleType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ScheduleType.routine,
      ),
      map['isCompleted'] == 1,
      map['weeklySchedule'].split(',').map<int>((e) => int.parse(e)).toList(),
      map['percentage'],      CardDisplayState.values.firstWhere(
        (e) => e.toString() == map['cardDisplayState'],
        orElse: () => CardDisplayState.compact,
      ),
      map['id'],
      map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  // Insert a new routine
  Future<int> insertRoutine(ScheduleItem routine) async {
    final db = await database;
    final id = await db.insert('routines', _routineToMap(routine));
    routine.id = id;
    return id;
  }

  // Get all routines
  Future<List<ScheduleItem>> getAllRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines');
    return List.generate(maps.length, (i) => _mapToRoutine(maps[i]));
  }

  // Update a routine
  Future<int> updateRoutine(ScheduleItem routine) async {
    final db = await database;
    return await db.update(
      'routines',
      _routineToMap(routine),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  // Delete a routine
  Future<int> deleteRoutine(int id) async {
    final db = await database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // Get routines for a specific day
  Future<List<ScheduleItem>> getRoutinesForDay(int dayOfWeek) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines');

    return maps
        .map((map) => _mapToRoutine(map))
        .where((routine) => routine.weeklySchedule.contains(dayOfWeek))
        .toList();
  }

  // Delete all routines (for testing purposes)
  Future<void> deleteAllRoutines() async {
    final db = await database;
    await db.delete('routines');
  }
}
