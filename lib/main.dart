import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_section.dart';
import 'theme_provider.dart';
import 'database_helper.dart';

void main() {
  runApp(const ScheduleApp());
}

class ScheduleApp extends StatefulWidget {
  const ScheduleApp({super.key});

  @override
  State<ScheduleApp> createState() => _ScheduleAppState();
}

class _ScheduleAppState extends State<ScheduleApp> {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _themeProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: _themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ScheduleHomePage(themeProvider: _themeProvider),
    );
  }
}

class ScheduleHomePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ScheduleHomePage({super.key, required this.themeProvider});

  @override
  State<ScheduleHomePage> createState() => _ScheduleHomePageState();
}

class _ScheduleHomePageState extends State<ScheduleHomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<ScheduleItem> _routines = [];
  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final routines = await _databaseHelper.getAllRoutines();
    setState(() {
      _routines = routines;
    });
  }

  Future<void> _addRoutine(ScheduleItem routine) async {
    await _databaseHelper.insertRoutine(routine);
    _loadRoutines();
  }

  Future<void> _updateRoutine(ScheduleItem routine) async {
    await _databaseHelper.updateRoutine(routine);
    _loadRoutines();
  }

  Future<void> _deleteRoutine(ScheduleItem routine) async {
    if (routine.id != null) {
      await _databaseHelper.deleteRoutine(routine.id!);
      _loadRoutines();
    }
  }

  List<ScheduleItem> _getSchedulesForDay(DateTime day) {
    // Get the day of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
    final dayOfWeek = day.weekday % 7; // Convert to 0-6 format where 0=Sunday

    // Filter routines that are scheduled for this day of the week
    return _routines.where((routine) {
      return routine.weeklySchedule.contains(dayOfWeek);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Me'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Weekly Calendar Section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: TableCalendar<ScheduleItem>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.week,
                eventLoader: _getSchedulesForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF007AFF), // iOS blue
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Color(0xFFFF9500), // iOS orange
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 0, // Hide event markers
                  defaultTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  headerMargin: EdgeInsets.zero,
                  headerPadding: EdgeInsets.zero,
                  titleTextStyle: TextStyle(
                    fontSize: 0,
                    height: 0,
                  ), // Hide title
                  leftChevronVisible: false, // Hide left arrow
                  rightChevronVisible: false, // Hide right arrow
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  weekendStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ), // Daily Schedule Timeline
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ), // Reduced horizontal padding
              child: ScheduleSection(
                selectedDay: _selectedDay,
                routines: _routines,
                themeProvider: widget.themeProvider,
                onScheduleUpdated: _updateRoutine,
                onScheduleAdded: _addRoutine,
                onScheduleDeleted: _deleteRoutine,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
