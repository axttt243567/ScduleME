import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';

/// Database helper for event management
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const nullableIntType = 'INTEGER';
    const nullableTextType = 'TEXT';

    await db.execute('''
      CREATE TABLE events (
        id $idType,
        title $textType,
        categoryIds $textType,
        priority $intType,
        startDate $textType,
        endDate $nullableTextType,
        isAllDay $intType,
        startTimeHour $nullableIntType,
        startTimeMinute $nullableIntType,
        durationMinutes $nullableIntType,
        repetitionPattern $intType,
        customWeekdays $nullableTextType,
        iconCodePoint $textType,
        iconFontFamily $textType,
        remark $intType,
        notes $nullableTextType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_startDate ON events(startDate)');
    await db.execute('CREATE INDEX idx_priority ON events(priority)');
    await db.execute('CREATE INDEX idx_remark ON events(remark)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here if schema changes in future
  }

  /// Create a new event
  Future<Event> createEvent(Event event) async {
    final db = await instance.database;

    // Generate ID if not provided
    final id = event.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final eventWithId = event.copyWith(id: id);

    await db.insert('events', eventWithId.toMap());
    return eventWithId;
  }

  /// Read event by ID
  Future<Event?> readEvent(String id) async {
    final db = await instance.database;

    final maps = await db.query('events', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      return null;
    }

    return Event.fromMap(maps.first);
  }

  /// Read all events
  Future<List<Event>> readAllEvents() async {
    final db = await instance.database;

    const orderBy = 'startDate DESC, startTimeHour ASC, startTimeMinute ASC';
    final result = await db.query('events', orderBy: orderBy);

    return result.map((map) => Event.fromMap(map)).toList();
  }

  /// Read events for a specific date
  Future<List<Event>> readEventsForDate(DateTime date) async {
    // Get all events and filter using occursOnDate method
    final allEvents = await readAllEvents();

    return allEvents.where((event) => event.occursOnDate(date)).toList()
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

  /// Read events for a date range
  Future<List<Event>> readEventsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEvents = await readAllEvents();
    final eventsInRange = <Event>[];

    // Check each day in the range
    for (
      var date = start;
      date.isBefore(end) || date.isAtSameMomentAs(end);
      date = date.add(const Duration(days: 1))
    ) {
      for (var event in allEvents) {
        if (event.occursOnDate(date) && !eventsInRange.contains(event)) {
          eventsInRange.add(event);
        }
      }
    }

    return eventsInRange;
  }

  /// Read events by category
  Future<List<Event>> readEventsByCategory(String categoryId) async {
    final allEvents = await readAllEvents();

    return allEvents
        .where((event) => event.categoryIds.contains(categoryId))
        .toList();
  }

  /// Read events by priority
  Future<List<Event>> readEventsByPriority(int priority) async {
    final db = await instance.database;

    final result = await db.query(
      'events',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'startDate DESC',
    );

    return result.map((map) => Event.fromMap(map)).toList();
  }

  /// Read events by remark status
  Future<List<Event>> readEventsByRemark(int remark) async {
    final db = await instance.database;

    final result = await db.query(
      'events',
      where: 'remark = ?',
      whereArgs: [remark],
      orderBy: 'startDate DESC',
    );

    return result.map((map) => Event.fromMap(map)).toList();
  }

  /// Update an event
  Future<int> updateEvent(Event event) async {
    final db = await instance.database;

    final updatedEvent = event.copyWith(updatedAt: DateTime.now());

    return db.update(
      'events',
      updatedEvent.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Delete an event
  Future<int> deleteEvent(String id) async {
    final db = await instance.database;

    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all events
  Future<int> deleteAllEvents() async {
    final db = await instance.database;
    return await db.delete('events');
  }

  /// Search events by title
  Future<List<Event>> searchEvents(String query) async {
    final db = await instance.database;

    final result = await db.query(
      'events',
      where: 'title LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'startDate DESC',
    );

    return result.map((map) => Event.fromMap(map)).toList();
  }

  /// Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
