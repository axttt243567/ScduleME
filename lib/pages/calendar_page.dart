import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';
import 'event_detail_page.dart';

/// Calendar view modes
enum CalendarViewMode { yearly, monthly, weekly }

/// Calendar page with heatmap visualization and analytics
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarViewMode _viewMode = CalendarViewMode.monthly;
  DateTime _focusedDate = DateTime.now();
  final Map<int, GlobalKey> _monthKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize month keys
    for (int i = 1; i <= 12; i++) {
      _monthKeys[i] = GlobalKey();
    }
    // Load events when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
      // Scroll to current month in yearly view if needed
      if (_viewMode == CalendarViewMode.yearly) {
        _scrollToCurrentMonth();
      }
    });
  }

  void _scrollToCurrentMonth() {
    final currentMonth = DateTime.now().month;
    final key = _monthKeys[currentMonth];
    if (key?.currentContext != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> allEvents) {
    return allEvents.where((event) => event.occursOnDate(day)).toList();
  }

  /// Get events in date range
  List<Event> _getEventsInRange(
    DateTime start,
    DateTime end,
    List<Event> allEvents,
  ) {
    final events = <Event>[];
    for (
      var day = start;
      day.isBefore(end) || day.isAtSameMomentAs(end);
      day = day.add(const Duration(days: 1))
    ) {
      events.addAll(_getEventsForDay(day, allEvents));
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        toolbarHeight: 56,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text('Calendar', style: theme.textTheme.titleLarge),
              const SizedBox(width: 12),
              // View mode filter chips
              FilterChip(
                label: Text(
                  'Yearly',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _viewMode == CalendarViewMode.yearly
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: _viewMode == CalendarViewMode.yearly
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _viewMode == CalendarViewMode.yearly,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewMode = CalendarViewMode.yearly;
                    });
                    // Scroll to current month when yearly view is selected
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _scrollToCurrentMonth();
                    });
                  }
                },
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                backgroundColor: colorScheme.surfaceContainerHighest,
                selectedColor: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: Text(
                  'Monthly',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _viewMode == CalendarViewMode.monthly
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: _viewMode == CalendarViewMode.monthly
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _viewMode == CalendarViewMode.monthly,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewMode = CalendarViewMode.monthly;
                    });
                  }
                },
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                backgroundColor: colorScheme.surfaceContainerHighest,
                selectedColor: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: Text(
                  'Weekly',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _viewMode == CalendarViewMode.weekly
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: _viewMode == CalendarViewMode.weekly
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _viewMode == CalendarViewMode.weekly,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewMode = CalendarViewMode.weekly;
                    });
                  }
                },
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                backgroundColor: colorScheme.surfaceContainerHighest,
                selectedColor: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              // Refresh chip - resets to today's date and refreshes events
              ActionChip(
                label: const Icon(Icons.refresh, size: 16),
                tooltip: 'Reset to Today',
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime.now();
                  });
                  context.read<EventProvider>().loadEvents();
                  // Scroll to current month if in yearly view
                  if (_viewMode == CalendarViewMode.yearly) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _scrollToCurrentMonth();
                    });
                  }
                },
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventProvider.error!,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => eventProvider.loadEvents(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allEvents = eventProvider.events;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar view based on mode
                  if (_viewMode == CalendarViewMode.yearly)
                    _buildYearlyView(context, allEvents)
                  else if (_viewMode == CalendarViewMode.monthly)
                    _buildMonthlyView(context, allEvents)
                  else
                    _buildWeeklyView(context, allEvents),

                  const SizedBox(height: 24),

                  // Analytics section
                  _buildAnalytics(context, allEvents),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build detailed yearly heatmap view with all dates
  Widget _buildYearlyView(BuildContext context, List<Event> allEvents) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final year = _focusedDate.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _focusedDate = DateTime(year - 1, 1);
                });
              },
            ),
            Text(
              year.toString(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _focusedDate = DateTime(year + 1, 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // All 12 months with detailed view
        ...List.generate(12, (monthIndex) {
          final month = monthIndex + 1;
          final monthDate = DateTime(year, month);
          final monthName = DateFormat('MMMM').format(monthDate);

          final firstDayOfMonth = DateTime(year, month, 1);
          final lastDayOfMonth = DateTime(year, month + 1, 0);
          final daysInMonth = lastDayOfMonth.day;
          final startWeekday = firstDayOfMonth.weekday - 1;

          return Column(
            key: _monthKeys[month],
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (monthIndex > 0) const SizedBox(height: 20),
              // Month name
              Text(
                monthName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Weekday headers
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              // Days grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: startWeekday + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < startWeekday) {
                    return const SizedBox.shrink();
                  }

                  final day = index - startWeekday + 1;
                  final date = DateTime(year, month, day);
                  final dayEvents = _getEventsForDay(date, allEvents);

                  final isToday =
                      DateTime.now().year == year &&
                      DateTime.now().month == month &&
                      DateTime.now().day == day;

                  final totalCount = dayEvents.length;
                  final intensity = totalCount > 0
                      ? (totalCount / 10).clamp(0.0, 1.0)
                      : 0.0;

                  return InkWell(
                    onTap: totalCount > 0
                        ? () {
                            _showDayEventsSheet(context, date, dayEvents);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: totalCount > 0
                            ? colorScheme.primary.withOpacity(
                                0.15 + intensity * 0.5,
                              )
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isToday
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.15),
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: totalCount > 0
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build monthly heatmap view
  Widget _buildMonthlyView(BuildContext context, List<Event> allEvents) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final year = _focusedDate.year;
    final month = _focusedDate.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Calculate starting weekday (0 = Monday, 6 = Sunday)
    final startWeekday = firstDayOfMonth.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _focusedDate = DateTime(year, month - 1);
                });
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(_focusedDate),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _focusedDate = DateTime(year, month + 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekday headers
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }

            final day = index - startWeekday + 1;
            final date = DateTime(year, month, day);
            final dayEvents = _getEventsForDay(date, allEvents);

            final isToday =
                DateTime.now().year == year &&
                DateTime.now().month == month &&
                DateTime.now().day == day;

            final totalCount = dayEvents.length;
            final intensity = totalCount > 0
                ? (totalCount / 10).clamp(0.0, 1.0)
                : 0.0;

            return InkWell(
              onTap: totalCount > 0
                  ? () {
                      _showDayEventsSheet(context, date, dayEvents);
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: totalCount > 0
                      ? colorScheme.primary.withOpacity(0.15 + intensity * 0.5)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isToday
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.2),
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: totalCount > 0
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build weekly heatmap view
  Widget _buildWeeklyView(BuildContext context, List<Event> allEvents) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get start of week (Monday)
    final weekday = _focusedDate.weekday;
    final startOfWeek = _focusedDate.subtract(Duration(days: weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _focusedDate = _focusedDate.subtract(const Duration(days: 7));
                });
              },
            ),
            Text(
              '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(startOfWeek.add(const Duration(days: 6)))}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _focusedDate = _focusedDate.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Days of week
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7,
          itemBuilder: (context, index) {
            final date = startOfWeek.add(Duration(days: index));
            final dayEvents = _getEventsForDay(date, allEvents);
            final isToday =
                DateTime.now().year == date.year &&
                DateTime.now().month == date.month &&
                DateTime.now().day == date.day;

            final totalCount = dayEvents.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: totalCount > 0
                    ? () {
                        _showDayEventsSheet(context, date, dayEvents);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.2),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Date info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('d').format(date),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Event count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalCount ${totalCount == 1 ? 'event' : 'events'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Simple progress indicator
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: totalCount > 0
                                    ? colorScheme.primary.withOpacity(0.3)
                                    : colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: totalCount > 0
                                    ? (totalCount / 10).clamp(0.0, 1.0)
                                    : 0.0,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (totalCount > 0) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build analytics section
  Widget _buildAnalytics(BuildContext context, List<Event> allEvents) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get events for current view range
    DateTime startDate, endDate;
    switch (_viewMode) {
      case CalendarViewMode.yearly:
        startDate = DateTime(_focusedDate.year, 1, 1);
        endDate = DateTime(_focusedDate.year, 12, 31);
        break;
      case CalendarViewMode.monthly:
        startDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
        endDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
        break;
      case CalendarViewMode.weekly:
        final weekday = _focusedDate.weekday;
        startDate = _focusedDate.subtract(Duration(days: weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
        break;
    }

    final rangeEvents = _getEventsInRange(startDate, endDate, allEvents);

    // Calculate statistics
    final totalCount = rangeEvents.length;
    final doneCount = rangeEvents
        .where((e) => e.remark == EventRemark.done)
        .length;
    final skipCount = rangeEvents
        .where((e) => e.remark == EventRemark.skip)
        .length;
    final missedCount = rangeEvents
        .where((e) => e.remark == EventRemark.missed)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Statistics grid
          Row(
            children: [
              _buildAnalyticCard(
                context,
                'Total',
                totalCount.toString(),
                Icons.event,
                colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _buildAnalyticCard(
                context,
                'Done',
                doneCount.toString(),
                Icons.check_circle,
                EventRemark.done.color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAnalyticCard(
                context,
                'Skipped',
                skipCount.toString(),
                Icons.skip_next,
                EventRemark.skip.color,
              ),
              const SizedBox(width: 12),
              _buildAnalyticCard(
                context,
                'Missed',
                missedCount.toString(),
                Icons.cancel,
                EventRemark.missed.color,
              ),
            ],
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 16),
            // Completion rate
            Row(
              children: [
                Text(
                  'Completion:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${((doneCount / totalCount) * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: EventRemark.done.color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build analytic card
  Widget _buildAnalyticCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show bottom sheet with day events
  void _showDayEventsSheet(
    BuildContext context,
    DateTime date,
    List<Event> events,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Date header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    DateFormat('EEEE, MMMM d, y').format(date),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Events list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final category = event.categoryIds.isNotEmpty
                          ? Categories.getById(event.categoryIds.first)
                          : Categories.other;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailPage(event: event),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: category.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      event.icon,
                                      color: category.color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Event info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.getTimeString(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status
                                  if (event.remark != EventRemark.none)
                                    Icon(
                                      event.remark.icon,
                                      color: event.remark.color,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
