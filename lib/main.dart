import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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

  void _showScheduleMeBottomSheet(BuildContext context) {
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
                          color: Theme.of(context).cardColor,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
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
                                    Icons.calendar_today,
                                    size: 24,
                                    color: const Color(0xFF34C759),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Schedules - Routine Management',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == selectedDayIndex;
          final isToday = index == today;
          final routinesCount =
              _routines
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
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (routinesCount > 0)
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF34C759),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$routinesCount',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? const Color(0xFF34C759)
                                    : Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(width: 16, height: 16),
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
        _routines
            .where(
              (routine) => routine.weeklySchedule.contains(selectedDayIndex),
            )
            .toList();

    // Sort routines by start time
    dayRoutines.sort((a, b) {
      final aTime = TimeOfDay(
        hour: int.parse(a.startTime.split(':')[0]),
        minute: int.parse(a.startTime.split(':')[1]),
      );
      final bTime = TimeOfDay(
        hour: int.parse(b.startTime.split(':')[0]),
        minute: int.parse(b.startTime.split(':')[1]),
      );
      return aTime.hour.compareTo(bTime.hour) != 0
          ? aTime.hour.compareTo(bTime.hour)
          : aTime.minute.compareTo(bTime.minute);
    });

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
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${dayRoutines.length} routine${dayRoutines.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Routines List
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No routines for $dayName',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a routine to get started',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.repeat, size: 16, color: const Color(0xFF007AFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    routine.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDeleteDialog(context, routine),
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
                  Icons.timer_outlined,
                  _calculateDuration(routine.startTime, routine.endTime),
                  const Color(0xFF34C759),
                ),
              ],
            ),
            if (routine.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                routine.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
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

  void _showDeleteDialog(BuildContext context, ScheduleItem routine) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Delete Routine',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Are you sure you want to delete "${routine.title}"? This action cannot be undone.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteRoutine(routine);
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

  String _formatTimeToAmPm(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
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

  void _showScduleMeBottomSheet(BuildContext context) {
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
                          color: Theme.of(context).cardColor,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
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
                                    child: Row(
                                      children: [
                                        Text(
                                          'ScduleMe',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap:
                                              () => _showAIBottomSheet(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF007AFF,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF007AFF,
                                                ).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.auto_awesome,
                                                  size: 14,
                                                  color: const Color(
                                                    0xFF007AFF,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'AI',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF007AFF,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ), // Weekly Calendar for ScduleMe
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

  void _showAIBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 24,
                                color: const Color(0xFF007AFF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI - Schedule Creator',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content
                      Expanded(
                        child: _buildAContentSection(context, scrollController),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildAContentSection(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return Column(
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Upload Your Schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI POWERED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF007AFF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // Upload Feature
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Main upload card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.upload_file,
                            size: 32,
                            color: const Color(0xFF007AFF),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'Upload Schedule Image',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          'Take a photo or upload an image of your timetable, schedule, or handwritten notes. Our AI will automatically create routines for you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Upload buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImageFromCamera(context),
                                icon: Icon(Icons.camera_alt, size: 16),
                                label: Text('Take Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF34C759),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImageFromGallery(context),
                                icon: Icon(Icons.photo_library, size: 16),
                                label: Text('Choose Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007AFF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info cards
                _buildInfoCard(
                  context,
                  Icons.auto_awesome,
                  'AI Processing',
                  'Advanced AI analyzes your image and extracts schedule information automatically.',
                  const Color(0xFF5856D6),
                ),

                const SizedBox(height: 10),

                _buildInfoCard(
                  context,
                  Icons.schedule,
                  'Smart Recognition',
                  'Recognizes times, subjects, days, and activities from various image formats.',
                  const Color(0xFFFF9500),
                ),

                const SizedBox(height: 10),

                _buildInfoCard(
                  context,
                  Icons.check_circle,
                  'Auto-Create Routines',
                  'Automatically creates multiple routines that work just like manually created ones.',
                  const Color(0xFF34C759),
                ),

                // Add bottom padding to ensure content doesn't get cut off
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Image picking methods
  Future<void> _pickImageFromCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        _processImageWithAI(context, File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to take photo: $e');
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _processImageWithAI(context, File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _processImageWithAI(BuildContext context, File imageFile) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: const Color(0xFF007AFF)),
                const SizedBox(height: 16),
                Text(
                  'AI is analyzing your schedule...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
    );

    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call Gemini API
      final schedules = await _callGeminiAPI(base64Image);

      // Close loading dialog
      Navigator.pop(context);

      if (schedules.isNotEmpty) {
        // Create routines from AI response
        await _createRoutinesFromAI(schedules);

        // Close AI bottom sheet
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully created ${schedules.length} routine${schedules.length != 1 ? 's' : ''} from your image!',
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showErrorSnackBar(
          context,
          'No schedules found in the image. Please try with a clearer image.',
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorSnackBar(context, 'Failed to process image: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _callGeminiAPI(String base64Image) async {
    const String apiKey = 'AIzaSyDRPiM0HxRw68QMB6ed1CuHKrLQnbd5yVQ';
    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final prompt = '''
Analyze this image and extract all schedule/routine information. Return ONLY a valid JSON array with the following structure for each routine found:

[
  {
    "title": "Subject/Activity name",
    "description": "Brief description or additional notes",
    "startTime": "HH:MM" (24-hour format),
    "endTime": "HH:MM" (24-hour format),
    "weeklySchedule": [0, 1, 2, 3, 4, 5, 6] (array of day indices: 0=Sunday, 1=Monday, etc.)
  }
]

Important rules:
1. Extract ALL visible schedules/routines from the image
2. Use 24-hour time format (e.g., "09:00", "14:30")
3. For weeklySchedule, include only the days when this routine occurs
4. If no specific days are mentioned, assume it's for weekdays [1,2,3,4,5]
5. Make realistic time durations (minimum 15 minutes, maximum 4 hours)
6. Return ONLY the JSON array, no other text
7. If no clear schedule is found, return []

Extract schedules from: timetables, handwritten notes, printed schedules, class schedules, work schedules, etc.
''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 1,
        'topP': 1,
        'maxOutputTokens': 2048,
      },
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final generatedText =
          responseData['candidates'][0]['content']['parts'][0]['text'];

      // Clean the response and parse JSON
      String cleanedText = generatedText.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }

      try {
        final List<dynamic> schedules = jsonDecode(cleanedText.trim());
        return schedules.cast<Map<String, dynamic>>();
      } catch (e) {
        print('Failed to parse AI response: $e');
        print('AI Response: $generatedText');
        return [];
      }
    } else {
      throw Exception(
        'API call failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> _createRoutinesFromAI(
    List<Map<String, dynamic>> schedules,
  ) async {
    for (final schedule in schedules) {
      try {
        final routine = ScheduleItem(
          schedule['title'] ?? 'Untitled',
          schedule['startTime'] ?? '09:00',
          schedule['endTime'] ?? '10:00',
          const Color(0xFF007AFF), // Default color
          schedule['description'] ?? '',
          ScheduleType.routine,
          false, // isCompleted
          List<int>.from(schedule['weeklySchedule'] ?? [1, 2, 3, 4, 5]),
          0, // percentage
          CardDisplayState.compact,
          null, // id
          DateTime.now(), // createdAt
        );

        await _addRoutine(routine);
      } catch (e) {
        print('Failed to create routine: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    final currentMonth = monthNames[_focusedDay.month - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMonth),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showScheduleMeBottomSheet(context),
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5856D6).withOpacity(0.1), // iOS purple
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF5856D6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: const Color(0xFF5856D6), // iOS purple
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Schedules',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5856D6), // iOS purple
                    ),
                  ),
                ],
              ),
            ),
            tooltip: 'Manage Schedules',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showScduleMeBottomSheet(context),
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.1), // iOS green
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF34C759).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 16,
                    color: const Color(0xFF34C759), // iOS green
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ScduleMe',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF34C759), // iOS green
                    ),
                  ),
                ],
              ),
            ),
            tooltip: 'ScduleMe Features',
          ),
          const SizedBox(width: 8),
        ],
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
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
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
