import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../providers/event_provider.dart';

/// Today page with timeline view showing events
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load events when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest, // Pure black AMOLED
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surfaceContainerLowest, // Pure black
        toolbarHeight: 80,
        titleSpacing: 0,
        centerTitle: false,
        flexibleSpace: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Today text - tap to return to today
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = now;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'Today',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: _isToday(_selectedDate)
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Day chips for the next 6 days
                for (int i = 1; i <= 6; i++)
                  Builder(
                    builder: (context) {
                      final date = now.add(Duration(days: i));
                      final isSelected =
                          _selectedDate.year == date.year &&
                          _selectedDate.month == date.month &&
                          _selectedDate.day == date.day;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(_getDayName(date.weekday)),
                          labelStyle: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                          ),
                          side: BorderSide.none,
                          backgroundColor: isSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHigh,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
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

          final events = eventProvider.getEventsForDate(_selectedDate);

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events for this day',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add an event',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Event timeline
              for (final event in events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EventTimelineCard(
                    event: event,
                    isToday: _isToday(_selectedDate),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Card expansion states
enum _CardState {
  micro, // State 1: Default compact view
  full, // State 2: Extended with all details
}

/// Two-state expandable event card
class _EventTimelineCard extends StatefulWidget {
  final Event event;
  final bool isToday;

  const _EventTimelineCard({required this.event, required this.isToday});

  @override
  State<_EventTimelineCard> createState() => _EventTimelineCardState();
}

class _EventTimelineCardState extends State<_EventTimelineCard> {
  _CardState _currentState = _CardState.micro; // Default state
  String? _markedAs; // Track if marked as 'Done' or 'Skip'

  @override
  void initState() {
    super.initState();
    // Start in micro state regardless of event status
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleState() {
    setState(() {
      _currentState = _currentState == _CardState.micro
          ? _CardState.full
          : _CardState.micro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHappening = widget.isToday && widget.event.isHappeningNow();
    final category = widget.event.categoryIds.isNotEmpty
        ? Categories.getById(widget.event.categoryIds.first)
        : Categories.other;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest, // Pure black X-style
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // X-style subtle rounding
          side: BorderSide(
            color: isHappening
                ? colorScheme.primary.withOpacity(0.5) // Twitter blue glow
                : colorScheme.outline, // X-style border
            width: isHappening ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content - tap anywhere to toggle state
            InkWell(
              onTap: _toggleState,
              child: Padding(
                padding: const EdgeInsets.all(16), // X-style padding
                child: _buildContent(theme, colorScheme, category, isHappening),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    ColorScheme colorScheme,
    EventCategory category,
    bool isHappening,
  ) {
    switch (_currentState) {
      case _CardState.micro:
        return _buildMicroState(theme, colorScheme, category, isHappening);
      case _CardState.full:
        return _buildFullState(theme, colorScheme, category, isHappening);
    }
  }

  /// State 1: MICRO - Icon + Title, then Time + Duration + Priority chips
  Widget _buildMicroState(
    ThemeData theme,
    ColorScheme colorScheme,
    EventCategory category,
    bool isHappening,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Icon + Title + NOW badge (if happening)
        Row(
          children: [
            Icon(widget.event.icon, size: 24, color: category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.event.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isHappening) ...[
              const SizedBox(width: 8),
              // NOW badge - minimal design
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NOW',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Time + Duration + Priority chips + Status chip
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Time chip (icon + time only)
            _buildChip(
              icon: Icons.access_time,
              label: _getStartTime(),
              color: category.color,
              colorScheme: colorScheme,
            ),
            // Duration chip
            _buildChip(
              icon: Icons.timer_outlined,
              label: _getDuration(),
              color: colorScheme.tertiary,
              colorScheme: colorScheme,
            ),
            // Priority chip (if medium/high)
            if (widget.event.priority.value >= 2)
              _buildChip(
                icon: widget.event.priority.icon,
                label: widget.event.priority.displayName,
                color: widget.event.priority.color,
                colorScheme: colorScheme,
              ),
            // Status chip (if marked as Done or Skip)
            if (_markedAs != null)
              _buildChip(
                icon: _markedAs == 'Done'
                    ? Icons.check_circle
                    : Icons.cancel_outlined,
                label: _markedAs!,
                color: _markedAs == 'Done' ? Colors.green : colorScheme.error,
                colorScheme: colorScheme,
              ),
          ],
        ),
      ],
    );
  }

  /// State 2: FULL - Extended micro with all details
  Widget _buildFullState(
    ThemeData theme,
    ColorScheme colorScheme,
    EventCategory category,
    bool isHappening,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Icon + Title + NOW badge (if happening)
        Row(
          children: [
            Icon(widget.event.icon, size: 24, color: category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.event.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isHappening) ...[
              const SizedBox(width: 8),
              // NOW badge - minimal design
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NOW',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Time + Duration + Priority chips (same as micro)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              icon: Icons.access_time,
              label: _getStartTime(),
              color: category.color,
              colorScheme: colorScheme,
            ),
            _buildChip(
              icon: Icons.timer_outlined,
              label: _getDuration(),
              color: colorScheme.tertiary,
              colorScheme: colorScheme,
            ),
            if (widget.event.priority.value >= 2)
              _buildChip(
                icon: widget.event.priority.icon,
                label: widget.event.priority.displayName,
                color: widget.event.priority.color,
                colorScheme: colorScheme,
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Description/Notes section
        if (widget.event.notes?.isNotEmpty ?? false) ...[
          Text(
            'Description',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.event.notes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Categories and Quick Actions in single scrollable row
        Text(
          'Categories & Actions',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Category chips
              if (widget.event.categoryIds.isNotEmpty)
                ...widget.event.categoryIds.map(
                  (categoryId) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildUnifiedChip(
                      label: Categories.getById(categoryId).name,
                      color: Categories.getById(categoryId).color,
                      colorScheme: colorScheme,
                    ),
                  ),
                ),
              // Quick action chips
              _buildStatusActionChip(
                icon: Icons.check_circle,
                label: 'Done',
                isSelected: _markedAs == 'Done',
                onTap: () {
                  setState(() {
                    _markedAs = _markedAs == 'Done' ? null : 'Done';
                  });
                  _markDone();
                },
                colorScheme: colorScheme,
                selectedColor: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatusActionChip(
                icon: Icons.cancel_outlined,
                label: 'Skip',
                isSelected: _markedAs == 'Skip',
                onTap: () {
                  setState(() {
                    _markedAs = _markedAs == 'Skip' ? null : 'Skip';
                  });
                  _skipEvent();
                },
                colorScheme: colorScheme,
                selectedColor: colorScheme.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper: Get start time only
  String _getStartTime() {
    if (widget.event.isAllDay) {
      return 'All Day';
    }
    if (widget.event.startTime == null) {
      return 'No time';
    }
    return '${widget.event.startTime!.hour.toString().padLeft(2, '0')}:${widget.event.startTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Helper: Get duration string
  String _getDuration() {
    if (widget.event.durationMinutes == null ||
        widget.event.durationMinutes == 0) {
      return '30m';
    }
    final totalMinutes = widget.event.durationMinutes!;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  /// Build reusable chip
  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required ColorScheme colorScheme,
    bool iconOnly = false,
  }) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: iconOnly ? 8 : 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          if (!iconOnly && label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build unified chip for categories (same size as action chips)
  Widget _buildUnifiedChip({
    required String label,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build status action chip (Done/Skip) with selected state
  Widget _buildStatusActionChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required Color selectedColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.2)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? selectedColor.withOpacity(0.5)
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? selectedColor : colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : colorScheme.onSurface,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action handlers
  void _markDone() {
    _showSnackbar('Marked as done!');
  }

  void _skipEvent() {
    _showSnackbar('Event skipped');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
