import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';
import 'schedule_section.dart';
import 'theme_provider.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

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
      themeMode:
          _themeProvider.currentTheme == AppTheme.light
              ? ThemeMode.light
              : (_themeProvider.currentTheme == AppTheme.dark
                  ? ThemeMode.dark
                  : ThemeMode.dark), // Midnight Bloom uses dark mode base
      builder: (context, child) {
        // Override theme for Midnight Bloom
        if (_themeProvider.currentTheme == AppTheme.midnightBloom) {
          return Theme(data: ThemeProvider.midnightBloomTheme, child: child!);
        }
        return child!;
      },
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
    bool isSelectionMode,
    Set<int> selectedRoutineIds,
    Function(ScheduleItem) toggleRoutineSelection,
    VoidCallback toggleSelectionMode,
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
                        isSelectionMode,
                        selectedRoutineIds,
                        toggleRoutineSelection,
                        toggleSelectionMode,
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
            onPressed: () => _showAddRoutineBottomSheet(context),
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
    bool isSelectionMode,
    Set<int> selectedRoutineIds,
    Function(ScheduleItem) toggleRoutineSelection,
    VoidCallback toggleSelectionMode,
  ) {
    final isSelected =
        routine.id != null && selectedRoutineIds.contains(routine.id);

    return GestureDetector(
      onTap: isSelectionMode ? () => toggleRoutineSelection(routine) : null,
      onLongPress: () {
        if (!isSelectionMode) {
          // Provide haptic feedback
          HapticFeedback.mediumImpact();
          // Enter selection mode and select this routine
          toggleSelectionMode();
          toggleRoutineSelection(routine);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF5856D6).withOpacity(0.05)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF5856D6).withOpacity(0.3)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 2 : 1,
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
                  // Selection checkbox (only show in selection mode)
                  if (isSelectionMode) ...[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF5856D6)
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF5856D6)
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                  ],

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
                  // Individual delete button (only show when not in selection mode)
                  if (!isSelectionMode)
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
    bool isSelectionMode = false;
    Set<int> selectedRoutineIds = <int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Helper function to toggle selection mode
              void toggleSelectionMode() {
                setState(() {
                  isSelectionMode = !isSelectionMode;
                  if (!isSelectionMode) {
                    selectedRoutineIds.clear();
                  }
                });
              }

              // Helper function to toggle routine selection
              void toggleRoutineSelection(ScheduleItem routine) {
                if (routine.id != null) {
                  setState(() {
                    if (selectedRoutineIds.contains(routine.id)) {
                      selectedRoutineIds.remove(routine.id);
                    } else {
                      selectedRoutineIds.add(routine.id!);
                    }
                  });
                }
              }

              // Helper function to delete selected routines
              void deleteSelectedRoutines() async {
                if (selectedRoutineIds.isEmpty) return;

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        title: Text(
                          'Delete Selected Routines',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete ${selectedRoutineIds.length} selected routine${selectedRoutineIds.length != 1 ? 's' : ''}? This action cannot be undone.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
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
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Color(0xFFFF3B30)),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  for (final routineId in selectedRoutineIds) {
                    await _databaseHelper.deleteRoutine(routineId);
                  }
                  await _loadRoutines();
                  setState(() {
                    selectedRoutineIds.clear();
                    isSelectionMode = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deleted ${selectedRoutineIds.length} routine${selectedRoutineIds.length != 1 ? 's' : ''}',
                      ),
                      backgroundColor: const Color(0xFFFF3B30),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }

              return DraggableScrollableSheet(
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          const SizedBox(height: 16),

                          // Quick Actions Section (Horizontally Scrollable)
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Delete Selected Chip (only show when in selection mode and items are selected)
                                  if (isSelectionMode &&
                                      selectedRoutineIds.isNotEmpty) ...[
                                    GestureDetector(
                                      onTap: deleteSelectedRoutines,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFF3B30,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFFFF3B30,
                                            ).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: const Color(0xFFFF3B30),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Delete (${selectedRoutineIds.length})',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Exit Selection Mode Chip
                                    GestureDetector(
                                      onTap: toggleSelectionMode,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF8E8E93,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF8E8E93,
                                            ).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Exit Select',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Show normal chips only when not in selection mode
                                  if (!isSelectionMode) ...[
                                    // Add Routine Chip
                                    GestureDetector(
                                      onTap:
                                          () => _showAddRoutineBottomSheet(
                                            context,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF34C759,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF34C759,
                                            ).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Add Routine',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // AI Chip
                                    GestureDetector(
                                      onTap: () => _showAIBottomSheet(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF007AFF,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'AI Extract',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Clear All Chip
                                    GestureDetector(
                                      onTap: () => _showClearAllDialog(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFF3B30,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFFFF3B30,
                                            ).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.clear_all,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Clear All',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(
                                    width: 20,
                                  ), // Extra padding at the end
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Weekly Calendar for ScduleMe
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
                              isSelectionMode,
                              selectedRoutineIds,
                              toggleRoutineSelection,
                              toggleSelectionMode,
                            ),
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Clear All Schedules',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Are you sure you want to delete ALL schedules? This action cannot be undone.',
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
                  _clearAllSchedules();
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Color(0xFFFF3B30)),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _clearAllSchedules() async {
    final routineCount = _routines.length;

    // Delete all routines one by one
    for (final routine in _routines) {
      if (routine.id != null) {
        await _databaseHelper.deleteRoutine(routine.id!);
      }
    }

    _loadRoutines();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cleared $routineCount schedule${routineCount != 1 ? 's' : ''}',
        ),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddRoutineBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
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
                                color: const Color(0xFF34C759).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 24,
                                color: const Color(0xFF34C759),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Create New Routine',
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
                        child: ScheduleSection(
                          selectedDay: _selectedDay,
                          routines: _routines,
                          themeProvider: widget.themeProvider,
                          onScheduleUpdated: _updateRoutine,
                          onScheduleAdded: (routine) {
                            _addRoutine(routine);
                            Navigator.pop(
                              context,
                            ); // Close the bottom sheet after adding
                          },
                          onScheduleDeleted: _deleteRoutine,
                        ),
                      ),
                    ],
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
                          'Upload high-resolution images, screenshots, or camera photos of any schedule. Our advanced AI processes large files efficiently and extracts detailed schedule information with maximum precision.',
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
                  'Gemini-1.5-pro-latest AI Engine',
                  'Advanced and powerful AI model with enhanced capabilities - optimized for complex processing of detailed schedules and high-resolution images.',
                  const Color(0xFF5856D6),
                ),

                const SizedBox(height: 10),

                _buildInfoCard(
                  context,
                  Icons.photo_size_select_actual,
                  'Large File Support',
                  'Handles high-resolution images up to 10MB+ including screenshots, camera photos, and detailed timetables without compression.',
                  const Color(0xFFFF9500),
                ),

                const SizedBox(height: 10),

                _buildInfoCard(
                  context,
                  Icons.precision_manufacturing,
                  'Detailed Extraction',
                  'Extracts specific titles, complete descriptions, room numbers, instructor names, and precise scheduling details for 50-300+ routines.',
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

  // Enhanced image picking methods for complex schedule analysis
  Future<void> _pickImageFromCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95, // Higher quality for complex text recognition
        maxWidth: 4000, // Allow larger images for detailed schedules
        maxHeight: 4000,
        preferredCameraDevice:
            CameraDevice.rear, // Use rear camera for better quality
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
        imageQuality: 95, // Higher quality for complex text recognition
        maxWidth: 4000, // Allow larger images for detailed schedules
        maxHeight: 4000,
      );

      if (image != null) {
        _processImageWithAI(context, File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _processImageWithAI(BuildContext context, File imageFile) async {
    // Show enhanced loading dialog with progress
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
                  'Advanced AI Analysis in Progress...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Using Gemini-1.5-pro-latest for advanced complex image processing\nThis may take 15-30 seconds for detailed schedules',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );

    try {
      // Enhanced image processing for complex images
      final bytes = await imageFile.readAsBytes();

      // Enhanced file size handling for large images (screenshots, camera photos)
      final fileSizeInMB = bytes.length / (1024 * 1024);
      print('Image size: ${fileSizeInMB.toStringAsFixed(2)} MB');

      String base64Image;
      if (fileSizeInMB > 10) {
        print(
          'Very large image detected (${fileSizeInMB.toStringAsFixed(1)}MB) - optimized for processing',
        );
        // Large images are handled efficiently by Gemini-1.5-pro-latest
        // Screenshots and high-res camera photos are supported
      } else if (fileSizeInMB > 5) {
        print(
          'Large image detected (${fileSizeInMB.toStringAsFixed(1)}MB) - processing with fast AI',
        );
      }

      base64Image = base64Encode(bytes);
      print('Base64 image size: ${base64Image.length} characters');

      // Call the enhanced Gemini API
      final schedules = await _callGeminiAPI(base64Image);

      // Close loading dialog
      Navigator.pop(context);

      if (schedules.isNotEmpty) {
        // Enhanced success handling for large numbers of schedules
        await _createRoutinesFromAI(schedules);

        // Close AI bottom sheet
        Navigator.pop(context);

        // Enhanced success message with details
        final successMessage =
            schedules.length >= 50
                ? 'Outstanding! Created ${schedules.length} routines from your complex schedule!'
                : schedules.length >= 20
                ? 'Great! Created ${schedules.length} routines from your image!'
                : 'Successfully created ${schedules.length} routine${schedules.length != 1 ? 's' : ''} from your image!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(successMessage),
                if (schedules.length >= 20)
                  Text(
                    'Large schedule detected - check all days for your routines',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
              ],
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );

        // Log processing statistics
        print('=== AI PROCESSING COMPLETE ===');
        print('Total schedules extracted: ${schedules.length}');
        print('Image processing model: Gemini-1.5-pro-latest');
        print('Processing successful: ${DateTime.now()}');
      } else {
        _showErrorSnackBar(
          context,
          'No schedules detected. Try:\n• Better lighting\n• Clearer text\n• Full schedule visible\n• Less blurry image',
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Enhanced error handling
      String errorMessage = 'Processing failed: ';
      if (e.toString().contains('API call failed')) {
        errorMessage += 'Network or API issue. Check internet connection.';
      } else if (e.toString().contains('Failed to parse')) {
        errorMessage +=
            'AI response parsing error. Try with a different image.';
      } else {
        errorMessage += 'Unexpected error. Please try again.';
      }

      print('Error details: $e');
      _showErrorSnackBar(context, errorMessage);
    }
  }

  Future<List<Map<String, dynamic>>> _callGeminiAPI(String base64Image) async {
    // Get API key from environment variables
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    // Updated to use Gemini-1.5-pro-latest for enhanced complex image analysis
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey';

    final prompt = '''
You are an expert schedule analyzer. Analyze this image EXTREMELY THOROUGHLY and extract ALL schedule/routine information with precise details.

COMPREHENSIVE ANALYSIS REQUIRED:
- Scan EVERY part of the image methodically (top-to-bottom, left-to-right)
- Extract ALL schedule information: classes, meetings, activities, tasks, appointments, deadlines
- Handle ALL time formats: 12-hour, 24-hour, abbreviated times
- Process ALL schedule layouts: tables, grids, lists, handwritten notes, printed formats, digital screenshots
- Read ALL text types: small text, faded text, handwritten text, different fonts, rotated text
- Identify recurring patterns and one-time events
- Extract from complex multi-column and overlapping layouts

TARGET EXTRACTION: Extract 50-300+ individual schedule entries from complex images.

CRITICAL: Return ONLY a valid JSON array with this EXACT structure - no explanations, no markdown:

[
  {
    "title": "Specific and descriptive activity name (e.g., 'Mathematics 101 - Linear Algebra', 'Team Meeting - Project Alpha', 'Doctor Appointment - Cardiology')",
    "description": "Complete details: room numbers, instructor names, location, additional notes, building names, floor numbers",
    "startTime": "HH:MM (24-hour format only)",
    "endTime": "HH:MM (24-hour format only)", 
    "weeklySchedule": [0,1,2,3,4,5,6] (0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)
  }
]

EXTRACTION RULES:
1. Extract EVERY visible schedule entry - aim for maximum extraction (50-300+ entries)
2. Create specific, descriptive titles that include subject/activity details
3. Include ALL available details in description: rooms, instructors, locations, notes
4. Convert ALL times to 24-hour format (09:00, 14:30, 21:00)
5. For weeklySchedule: specify exact days when activity occurs
6. If no days specified, use logical context-based defaults
7. Break large time blocks into specific sub-activities when possible
8. Handle overlapping schedules by creating separate detailed entries
9. Minimum duration: 15 minutes, Maximum: 8 hours
10. For deadlines/assignments: create appropriate time slots (e.g., 23:59 for end-of-day)

HANDLE ALL SCENARIOS:
- University/school timetables with course codes and room numbers
- Work schedules with meeting rooms and participant details
- Medical appointments with doctor names and clinic locations
- Training programs with module names and instructors
- Conference schedules with session titles and venues
- Personal planners with detailed activity descriptions
- Examination schedules with subjects and halls
- Sports schedules with teams and locations

Be EXTREMELY thorough in extraction - capture every detail visible in the image.
Return ONLY the JSON array with no additional text.
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
        'temperature':
            0.2, // Optimized for more precise and accurate extraction
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens':
            32768, // Increased for complex schedules with detailed extraction using pro model
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

      // Enhanced JSON cleaning for complex responses
      String cleanedText = generatedText.trim();

      // Remove various markdown code block formats
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }

      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }

      // Remove any leading/trailing explanatory text
      int jsonStart = cleanedText.indexOf('[');
      int jsonEnd = cleanedText.lastIndexOf(']');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        cleanedText = cleanedText.substring(jsonStart, jsonEnd + 1);
      }

      try {
        final List<dynamic> schedules = jsonDecode(cleanedText.trim());
        print('AI extracted ${schedules.length} schedules from image');
        return schedules.cast<Map<String, dynamic>>();
      } catch (e) {
        print('Failed to parse AI response: $e');
        print('AI Response length: ${generatedText.length}');
        print(
          'First 500 chars: ${generatedText.substring(0, generatedText.length > 500 ? 500 : generatedText.length)}',
        );

        // Attempt to fix common JSON issues
        try {
          // Try to extract JSON from mixed content
          final jsonMatch = RegExp(
            r'\[.*\]',
            dotAll: true,
          ).firstMatch(cleanedText);
          if (jsonMatch != null) {
            final extractedJson = jsonMatch.group(0)!;
            final List<dynamic> schedules = jsonDecode(extractedJson);
            print(
              'Successfully recovered ${schedules.length} schedules after JSON repair',
            );
            return schedules.cast<Map<String, dynamic>>();
          }
        } catch (repairError) {
          print('JSON repair also failed: $repairError');
        }

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
    int successCount = 0;
    int failCount = 0;

    print('Creating ${schedules.length} routines from AI analysis...');

    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];
      try {
        // Validate required fields
        if (schedule['title'] == null ||
            schedule['title'].toString().trim().isEmpty) {
          print('Skipping schedule $i: Missing title');
          failCount++;
          continue;
        }

        if (schedule['startTime'] == null || schedule['endTime'] == null) {
          print('Skipping schedule $i: Missing time information');
          failCount++;
          continue;
        }

        // Validate time format
        if (!_isValidTimeFormat(schedule['startTime']) ||
            !_isValidTimeFormat(schedule['endTime'])) {
          print('Skipping schedule $i: Invalid time format');
          failCount++;
          continue;
        }

        // Don't assign colors cyclically - let the app use default colors
        // Colors will be handled by the app's theme system
        final routine = ScheduleItem(
          schedule['title'].toString().trim(),
          schedule['startTime'].toString(),
          schedule['endTime'].toString(),
          const Color(0xFF007AFF), // Use consistent default color
          schedule['description']?.toString() ?? '',
          ScheduleType.routine,
          false, // isCompleted
          _validateWeeklySchedule(schedule['weeklySchedule']),
          0, // percentage
          CardDisplayState.compact,
          null, // id
          DateTime.now(), // createdAt
        );

        await _addRoutine(routine);
        successCount++;

        // Log progress for large batches
        if (schedules.length > 20 && (i + 1) % 10 == 0) {
          print('Progress: ${i + 1}/${schedules.length} routines processed');
        }
      } catch (e) {
        print('Failed to create routine ${i + 1}: $e');
        print('Schedule data: $schedule');
        failCount++;
      }
    }

    print('=== ROUTINE CREATION COMPLETE ===');
    print('Successfully created: $successCount routines');
    print('Failed to create: $failCount routines');
    print('Total processed: ${schedules.length} schedules');
  }

  // Helper function to validate time format
  bool _isValidTimeFormat(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return false;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  // Helper function to validate and fix weekly schedule
  List<int> _validateWeeklySchedule(dynamic weeklySchedule) {
    if (weeklySchedule == null) {
      return [1, 2, 3, 4, 5]; // Default to weekdays
    }

    try {
      final List<int> schedule = List<int>.from(weeklySchedule);
      // Filter valid days (0-6) and remove duplicates
      final validDays =
          schedule.where((day) => day >= 0 && day <= 6).toSet().toList();

      if (validDays.isEmpty) {
        return [1, 2, 3, 4, 5]; // Default to weekdays if invalid
      }

      return validDays;
    } catch (e) {
      return [1, 2, 3, 4, 5]; // Default to weekdays on error
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

  void _showThemeSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.7,
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
                                color: const Color(0xFF5856D6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.palette,
                                size: 24,
                                color: const Color(0xFF5856D6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Theme Settings',
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
                      const SizedBox(height: 24),

                      // Theme Options
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose your theme',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Theme Cards
                              ...AppTheme.values
                                  .map(
                                    (theme) => _buildThemeCard(
                                      context,
                                      theme,
                                      widget.themeProvider.currentTheme ==
                                          theme,
                                    ),
                                  )
                                  .toList(),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    AppTheme theme,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          widget.themeProvider.setTheme(theme);
          // Add haptic feedback
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
              width: isSelected ? 2 : 1,
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
          child: Row(
            children: [
              // Theme preview container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: _getThemeGradient(theme),
                ),
                child: Icon(
                  ThemeProvider.getThemeIcon(theme),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Theme info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ThemeProvider.getThemeName(theme),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getThemeDescription(theme),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getThemeGradient(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF34C759)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppTheme.dark:
        return const LinearGradient(
          colors: [Color(0xFF1C1C1E), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppTheme.midnightBloom:
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Clean and bright interface for daytime use';
      case AppTheme.dark:
        return 'Easy on the eyes for low-light environments';
      case AppTheme.midnightBloom:
        return 'Mystical purple-pink theme with elegant blooms';
    }
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
            onPressed: () => _showThemeSettingsBottomSheet(context),
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5856D6).withOpacity(0.1), // Purple theme
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF5856D6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 18,
                color: const Color(0xFF5856D6),
              ),
            ),
            tooltip: 'Theme Settings',
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
