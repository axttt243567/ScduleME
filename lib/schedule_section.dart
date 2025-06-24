import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'theme_provider.dart';

enum ScheduleType {
  routine, // Recurring activities (daily, weekly, etc.)
}

enum CardDisplayState {
  compact, // Title, time chip, duration chip only
  full, // All features (current implementation)
}

class ScheduleItem {
  int? id; // Database ID
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
  final DateTime? createdAt;

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
    this.id,
    this.createdAt,
  ]);
}

class ScheduleSection extends StatefulWidget {
  final DateTime selectedDay;
  final List<ScheduleItem> routines;
  final ThemeProvider themeProvider;
  final Function(ScheduleItem) onScheduleUpdated;
  final Function(ScheduleItem) onScheduleAdded;
  final Function(ScheduleItem) onScheduleDeleted;

  const ScheduleSection({
    super.key,
    required this.selectedDay,
    required this.routines,
    required this.themeProvider,
    required this.onScheduleUpdated,
    required this.onScheduleAdded,
    required this.onScheduleDeleted,
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
                  'Create your first routine to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8E8E93), // iOS gray
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateRoutineBottomSheet(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Routine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.add_circle_outline,
                  label: 'Create Routine',
                  color: const Color(0xFF007AFF), // iOS blue
                  onTap: () => _showCreateRoutineBottomSheet(context),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  color: const Color(0xFF8E8E93), // iOS gray
                  onTap: () => _showSettingsBottomSheet(context),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  color: const Color(0xFF34C759), // iOS green
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.repeat,
                  label: 'Manage Routines',
                  color: const Color(0xFF5856D6), // iOS purple
                  onTap: () => _showRoutineManagementBottomSheet(context),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.tune_outlined,
                  label: 'Customize',
                  color: const Color(0xFF5856D6), // iOS purple
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.info_outline,
                  label: 'About Us',
                  color: const Color(0xFFFF9500), // iOS orange
                  onTap: () => _showAboutUsDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D1D6), // iOS gray
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Settings',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E), // iOS dark text
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Scrollable content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Settings options
                            _buildSettingsOption(
                              context: context,
                              icon: Icons.palette_outlined,
                              title: 'Theme Setting',
                              subtitle: 'Customize app appearance',
                              onTap: () {
                                Navigator.pop(context);
                                _showThemeSettingsBottomSheet(context);
                              },
                            ),

                            _buildSettingsOption(
                              context: context,
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              subtitle: 'Manage alerts and reminders',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to notification settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notification Settings coming soon!',
                                    ),
                                    backgroundColor: Color(0xFF007AFF),
                                  ),
                                );
                              },
                            ),

                            _buildSettingsOption(
                              context: context,
                              icon: Icons.schedule_outlined,
                              title: 'Default Times',
                              subtitle: 'Set default routine durations',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to default times settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Default Times Settings coming soon!',
                                    ),
                                    backgroundColor: Color(0xFF007AFF),
                                  ),
                                );
                              },
                            ),

                            _buildSettingsOption(
                              context: context,
                              icon: Icons.sync_outlined,
                              title: 'Sync & Backup',
                              subtitle: 'Cloud sync and data backup',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to sync settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sync & Backup Settings coming soon!',
                                    ),
                                    backgroundColor: Color(0xFF007AFF),
                                  ),
                                );
                              },
                            ),
                            _buildSettingsOption(
                              context: context,
                              icon: Icons.api_outlined,
                              title: 'API Settings',
                              subtitle: 'Configure API keys and endpoints',
                              onTap: () {
                                Navigator.pop(context);
                                _showApiSettingsBottomSheet(context);
                              },
                            ),

                            _buildSettingsOption(
                              context: context,
                              icon: Icons.access_time_outlined,
                              title: 'Time Zone',
                              subtitle: 'Configure time zone settings',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to timezone settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Time Zone Settings coming soon!',
                                    ),
                                    backgroundColor: Color(0xFF007AFF),
                                  ),
                                );
                              },
                            ),

                            _buildSettingsOption(
                              context: context,
                              icon: Icons.security_outlined,
                              title: 'Privacy & Security',
                              subtitle: 'App lock and privacy settings',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to privacy settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Privacy & Security Settings coming soon!',
                                    ),
                                    backgroundColor: Color(0xFF007AFF),
                                  ),
                                );
                              },
                            ),

                            _buildSettingsOption(
                              context: context,
                              icon: Icons.storage_outlined,
                              title: 'Storage',
                              subtitle: 'Manage app data and cache',
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Navigate to storage settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Storage Settings coming soon!',
                                    ),
                                    backgroundColor: Color(0xFF007AFF),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildSettingsOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF007AFF), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 20),
          ],
        ),
      ),
    );
  }

  void _showThemeSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: ThemeProvider.getCardColor(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeProvider.getSecondaryTextColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showSettingsBottomSheet(context);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ThemeProvider.getSecondaryTextColor(
                              context,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: ThemeProvider.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Theme Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeProvider.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24), // Light theme option
                _buildThemeOption(
                  context: context,
                  icon: Icons.light_mode_outlined,
                  title: 'Light Mode',
                  subtitle: 'Clean and bright interface',
                  isSelected: !widget.themeProvider.isDarkMode,
                  onTap: () {
                    if (widget.themeProvider.isDarkMode) {
                      widget.themeProvider.toggleTheme();
                      // Add a small delay to show the theme change
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                ),

                // Dark theme option
                _buildThemeOption(
                  context: context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Easier on the eyes in low light',
                  isSelected: widget.themeProvider.isDarkMode,
                  onTap: () {
                    if (!widget.themeProvider.isDarkMode) {
                      widget.themeProvider
                          .toggleTheme(); // Add a small delay to show the theme change
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF007AFF).withOpacity(0.1)
                        : ThemeProvider.getSecondaryTextColor(
                          context,
                        ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    isSelected
                        ? const Color(0xFF007AFF)
                        : ThemeProvider.getSecondaryTextColor(context),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeProvider.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF007AFF), size: 20)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: ThemeProvider.getSecondaryTextColor(context),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showAboutUsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: ThemeProvider.getCardColor(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ThemeProvider.getSecondaryTextColor(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scrollable content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            // App icon or logo placeholder
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF007AFF,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.schedule,
                                  size: 40,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // App name
                            Center(
                              child: Text(
                                'ScheduleMe',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeProvider.getTextColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Version
                            Center(
                              child: Text(
                                'Version 1.7.0',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeProvider.getSecondaryTextColor(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // About section
                            Text(
                              'About',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              'ScheduleMe is a beautiful and intuitive scheduling app designed to help you manage your daily routines and stay organized. Built with modern iOS design principles, it offers a seamless experience for tracking your habits, managing your time, and achieving your goals.',
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeProvider.getTextColor(context),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Features section
                            Text(
                              'Features',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildFeatureItem(
                              context,
                              Icons.repeat,
                              'Smart Routines',
                              'Create and manage recurring activities with flexible scheduling',
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.palette_outlined,
                              'Beautiful Themes',
                              'Switch between light and dark modes with iOS-style design',
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.analytics_outlined,
                              'Progress Tracking',
                              'Monitor your habit completion and track your progress',
                            ),
                            _buildFeatureItem(
                              context,
                              Icons.notifications_outlined,
                              'Smart Reminders',
                              'Never miss your routines with intelligent notifications',
                            ),

                            const SizedBox(height: 32),

                            // Close button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007AFF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Got it',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF007AFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeProvider.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeProvider.getSecondaryTextColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRoutineManagementBottomSheet(BuildContext context) {
    int selectedDayIndex =
        DateTime.now().weekday % 7; // 0=Sunday, 1=Monday, etc.

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.6,
                  maxChildSize: 0.95,
                  expand: false,
                  builder:
                      (context, scrollController) => Container(
                        decoration: BoxDecoration(
                          color: ThemeProvider.getCardColor(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Handle bar
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: ThemeProvider.getSecondaryTextColor(
                                  context,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 24,
                                    color: const Color(0xFF34C759),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Routine Management',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeProvider.getTextColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color:
                                            ThemeProvider.getSecondaryTextColor(
                                              context,
                                            ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color:
                                            ThemeProvider.getSecondaryTextColor(
                                              context,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Weekly Calendar
                            _buildWeeklyCalendar(context, selectedDayIndex, (
                              dayIndex,
                            ) {
                              setState(() {
                                selectedDayIndex = dayIndex;
                              });
                            }),

                            const SizedBox(height: 20),
                            // Day's Routines Section
                            Expanded(
                              child: _buildDayRoutinesSection(
                                context,
                                selectedDayIndex,
                                scrollController,
                                setState,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
          ),
    );
  }

  Widget _buildWeeklyCalendar(
    BuildContext context,
    int selectedDayIndex,
    Function(int) onDaySelected,
  ) {
    final dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = DateTime.now().weekday % 7; // Current day index

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == selectedDayIndex;
          final isToday = index == today;
          final routinesCount =
              widget.routines
                  .where((routine) => routine.weeklySchedule.contains(index))
                  .length;

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: Container(
              width: 42,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF34C759)
                        : isToday
                        ? const Color(0xFF34C759).withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border:
                    isToday && !isSelected
                        ? Border.all(color: const Color(0xFF34C759), width: 1)
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white
                              : isToday
                              ? const Color(0xFF34C759)
                              : ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (routinesCount > 0)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.3)
                                : const Color(0xFF34C759).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          '$routinesCount',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF34C759),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : ThemeProvider.getSecondaryTextColor(
                                    context,
                                  ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayRoutinesSection(
    BuildContext context,
    int selectedDayIndex,
    ScrollController scrollController,
    StateSetter setModalState,
  ) {
    final dayLabels = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final dayRoutines =
        widget.routines
            .where(
              (routine) => routine.weeklySchedule.contains(selectedDayIndex),
            )
            .toList();

    // Sort routines by start time
    dayRoutines.sort(
      (a, b) => _parseTime(a.startTime).compareTo(_parseTime(b.startTime)),
    );

    return Column(
      children: [
        // Day Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${dayLabels[selectedDayIndex]} Routines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeProvider.getTextColor(context),
                  ),
                ),
              ),
              Text(
                '${dayRoutines.length} routine${dayRoutines.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeProvider.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // Routines List
        Expanded(
          child:
              dayRoutines.isEmpty
                  ? _buildEmptyRoutinesState(
                    context,
                    dayLabels[selectedDayIndex],
                  )
                  : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: dayRoutines.length,
                    itemBuilder: (context, index) {
                      return _buildRoutinePreviewCard(
                        context,
                        dayRoutines[index],
                        index,
                        setModalState,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyRoutinesState(BuildContext context, String dayName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: ThemeProvider.getSecondaryTextColor(
              context,
            ).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No routines for $dayName',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeProvider.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a routine to get started',
            style: TextStyle(
              fontSize: 14,
              color: ThemeProvider.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add routine
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add routine feature coming soon!'),
                  backgroundColor: Color(0xFF34C759),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Routine'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinePreviewCard(
    BuildContext context,
    ScheduleItem routine,
    int index,
    StateSetter setModalState,
  ) {
    bool isExpanded = routine.cardDisplayState == CardDisplayState.full;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        routine.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeProvider.getTextColor(context),
                        ),
                      ),
                    ),
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${routine.percentage}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF34C759),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Use the setState from StatefulBuilder to update the bottom sheet
                        setModalState(() {
                          routine.cardDisplayState =
                              isExpanded
                                  ? CardDisplayState.compact
                                  : CardDisplayState.full;
                        });
                        // Also update the main widget state
                        widget.onScheduleUpdated(routine);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: ThemeProvider.getSecondaryTextColor(
                            context,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: ThemeProvider.getSecondaryTextColor(
                                context,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Time and duration chips
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.access_time,
                      _formatTimeToAmPm(routine.startTime),
                      const Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      Icons.timelapse,
                      _calculateDuration(routine.startTime, routine.endTime),
                      const Color(0xFF34C759),
                    ),
                  ],
                ),

                // Expanded content
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: ThemeProvider.getSecondaryTextColor(
                      context,
                    ).withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    routine.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeProvider.getSecondaryTextColor(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weekly schedule indicator
                  _buildMiniWeeklyIndicator(context, routine),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildIconActionButton(
                          context,
                          Icons.edit_outlined,
                          const Color(0xFF007AFF),
                          'Edit routine',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Edit routine feature coming soon!',
                                ),
                                backgroundColor: Color(0xFF007AFF),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildIconActionButton(
                          context,
                          Icons.delete_outline,
                          const Color(0xFFFF3B30),
                          'Delete routine',
                          () {
                            _showDeleteRoutineDialog(context, routine);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniWeeklyIndicator(BuildContext context, ScheduleItem routine) {
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Schedule',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (index) {
            final isScheduled = routine.weeklySchedule.contains(index);
            return Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isScheduled ? const Color(0xFF34C759) : Colors.transparent,
                border: Border.all(
                  color:
                      isScheduled
                          ? const Color(0xFF34C759)
                          : ThemeProvider.getSecondaryTextColor(
                            context,
                          ).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color:
                        isScheduled
                            ? Colors.white
                            : ThemeProvider.getSecondaryTextColor(context),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildIconActionButton(
    BuildContext context,
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Center(child: Icon(icon, size: 20, color: color)),
      ),
    );
  }

  void _showDeleteRoutineDialog(BuildContext context, ScheduleItem routine) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: ThemeProvider.getCardColor(context),
            title: Text(
              'Delete Routine',
              style: TextStyle(color: ThemeProvider.getTextColor(context)),
            ),
            content: Text(
              'Are you sure you want to delete "${routine.title}"? This action cannot be undone.',
              style: TextStyle(
                color: ThemeProvider.getSecondaryTextColor(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: ThemeProvider.getSecondaryTextColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onScheduleDeleted(routine);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Routine "${routine.title}" deleted'),
                      backgroundColor: const Color(0xFFFF3B30),
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFFF3B30)),
                ),
              ),
            ],
          ),
    );
  }

  // Create Routine Bottom Sheet
  void _showCreateRoutineBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CreateRoutineBottomSheet(
            onRoutineCreated: (routine) {
              widget.onScheduleAdded(routine);
              Navigator.pop(context);
            },
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
  void _showApiSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ThemeProvider.getCardColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeProvider.getSecondaryTextColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: ThemeProvider.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'API Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 32), // Balance the back button
                ],
              ),
            ),
            const SizedBox(height: 24),

            // API Key Management
            _buildApiKeyOption(
              context: context,
              icon: Icons.vpn_key_outlined,
              title: 'Manage API Keys',
              subtitle: 'Add, edit, and select your API keys (up to 5)',
              onTap: () => _showApiKeyManagementBottomSheet(context),
            ),

            // AI Model Selection
            _buildApiKeyOption(
              context: context,
              icon: Icons.psychology_outlined,
              title: 'AI Model Settings',
              subtitle: 'Choose AI models for different tasks',
              onTap: () => _showAiModelSelectionBottomSheet(context),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 24, color: const Color(0xFF007AFF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeProvider.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ThemeProvider.getSecondaryTextColor(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeyManagementBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ThemeProvider.getCardColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeProvider.getSecondaryTextColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: ThemeProvider.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'API Keys',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAddApiKeyDialog(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // API Keys List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Example API Keys (you can load these from shared preferences)
                  _buildApiKeyCard(
                    context: context,
                    name: 'OpenAI GPT-4',
                    provider: 'OpenAI',
                    isActive: true,
                    onTap: () {
                      // Set as active key
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API Key activated'),
                          backgroundColor: Color(0xFF34C759),
                        ),
                      );
                    },
                    onEdit: () => _showEditApiKeyDialog(context, 'OpenAI GPT-4'),
                    onDelete: () => _showDeleteConfirmation(context, 'OpenAI GPT-4'),
                  ),
                  const SizedBox(height: 12),
                  
                  // Empty state when no keys
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.vpn_key_outlined,
                          size: 48,
                          color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No API Keys Added',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeProvider.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first API key to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeProvider.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddApiKeyDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add API Key'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyCard({
    required BuildContext context,
    required String name,
    required String provider,
    required bool isActive,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF007AFF).withOpacity(0.1)
              : ThemeProvider.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF007AFF).withOpacity(0.2)
                : ThemeProvider.getSecondaryTextColor(context).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Provider Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.api,
                size: 20,
                color: Color(0xFF007AFF),
              ),
            ),
            const SizedBox(width: 12),

            // Key Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeProvider.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              children: [
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: ThemeProvider.getSecondaryTextColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAiModelSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: ThemeProvider.getCardColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeProvider.getSecondaryTextColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: ThemeProvider.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'AI Models',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.getTextColor(context),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Model Selection Cards
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildModelSelectionCard(
                      context: context,
                      title: 'Text Generation',
                      description: 'For creating routine descriptions and suggestions',
                      currentModel: 'GPT-4',
                      icon: Icons.text_fields_outlined,
                      color: const Color(0xFF007AFF),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Model selection coming soon!'),
                            backgroundColor: Color(0xFF007AFF),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModelSelectionCard(
                      context: context,
                      title: 'Schedule Optimization',
                      description: 'For optimizing your daily schedule',
                      currentModel: 'GPT-4',
                      icon: Icons.auto_awesome_outlined,
                      color: const Color(0xFF34C759),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Model selection coming soon!'),
                            backgroundColor: Color(0xFF34C759),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModelSelectionCard(
                      context: context,
                      title: 'Habit Analysis',
                      description: 'For analyzing and improving your habits',
                      currentModel: 'GPT-4',
                      icon: Icons.psychology_outlined,
                      color: const Color(0xFF5856D6),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Model selection coming soon!'),
                            backgroundColor: Color(0xFF5856D6),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelectionCard({
    required BuildContext context,
    required String title,
    required String description,
    required String currentModel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeProvider.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeProvider.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Current: $currentModel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ThemeProvider.getSecondaryTextColor(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddApiKeyDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController apiKeyController = TextEditingController();
    bool isLoading = false;
    bool obscureText = true;
    String selectedProvider = 'OpenAI';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: ThemeProvider.getCardColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeProvider.getSecondaryTextColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: ThemeProvider.getSecondaryTextColor(context),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Add API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.getTextColor(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: isLoading ? null : () {
                        if (nameController.text.trim().isEmpty ||
                            apiKeyController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              backgroundColor: Color(0xFFFF3B30),
                            ),
                          );
                          return;
                        }
                        
                        setState(() => isLoading = true);
                        
                        // TODO: Save API key to shared preferences
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('API Key saved successfully!'),
                              backgroundColor: Color(0xFF34C759),
                            ),
                          );
                        });
                      },
                      child: Text(
                        isLoading ? 'Saving...' : 'Save',
                        style: TextStyle(
                          color: isLoading ? 
                            ThemeProvider.getSecondaryTextColor(context) : 
                            const Color(0xFF007AFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider selection
                    Text(
                      'Provider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeProvider.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedProvider,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['OpenAI', 'Anthropic', 'Google', 'Custom'].map((provider) {
                          return DropdownMenuItem(
                            value: provider,
                            child: Text(provider),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedProvider = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name field
                    Text(
                      'Display Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeProvider.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., My OpenAI Key',
                        filled: true,
                        fillColor: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // API Key field
                    Text(
                      'API Key',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeProvider.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: apiKeyController,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: 'Paste your API key here',
                        filled: true,
                        fillColor: ThemeProvider.getSecondaryTextColor(context).withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscureText = !obscureText),
                          icon: Icon(
                            obscureText ? Icons.visibility : Icons.visibility_off,
                            color: ThemeProvider.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditApiKeyDialog(BuildContext context, String keyName) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit API Key feature coming soon!'),
        backgroundColor: Color(0xFF007AFF),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String keyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeProvider.getCardColor(context),
        title: Text(
          'Delete API Key',
          style: TextStyle(color: ThemeProvider.getTextColor(context)),
        ),
        content: Text(
          'Are you sure you want to delete "$keyName"? This action cannot be undone.',
          style: TextStyle(
            color: ThemeProvider.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeProvider.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('API Key "$keyName" deleted'),
                  backgroundColor: const Color(0xFFFF3B30),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
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

class _CreateRoutineBottomSheet extends StatefulWidget {
  final Function(ScheduleItem) onRoutineCreated;

  const _CreateRoutineBottomSheet({required this.onRoutineCreated});

  @override
  State<_CreateRoutineBottomSheet> createState() =>
      _CreateRoutineBottomSheetState();
}

class _CreateRoutineBottomSheetState extends State<_CreateRoutineBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour + 1,
  );
  Color _selectedColor = const Color(0xFF007AFF);
  List<int> _selectedDays = [];
  bool _isLoading = false;

  final List<Color> _colorOptions = [
    const Color(0xFF007AFF), // iOS blue
    const Color(0xFF34C759), // iOS green
    const Color(0xFFFF9500), // iOS orange
    const Color(0xFFFF3B30), // iOS red
    const Color(0xFF5856D6), // iOS purple
    const Color(0xFFFF2D92), // iOS pink
    const Color(0xFF8E8E93), // iOS gray
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E8E93),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'New Routine',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _saveRoutine,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color:
                                _isLoading
                                    ? const Color(0xFF8E8E93)
                                    : const Color(0xFF007AFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Title section
                      _buildSectionTitle('Title'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Enter routine title',
                        maxLines: 1,
                      ),
                      const SizedBox(height: 24),

                      // Description section
                      _buildSectionTitle('Description'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Enter routine description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Time section
                      _buildSectionTitle('Time'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'Start Time',
                              time: _startTime,
                              onTimeChanged:
                                  (time) => setState(() => _startTime = time),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'End Time',
                              time: _endTime,
                              onTimeChanged:
                                  (time) => setState(() => _endTime = time),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Color section
                      _buildSectionTitle('Color'),
                      const SizedBox(height: 12),
                      _buildColorSelector(),
                      const SizedBox(height: 24),

                      // Days section
                      _buildSectionTitle('Days'),
                      const SizedBox(height: 12),
                      _buildDaySelector(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1C1C1E),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) {
          onTimeChanged(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colorOptions.length,
        itemBuilder: (context, index) {
          final color = _colorOptions[index];
          final isSelected = _selectedColor == color;

          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border:
                    isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    final dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = _selectedDays.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFF007AFF)
                      : const Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dayLabels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _saveRoutine() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a routine title'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final routine = ScheduleItem(
        _titleController.text.trim(),
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        _selectedColor,
        _descriptionController.text.trim(),
        ScheduleType.routine,
        false,
        _selectedDays,
        0,
        CardDisplayState.compact,
        null,
        DateTime.now(),
      );

      widget.onRoutineCreated(routine);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating routine: $e'),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
