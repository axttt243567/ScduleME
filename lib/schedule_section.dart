import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ScheduleType {
  routine, // Recurring activities (daily, weekly, etc.)
}

enum CardDisplayState {
  compact, // Title, time chip, duration chip only
  full, // All features (current implementation)
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
  CardDisplayState cardDisplayState; // Individual card display state

  ScheduleItem(
    this.title,
    this.startTime,
    this.endTime,
    this.color,
    this.description, [
    this.type = ScheduleType.routine,
    this.isCompleted = false,
    this.weeklySchedule = const [],
    this.percentage = 0,
    this.cardDisplayState = CardDisplayState.compact, // Default to compact
  ]);
}

class ScheduleSection extends StatefulWidget {
  final DateTime selectedDay;
  final List<ScheduleItem> routines;
  final Function(ScheduleItem) onScheduleUpdated;

  const ScheduleSection({
    super.key,
    required this.selectedDay,
    required this.routines,
    required this.onScheduleUpdated,
  });

  @override
  State<ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<ScheduleSection> {
  List<ScheduleItem> _getSchedulesForDay(DateTime day) {
    // Get the day of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
    final dayOfWeek = day.weekday % 7; // Convert to 0-6 format where 0=Sunday

    // Filter routines that are scheduled for this day of the week
    return widget.routines.where((routine) {
      return routine.weeklySchedule.contains(dayOfWeek);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 16.0,
      ), // Reduced horizontal padding for wider cards
      child: _buildScheduleTimeline(),
    );
  }

  Widget _buildScheduleTimeline() {
    final schedules = _getSchedulesForDay(widget.selectedDay);

    if (schedules.isEmpty) {
      return Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: const Color(0xFF8E8E93),
                ), // iOS gray
                const SizedBox(height: 16),
                Text(
                  'No routines for this day',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF1C1C1E), // iOS dark text
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add a new routine',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8E8E93), // iOS gray
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Dividing line after empty state
          Container(
            height: 1,
            color: const Color(0xFFE5E5EA), // iOS separator color
            margin: const EdgeInsets.symmetric(horizontal: 0),
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildHorizontalTimeline(schedules),
        const SizedBox(height: 20), // Dividing line after routine cards
        Container(
          height: 1,
          color: const Color(0xFFE5E5EA), // iOS separator color
          margin: const EdgeInsets.symmetric(horizontal: 0),
        ),
        const SizedBox(height: 20), // Space before new section
        _buildActionChipsSection(),
        const SizedBox(height: 20), // Space after new section
        Container(
          height: 1,
          color: const Color(0xFFE5E5EA), // iOS separator color
          margin: const EdgeInsets.symmetric(horizontal: 0),
        ),
      ],
    );
  }

