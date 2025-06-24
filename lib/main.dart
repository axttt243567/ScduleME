import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;

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
        false,
        [1, 2, 3, 4, 5], // Monday to Friday
        85, // 85% progress
      ),
      ScheduleItem(
        'Team Standup',
        '09:00',
        '09:30',
        Colors.blue,
        'Daily sync meeting - Mon, Tue, Wed, Thu, Fri',
        ScheduleType.routine,
        false,
        [1, 2, 3, 4, 5], // Monday to Friday
        92, // 92% progress
      ),
      ScheduleItem(
        'Code Review',
        '17:00',
        '18:00',
        Colors.blue[600]!,
        'Review pull requests - Mon, Wed, Fri',
        ScheduleType.routine,
        false,
        [1, 3, 5], // Monday, Wednesday, Friday
        67, // 67% progress
      ),
      ScheduleItem(
        'Call to Mom',
        '19:00',
        '19:30',
        Colors.blue[400]!,
        'Weekly check-in call',
        ScheduleType.event,
        false,
        [0], // Sunday only
        0, // Not a routine, no progress
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
        false,
        [1, 2, 3, 4, 5, 6, 0], // Daily
        78, // 78% progress
      ),
      ScheduleItem(
        'Project Planning',
        '09:30',
        '11:00',
        Colors.indigo,
        'Sprint planning meeting',
        ScheduleType.event,
        false,
        [2], // Tuesday only
        0, // Not a routine, no progress
      ),
      ScheduleItem(
        'Lunch Meeting',
        '12:30',
        '13:30',
        Colors.blue[700]!,
        'Business lunch with client',
        ScheduleType.event,
        false,
        [2], // Tuesday only
        0, // Not a routine, no progress
      ),
      ScheduleItem(
        'Development',
        '14:00',
        '17:00',
        Colors.blue[600]!,
        'Feature implementation - Daily routine',
        ScheduleType.routine,
        false,
        [1, 2, 3, 4, 5], // Weekdays
        43, // 43% progress
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
        false,
        [1, 2, 3, 4, 5, 6, 0], // Daily
        91, // 91% progress
      ),
      ScheduleItem(
        'All Hands Meeting',
        '10:00',
        '11:00',
        Colors.blue,
        'Monthly company meeting',
        ScheduleType.event,
        false,
        [1], // Monday only
        0, // Not a routine, no progress
      ),
      ScheduleItem(
        '1:1 with Manager',
        '11:30',
        '12:00',
        Colors.blue[600]!,
        'Weekly performance review',
        ScheduleType.routine,
        false,
        [1], // Monday only
        55, // 55% progress
      ),
      ScheduleItem(
        'Dentist Appointment',
        '15:00',
        '16:00',
        Colors.blue[800]!,
        'Annual checkup',
        ScheduleType.event,
        false,
        [1], // Monday only
        0, // Not a routine, no progress
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
        false,
        [6], // Saturday only
        0, // Not a routine, no progress
      ),
      ScheduleItem(
        'Lunch with Friends',
        '13:00',
        '15:00',
        Colors.blue[400]!,
        'Monthly social gathering',
        ScheduleType.event,
        false,
        [6], // Saturday only
        0, // Not a routine, no progress
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
        false,
        [0], // Sunday only
        0, // Not a routine, no progress
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
        false,
        [1], // Monday only
        0, // Not a routine, no progress
      ),
      ScheduleItem(
        'Monthly Budget Review',
        '20:00',
        '20:30',
        Colors.indigo,
        'Review and plan expenses',
        ScheduleType.reminder,
        false,
        [1], // Monday only
        0, // Not a routine, no progress
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
        false,
        [2], // Tuesday only
        0, // Not a routine, no progress
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration:
                        schedule.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                    decorationColor: Colors.grey,
                  ),
                ),
              ), // Completion checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    schedule.isCompleted = !schedule.isCompleted;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: schedule.color.withOpacity(0.6),
                      width: 2,
                    ),
                    color:
                        schedule.isCompleted
                            ? schedule.color
                            : Colors.transparent,
                  ),
                  child:
                      schedule.isCompleted
                          ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Time, Duration, and Type chips row
          Row(
            children: [
              // Time chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: schedule.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: schedule.color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _formatTimeToAmPm(schedule.startTime),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: schedule.color.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Duration chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: schedule.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: schedule.color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _calculateDuration(schedule.startTime, schedule.endTime),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: schedule.color.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Type chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: schedule.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: schedule.color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getTypeLabel(schedule.type),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: schedule.color.withOpacity(0.9),
                  ),
                ),
              ),
              // Circular percentage indicator for routines
              if (schedule.type == ScheduleType.routine) ...[
                const SizedBox(width: 8),
                _buildCircularPercentageIndicator(schedule),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Weekly indicator - dividing line with day circles
          _buildWeeklyIndicator(schedule),
          const SizedBox(height: 8),
          // Separator line
          Container(
            height: 1,
            color: schedule.color.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          Text(
            schedule.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyIndicator(ScheduleItem schedule) {
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        // Dividing line
        Container(
          height: 1,
          color: schedule.color.withOpacity(0.2),
          margin: const EdgeInsets.only(bottom: 8),
        ),
        // Weekly day circles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isScheduled = schedule.weeklySchedule.contains(index);
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isScheduled
                        ? schedule.color.withOpacity(0.8)
                        : Colors.transparent,
                border: Border.all(
                  color: schedule.color.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isScheduled
                            ? Colors.white
                            : schedule.color.withOpacity(0.6),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCircularPercentageIndicator(ScheduleItem schedule) {
    return Container(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: CircularPercentagePainter(
          percentage: schedule.percentage.toDouble(),
          color: schedule.color,
        ),
        child: Center(
          child: Text(
            '${schedule.percentage}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: schedule.color.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  String _calculateDuration(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    final durationMinutes = endMinutes - startMinutes;

    if (durationMinutes <= 0) return '0 min';

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
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
  final List<int> weeklySchedule; // 0=Sunday, 1=Monday, ..., 6=Saturday
  final int percentage; // Progress percentage (0-100) for routines
  bool isCompleted;

  ScheduleItem(
    this.title,
    this.startTime,
    this.endTime,
    this.color,
    this.description, [
    this.type = ScheduleType.event,
    this.isCompleted = false,
    this.weeklySchedule = const [],
    this.percentage = 0,
  ]);
}

class CircularPercentagePainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircularPercentagePainter({required this.percentage, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 2.5;
    final radius = (size.width - strokeWidth) / 2;
    final center = size.center(Offset.zero);

    // Background circle (border)
    final backgroundPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (percentage > 0) {
      final progressPaint =
          Paint()
            ..color = color.withOpacity(0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * (percentage / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start at top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
