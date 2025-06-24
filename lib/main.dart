import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

enum ScheduleType {
  routine, // Recurring activities (daily, weekly, etc.)
  event, // One-time events
  reminder, // Important reminders
}

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
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.black,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 2,
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
  DateTime _focusedDay =
      DateTime.now(); // Sample schedule data with different types
  final Map<DateTime, List<ScheduleItem>> _schedules = {
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      ScheduleItem(
        'Morning Workout',
        '06:30',
        '07:30',
        Colors.blue[800]!,
        'Gym session - Daily routine',
        ScheduleType.routine,
      ),
      ScheduleItem(
        'Team Standup',
        '09:00',
        '09:30',
        Colors.blue,
        'Daily sync meeting - Mon, Tue, Wed, Thu, Fri',
        ScheduleType.routine,
      ),
      ScheduleItem(
        'Code Review',
        '17:00',
        '18:00',
        Colors.blue[600]!,
        'Review pull requests - Mon, Wed, Fri',
        ScheduleType.routine,
      ),
      ScheduleItem(
        'Call to Mom',
        '19:00',
        '19:30',
        Colors.blue[400]!,
        'Weekly check-in call',
        ScheduleType.event,
      ),
    ],
    DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + 1,
    ): [
      ScheduleItem(
        'Morning Jog',
        '06:00',
        '07:00',
        Colors.blue[800]!,
        'Outdoor exercise - Daily routine',
        ScheduleType.routine,
      ),
      ScheduleItem(
        'Project Planning',
        '09:30',
        '11:00',
        Colors.indigo,
        'Sprint planning meeting',
        ScheduleType.event,
      ),
      ScheduleItem(
        'Lunch Meeting',
        '12:30',
        '13:30',
        Colors.blue[700]!,
        'Business lunch with client',
        ScheduleType.event,
      ),
      ScheduleItem(
        'Development',
        '14:00',
        '17:00',
        Colors.blue[600]!,
        'Feature implementation - Daily routine',
        ScheduleType.routine,
      ),
    ],
    DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 1,
    ): [
      ScheduleItem(
        'Yoga Session',
        '07:00',
        '08:00',
        Colors.blue[500]!,
        'Morning stretch - Daily routine',
        ScheduleType.routine,
      ),
      ScheduleItem(
        'All Hands Meeting',
        '10:00',
        '11:00',
        Colors.blue,
        'Monthly company meeting',
        ScheduleType.event,
      ),
      ScheduleItem(
        '1:1 with Manager',
        '11:30',
        '12:00',
        Colors.blue[600]!,
        'Weekly performance review',
        ScheduleType.routine,
      ),
      ScheduleItem(
        'Dentist Appointment',
        '15:00',
        '16:00',
        Colors.blue[800]!,
        'Annual checkup',
        ScheduleType.event,
      ),
    ],
    DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + 2,
    ): [
      ScheduleItem(
        'Weekend Hike',
        '08:00',
        '12:00',
        Colors.blue[600]!,
        'Nature exploration trip',
        ScheduleType.event,
      ),
      ScheduleItem(
        'Lunch with Friends',
        '13:00',
        '15:00',
        Colors.blue[400]!,
        'Monthly social gathering',
        ScheduleType.event,
      ),
    ],
    // Add some reminders for specific dates
    DateTime(2025, 6, 25): [
      ScheduleItem(
        'Call to Mom',
        '19:00',
        '19:30',
        Colors.blue[400]!,
        'Weekly check-in call',
        ScheduleType.event,
      ),
    ],
    DateTime(2025, 6, 30): [
      ScheduleItem(
        'Room Rent Due',
        '09:00',
        '09:00',
        Colors.blue[700]!,
        'Pay monthly room rent',
        ScheduleType.reminder,
      ),
      ScheduleItem(
        'Monthly Budget Review',
        '20:00',
        '20:30',
        Colors.indigo,
        'Review and plan expenses',
        ScheduleType.reminder,
      ),
    ],
    DateTime(2025, 7, 1): [
      ScheduleItem(
        'Insurance Premium',
        '10:00',
        '10:00',
        Colors.blue[800]!,
        'Pay quarterly insurance premium',
        ScheduleType.reminder,
      ),
    ],
  };
  List<ScheduleItem> _getSchedulesForDay(DateTime day) {
    // Normalize the date to remove time component
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _schedules[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Me'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Weekly Calendar Section
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 0, // Hide event markers
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.grey),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white70),
                weekendStyle: TextStyle(color: Colors.grey),
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
          ),

          // Daily Schedule Timeline
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: _buildScheduleTimeline(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new schedule item
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new schedule - Coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScheduleTimeline() {
    final schedules = _getSchedulesForDay(_selectedDay);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No schedules for this day',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new schedule',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return _buildHorizontalTimeline(schedules);
  }

  Widget _buildHorizontalTimeline(List<ScheduleItem> schedules) {
    if (schedules.isEmpty) return const SizedBox.shrink();

    // Sort schedules by start time
    schedules.sort(
      (a, b) => _parseTime(a.startTime).compareTo(_parseTime(b.startTime)),
    );

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children:
              schedules.asMap().entries.map((entry) {
                final index = entry.key;
                final schedule = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: _buildScheduleCard(schedule, index, schedules.length),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    ScheduleItem schedule,
    int index,
    int totalSchedules,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: schedule.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: schedule.color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getTypeIcon(schedule.type),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: schedule.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeLabel(schedule.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: schedule.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Time chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: schedule.color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: schedule.color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              '${_formatTimeToAmPm(schedule.startTime)} - ${_formatTimeToAmPm(schedule.endTime)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: schedule.color.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            schedule.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  String _formatTimeToAmPm(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _getTypeIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.routine:
        return Icon(Icons.repeat, size: 16, color: Colors.blue[300]);
      case ScheduleType.event:
        return Icon(Icons.event, size: 16, color: Colors.green[300]);
      case ScheduleType.reminder:
        return Icon(
          Icons.notification_important,
          size: 16,
          color: Colors.orange[300],
        );
    }
  }

  String _getTypeLabel(ScheduleType type) {
    switch (type) {
      case ScheduleType.routine:
        return 'ROUTINE';
      case ScheduleType.event:
        return 'EVENT';
      case ScheduleType.reminder:
        return 'REMINDER';
    }
  }
}

class ScheduleItem {
  final String title;
  final String startTime;
  final String endTime;
  final Color color;
  final String description;
  final ScheduleType type;

  ScheduleItem(
    this.title,
    this.startTime,
    this.endTime,
    this.color,
    this.description, [
    this.type = ScheduleType.event,
  ]);
}