  Widget _buildHorizontalTimeline(List<ScheduleItem> schedules) {
    if (schedules.isEmpty) return const SizedBox.shrink();

    // Sort schedules by start time
    schedules.sort(
      (a, b) => _parseTime(a.startTime).compareTo(_parseTime(b.startTime)),
    );

    return Column(
      children:
          schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: _buildScheduleCard(schedule, index, schedules.length),
            );
          }).toList(),
    );
  }

  Widget _buildScheduleCard(
    ScheduleItem schedule,
    int index,
    int totalSchedules,
  ) {
    return Container(
      width: double.infinity, // Make card take full available width
      padding: const EdgeInsets.all(
        20.0,
      ), // Increased padding for better spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row - always shown
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
                    color: const Color(0xFF1C1C1E), // iOS dark text
                    decoration:
                        schedule.isCompleted &&
                                schedule.cardDisplayState !=
                                    CardDisplayState.compact
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                    decorationColor: const Color(0xFF8E8E93), // iOS gray
                  ),
                ),
              ), // Completion checkbox - only in full state
              if (schedule.cardDisplayState == CardDisplayState.full)
                _buildCompletionCheckbox(schedule),
            ],
          ),
          const SizedBox(height: 8), // Chips row - different based on state
          if (schedule.cardDisplayState == CardDisplayState.compact)
            _buildCompactChipsRow(schedule)
          else
            _buildFullChipsRow(schedule), // Additional content for full state
          if (schedule.cardDisplayState == CardDisplayState.full) ...[
            const SizedBox(height: 12),
            _buildWeeklyIndicator(schedule),
            const SizedBox(height: 8), // Separator line
            Container(
              height: 1,
              color: const Color(0xFFE5E5EA), // iOS separator color
              margin: const EdgeInsets.symmetric(vertical: 8),
            ), // Description
            Text(
              schedule.description,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF8E8E93), // iOS gray
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // New feature chips section
            _buildFeatureChipsSection(schedule),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionCheckbox(ScheduleItem schedule) {
    return GestureDetector(
      onTap: () {
        setState(() {
          schedule.isCompleted = !schedule.isCompleted;
        });
        widget.onScheduleUpdated(schedule);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF007AFF),
            width: 2,
          ), // iOS blue
          color:
              schedule.isCompleted
                  ? const Color(0xFF007AFF)
                  : Colors.transparent,
        ),
        child:
            schedule.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
      ),
    );
  }

  Widget _buildCompactChipsRow(ScheduleItem schedule) {
    return Row(
      children: [
        // Time chip - always shown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(
              0xFF007AFF,
            ).withOpacity(0.1), // iOS blue background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF007AFF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _formatTimeToAmPm(schedule.startTime),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF007AFF), // iOS blue text
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Duration chip - always shown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(
              0xFF34C759,
            ).withOpacity(0.1), // iOS green background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF34C759).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _calculateDuration(schedule.startTime, schedule.endTime),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF34C759), // iOS green text
            ),
          ),
        ), // Spacer to push dropdown toggle to the right
        const Spacer(),

        // Dropdown toggle for compact state
        _buildDropdownToggle(schedule),
      ],
    );
  }

  Widget _buildFullChipsRow(ScheduleItem schedule) {
    return Row(
      children: [
        // Time chip - always shown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(
              0xFF007AFF,
            ).withOpacity(0.1), // iOS blue background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF007AFF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _formatTimeToAmPm(schedule.startTime),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF007AFF), // iOS blue text
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Duration chip - always shown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(
              0xFF34C759,
            ).withOpacity(0.1), // iOS green background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF34C759).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _calculateDuration(schedule.startTime, schedule.endTime),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF34C759), // iOS green text
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Type chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(
              0xFF5856D6,
            ).withOpacity(0.1), // iOS purple background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF5856D6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getTypeLabel(schedule.type),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5856D6), // iOS purple text
            ),
          ),
        ),

        // Circular percentage indicator for routines
        if (schedule.type == ScheduleType.routine) ...[
          const SizedBox(width: 8),
          _buildCircularPercentageIndicator(schedule),
        ],
      ],
    );
  }

  Widget _buildDropdownToggle(ScheduleItem schedule) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            // Cycle between compact and full states
            if (schedule.cardDisplayState == CardDisplayState.compact) {
              schedule.cardDisplayState = CardDisplayState.full;
            } else {
              schedule.cardDisplayState = CardDisplayState.compact;
            }
          });
          widget.onScheduleUpdated(schedule);
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: schedule.color.withOpacity(0.1),
        highlightColor: schedule.color.withOpacity(0.05),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(
              0xFF8E8E93,
            ).withOpacity(0.1), // iOS gray background
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8E8E93).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: AnimatedRotation(
              turns: _getArrowRotation(schedule.cardDisplayState),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: const Color(0xFF8E8E93), // iOS gray
              ),
            ),
          ),
        ),
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
          color: const Color(0xFFE5E5EA), // iOS separator color
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
                        ? const Color(0xFF007AFF) // iOS blue
                        : Colors.transparent,
                border: Border.all(
                  color: const Color(
                    0xFF007AFF,
                  ).withOpacity(0.4), // iOS blue border
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
                            : const Color(0xFF007AFF).withOpacity(0.6),
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
          color: const Color(0xFF007AFF), // iOS blue
        ),
        child: Center(
          child: Text(
            '${schedule.percentage}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF007AFF), // iOS blue
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChipsSection(ScheduleItem schedule) {
    return Column(
      children: [
        // Separator line before feature chips
        Container(
          height: 1,
          color: const Color(0xFFE5E5EA), // iOS separator color
          margin: const EdgeInsets.only(bottom: 12),
        ), // Horizontally scrollable chips
        SizedBox(
          height: 36,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Remind Me chip
                _buildFeatureChip(
                  icon: Icons.notifications_outlined,
                  label: 'Remind Me',
                  color: schedule.color,
                ),
                const SizedBox(width: 8),

                // Flexible Timing chip
                _buildFeatureChip(
                  icon: Icons.schedule_outlined,
                  label: 'Flexible Timing',
                  color: schedule.color,
                ),
                const SizedBox(width: 8),

                // Buffer Time chip
                _buildFeatureChip(
                  icon: Icons.hourglass_empty_outlined,
                  label: 'Buffer Time',
                  color: schedule.color,
                ),
                const SizedBox(width: 8),

                // Habit Formation chip
                _buildFeatureChip(
                  icon: Icons.psychology_outlined,
                  label: 'Habit Formation',
                  color: schedule.color,
                ),

                // Add some spacing before dropdown toggle
                const SizedBox(width: 16),

                // Dropdown toggle at the end
                _buildDropdownToggle(schedule),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    // Define iOS colors for different chip types
    Color chipColor;
    switch (label) {
      case 'Remind Me':
        chipColor = const Color(0xFFFF9500); // iOS orange
        break;
      case 'Flexible Timing':
        chipColor = const Color(0xFF34C759); // iOS green
        break;
      case 'Buffer Time':
        chipColor = const Color(0xFF5856D6); // iOS purple
        break;
      case 'Habit Formation':
        chipColor = const Color(0xFFFF2D92); // iOS pink
        break;
      default:
        chipColor = const Color(0xFF007AFF); // iOS blue
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChipsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C1C1E), // iOS dark text
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionChip(
                icon: Icons.settings_outlined,
                label: 'Settings',
                color: const Color(0xFF8E8E93), // iOS gray
              ),
              _buildActionChip(
                icon: Icons.person_outline,
                label: 'Profile',
                color: const Color(0xFF007AFF), // iOS blue
              ),
              _buildActionChip(
                icon: Icons.repeat,
                label: 'Routine',
                color: const Color(0xFF34C759), // iOS green
              ),
              _buildActionChip(
                icon: Icons.tune_outlined,
                label: 'Customize',
                color: const Color(0xFF5856D6), // iOS purple
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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
        return Icon(
          Icons.repeat,
          size: 16,
          color: const Color(0xFF007AFF),
        ); // iOS blue
    }
  }

  double _getArrowRotation(CardDisplayState state) {
    switch (state) {
      case CardDisplayState.compact:
        return 0.0; // Arrow pointing down
      case CardDisplayState.full:
        return 0.5; // Arrow pointing up (180 degrees)
    }
  }

  String _getTypeLabel(ScheduleType type) {
    switch (type) {
      case ScheduleType.routine:
        return 'ROUTINE';
    }
  }
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
