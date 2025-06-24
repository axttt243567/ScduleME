import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_section.dart';

void main() {
  runApp(const ScheduleApp());
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007AFF), // iOS blue
          secondary: Color(0xFF5856D6), // iOS purple
          surface: Color(0xFFF2F2F7), // iOS light gray
          background: Color(0xFFFFFFFF), // Pure white
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1C1C1E), // iOS dark text
          onBackground: Color(0xFF1C1C1E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          foregroundColor: Color(0xFF1C1C1E),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const ScheduleHomePage(),
    );
  }
}

class ScheduleHomePage extends StatefulWidget {
  const ScheduleHomePage({super.key});

  @override
  State<ScheduleHomePage> createState() => _ScheduleHomePageState();
}

class _ScheduleHomePageState extends State<ScheduleHomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Routines are now stored independently of dates - they repeat based on weeklySchedule
  final List<ScheduleItem> _routines = [
    ScheduleItem(
      'Morning Workout',
      '06:30',
      '07:30',
      Colors.blue[800]!,
      'Gym session - Daily routine',
      ScheduleType.routine,
      false,
      [1, 2, 3, 4, 5], // Monday to Friday
      85, // 85% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Team Standup',
      '09:00',
      '09:30',
      Colors.blue[800]!,
      'Daily sync meeting - Mon, Tue, Wed, Thu, Fri',
      ScheduleType.routine,
      false,
      [1, 2, 3, 4, 5], // Monday to Friday
      92, // 92% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Code Review',
      '17:00',
      '18:00',
      Colors.blue[800]!,
      'Review pull requests - Mon, Wed, Fri',
      ScheduleType.routine,
      false,
      [1, 3, 5], // Monday, Wednesday, Friday
      67, // 67% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Call to Mom',
      '19:00',
      '19:30',
      Colors.blue[800]!,
      'Weekly check-in call',
      ScheduleType.routine,
      false,
      [0], // Sunday only
      75, // Weekly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Morning Jog',
      '06:00',
      '07:00',
      Colors.blue[800]!,
      'Outdoor exercise - Daily routine',
      ScheduleType.routine,
      false,
      [1, 2, 3, 4, 5, 6, 0], // Daily
      78, // 78% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Project Planning',
      '09:30',
      '11:00',
      Colors.blue[800]!,
      'Sprint planning meeting - Weekly routine',
      ScheduleType.routine,
      false,
      [2], // Tuesday only
      60, // Weekly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Lunch Meeting',
      '12:30',
      '13:30',
      Colors.blue[800]!,
      'Business lunch with client - Weekly routine',
      ScheduleType.routine,
      false,
      [2], // Tuesday only
      45, // Weekly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Development',
      '14:00',
      '17:00',
      Colors.blue[800]!,
      'Feature implementation - Daily routine',
      ScheduleType.routine,
      false,
      [1, 2, 3, 4, 5], // Weekdays
      43, // 43% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Yoga Session',
      '07:00',
      '08:00',
      Colors.blue[800]!,
      'Morning stretch - Daily routine',
      ScheduleType.routine,
      false,
      [1, 2, 3, 4, 5, 6, 0], // Daily
      91, // 91% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'All Hands Meeting',
      '10:00',
      '11:00',
      Colors.blue[800]!,
      'Monthly company meeting - Routine',
      ScheduleType.routine,
      false,
      [1], // Monday only
      85, // Monthly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      '1:1 with Manager',
      '11:30',
      '12:00',
      Colors.blue[800]!,
      'Weekly performance review',
      ScheduleType.routine,
      false,
      [1], // Monday only
      55, // 55% progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Weekend Hike',
      '08:00',
      '12:00',
      Colors.blue[800]!,
      'Weekly nature exploration routine',
      ScheduleType.routine,
      false,
      [6], // Saturday only
      80, // Weekly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Lunch with Friends',
      '13:00',
      '15:00',
      Colors.blue[800]!,
      'Weekly social gathering routine',
      ScheduleType.routine,
      false,
      [6], // Saturday only
      65, // Weekly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Room Rent Due',
      '09:00',
      '09:00',
      Colors.blue[800]!,
      'Monthly room rent payment routine',
      ScheduleType.routine,
      false,
      [1], // Monday only
      90, // Monthly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Monthly Budget Review',
      '20:00',
      '20:30',
      Colors.blue[800]!,
      'Monthly expense planning routine',
      ScheduleType.routine,
      false,
      [1], // Monday only
      85, // Monthly routine progress
      CardDisplayState.compact, // Individual card state
    ),
    ScheduleItem(
      'Insurance Premium',
      '10:00',
      '10:00',
      Colors.blue[800]!,
      'Quarterly insurance payment routine',
      ScheduleType.routine,
      false,
      [2], // Tuesday only
      95, // Quarterly routine progress
      CardDisplayState.compact, // Individual card state
    ),
  ];
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
        backgroundColor: const Color(0xFFF2F2F7),
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Weekly Calendar Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF007AFF), // iOS blue
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFFF9500), // iOS orange
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 0, // Hide event markers
                  defaultTextStyle: TextStyle(
                    color: Color(0xFF1C1C1E), // iOS dark text
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Color(0xFF8E8E93), // iOS gray
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
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Color(0xFF8E8E93), // iOS gray
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  weekendStyle: TextStyle(
                    color: Color(0xFF8E8E93), // iOS gray
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
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
                onScheduleUpdated: (schedule) {
                  setState(() {
                    // Update the schedule item in the list
                    final index = _routines.indexWhere(
                      (item) => item.title == schedule.title,
                    );
                    if (index != -1) {
                      _routines[index] = schedule;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
