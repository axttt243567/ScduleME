import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'super_amoled_theme.dart';
import 'providers/event_provider.dart';
import 'pages/today_page.dart';
import 'pages/calendar_page.dart';
import 'pages/notes_page.dart';
import 'pages/profile_page.dart';
import 'widgets/welcome_dialog.dart';

void main() {
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: MaterialApp(
        title: 'ScheduleMe — Student',
        debugShowCheckedModeBanner: false,
        theme: superAmoledDarkTheme, // Using Super AMOLED Dark Theme
        darkTheme: superAmoledDarkTheme,
        themeMode: ThemeMode.dark,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _isNavBarVisible = true; // Start visible
  DateTime? _lastInteractionTime;

  final _pages = const [
    TodayPage(), // New event-powered today page
    CalendarPage(), // New event-powered calendar page
    NotesPage(), // New notes page with folders and categories
    ProfilePage(), // Profile page with management options
  ];

  @override
  void initState() {
    super.initState();
    // Show welcome dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeDialog.showIfFirstLaunch(context);
    });
    // Start auto-hide timer
    _startAutoHideTimer();
  }

  void _startAutoHideTimer() {
    _lastInteractionTime = DateTime.now();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _lastInteractionTime != null) {
        final timeSinceLastInteraction = DateTime.now().difference(
          _lastInteractionTime!,
        );
        if (timeSinceLastInteraction.inSeconds >= 3) {
          setState(() => _isNavBarVisible = false);
        }
      }
    });
  }

  void _showNavBar() {
    if (!_isNavBarVisible) {
      setState(() => _isNavBarVisible = true);
    }
    _startAutoHideTimer();
  }

  void _onUserInteraction() {
    _lastInteractionTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: GestureDetector(
        onTap: () {
          // Show navbar on any tap
          _showNavBar();
        },
        child: Stack(
          children: [
            _pages[_currentIndex],
            // Floating icon-only navbar with slide animation
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                offset: _isNavBarVisible ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isNavBarVisible ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_isNavBarVisible,
                    child: SafeArea(
                      minimum: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _FloatingNavBar(
                          index: _currentIndex,
                          onTap: (i) {
                            _onUserInteraction();
                            setState(() => _currentIndex = i);
                            _startAutoHideTimer();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _FloatingNavBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Theme-based colors - no hardcoded values
    final bg = cs.secondaryContainer;
    final selected = cs.onSecondaryContainer;
    final unselected = cs.onSurfaceVariant;

    return Material(
      elevation: 6,
      color: bg, // Use theme color directly instead of transparent
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavIcon(
              icon: Icons.today_outlined,
              filledIcon: Icons.today,
              isActive: index == 0,
              activeColor: selected,
              inactiveColor: unselected,
              onPressed: () => onTap(0),
            ),
            const SizedBox(width: 10),
            _NavIcon(
              icon: Icons.calendar_month_outlined,
              filledIcon: Icons.calendar_month,
              isActive: index == 1,
              activeColor: selected,
              inactiveColor: unselected,
              onPressed: () => onTap(1),
            ),
            const SizedBox(width: 10),
            _NavIcon(
              icon: Icons.notes_outlined,
              filledIcon: Icons.notes,
              isActive: index == 2,
              activeColor: selected,
              inactiveColor: unselected,
              onPressed: () => onTap(2),
            ),
            const SizedBox(width: 10),
            _NavIcon(
              icon: Icons.person_outline,
              filledIcon: Icons.person,
              isActive: index == 3,
              activeColor: selected,
              inactiveColor: unselected,
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onPressed;
  const _NavIcon({
    required this.icon,
    required this.filledIcon,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isActive ? filledIcon : icon,
        color: isActive ? activeColor : inactiveColor,
      ),
      tooltip: '',
      style: IconButton.styleFrom(
        minimumSize: const Size(52, 52),
        padding: const EdgeInsets.all(12),
        shape: const CircleBorder(),
      ),
    );
  }
}

// Today — AppBar with big title, scrollable category chips, quick filters and a timeline
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final Map<String, bool> _filters = {
    'Ongoing': true,
    'Upcoming': true,
    'Completed': false,
    'Missed': false,
    'Online': false,
    'In-person': false,
  };

  // Helper method to get day name abbreviation
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

  List<_TimelineItem> _getItems(ColorScheme colorScheme) => [
    // Use theme colors instead of hardcoded Colors
    _TimelineItem(
      time: '08:30',
      title: 'Breakfast & Prep',
      subtitle: 'Quick review of CS101 notes',
      accent: colorScheme.tertiary, // Was Colors.teal
    ),
    _TimelineItem(
      time: '10:00',
      title: 'CS101 Lecture',
      subtitle: 'Room 204 • Prof. Lee',
      accent: colorScheme.primary, // Was Colors.indigo
      highlight: true,
    ),
    _TimelineItem(
      time: '12:00',
      title: 'Study Hall',
      subtitle: 'Library 2F • Algorithms practice',
      accent: colorScheme.secondary, // Was Colors.orange
    ),
    _TimelineItem(
      time: '14:00',
      title: 'Math Assignment',
      subtitle: 'Calculus HW due 6 PM',
      accent: colorScheme.tertiary, // Was Colors.pink
    ),
    _TimelineItem(
      time: '16:00',
      title: 'Club Meeting',
      subtitle: 'AI Club weekly sync',
      accent: colorScheme.secondary, // Was Colors.green
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    final items = _getItems(colorScheme);

    // Generate list of days starting from tomorrow (since Today is separate)
    final weekDays = <String>[];
    for (int i = 1; i <= 6; i++) {
      final date = now.add(Duration(days: i));
      weekDays.add(_getDayName(date.weekday));
    }

    return Scaffold(
      // Material 3: Use surface color for background
      backgroundColor: colorScheme.surface,
      // Material 3: Medium top app bar with proper elevation
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        backgroundColor: colorScheme.surface,
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
                // Material 3: Display text style for heading
                Text(
                  'Today',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 24),
                // Material 3: Assist chips for days
                for (var dayName in weekDays)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(dayName),
                      labelStyle: theme.textTheme.labelLarge,
                      side: BorderSide.none,
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      onPressed: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Material 3: Events with proper card elevation and surfaces
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _M3EventCard(item: item),
            ),
          const SizedBox(height: 32),
          // Material 3: Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Quick filters',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Material 3: Filter chips with proper styling
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in _filters.entries)
                FilterChip(
                  label: Text(e.key),
                  selected: e.value,
                  onSelected: (v) => setState(() => _filters[e.key] = v),
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  selectedColor: colorScheme.secondaryContainer,
                  checkmarkColor: colorScheme.onSecondaryContainer,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: e.value
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TimelineItem {
  final String time;
  final String title;
  final String subtitle;
  final bool highlight;
  final Color accent;
  const _TimelineItem({
    required this.time,
    required this.title,
    required this.subtitle,
    this.highlight = false,
    required this.accent, // No default - must come from theme
  });
}

// Material 3 compliant event card - fully theme-driven
class _M3EventCard extends StatelessWidget {
  final _TimelineItem item;
  const _M3EventCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardTheme = theme.cardTheme;

    // Use theme colors directly - no opacity manipulation
    final accentColor = item.highlight ? colorScheme.primary : item.accent;
    final cardColor = item.highlight
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerLow;

    return Card(
      // Material 3: Use theme-based elevation
      elevation: item.highlight ? 2 : 0,
      surfaceTintColor: cardTheme.surfaceTintColor,
      color: cardColor,
      margin: EdgeInsets.zero,
      // Use the theme's card shape (24px radius from super_amoled_theme)
      shape: item.highlight
          ? cardTheme.shape
          : RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              // Material 3: Subtle outline for non-elevated cards
              side: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Material 3: Small icon for category/type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event_outlined,
                      size: 20,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time with proper typography
                  Text(
                    item.time,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Material 3: Badge for current event
                  if (item.highlight)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NOW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Material 3: Title with proper hierarchy
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Material 3: Supporting text with icon
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed legacy bottom sheets and session tiles that are no longer used on Today screen.

// Notes list and editor (frontend only) - All styling from theme
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () => _showNoteActions(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Chips use theme styling automatically
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Lectures'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Highlights'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Flashcards'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cards use theme styling (24px radius, theme colors)
          ...List.generate(
            5,
            (i) => Card(
              child: ListTile(
                title: Text('Note ${i + 1}: Blog style with images'),
                subtitle: const Text('Updated 2h ago · CS101'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
      // FAB uses theme (20px squircle radius, primary blue)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NoteEditorScreen())),
        icon: const Icon(Icons.edit),
        label: const Text('New note'),
      ),
    );
  }

  void _showNoteActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // ActionChips use theme styling automatically
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.link),
                  label: const Text('From Link'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.picture_as_pdf),
                  label: const Text('From PDF'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.ondemand_video),
                  label: const Text('From YouTube'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.mic),
                  label: const Text('From Audio'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showAiSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HeadingField(),
          SizedBox(height: 12),
          _ToolbarChips(),
          SizedBox(height: 12),
          _BodyField(),
        ],
      ),
    );
  }

  void _showAiSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Suggestions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // ActionChips use theme styling
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.summarize),
                  label: const Text('Summarize'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.highlight),
                  label: const Text('Create Highlights'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.style),
                  label: const Text('Rewrite (Clarity)'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.translate),
                  label: const Text('Translate'),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.quiz),
                  label: const Text('Generate Flashcards'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            // FilterChips use theme styling
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Concise'),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Keep citations'),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Add examples'),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Preserve structure'),
                  selected: true,
                  onSelected: (_) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// TextField uses theme's inputDecorationTheme (16px radius)
class _HeadingField extends StatelessWidget {
  const _HeadingField();
  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        hintText: 'Note title',
        // No border override - uses theme's 16px radius
      ),
    );
  }
}

// InputChips use theme styling
class _ToolbarChips extends StatelessWidget {
  const _ToolbarChips();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: const [
        InputChip(label: Text('H1')),
        InputChip(label: Text('H2')),
        InputChip(label: Text('Bold')),
        InputChip(label: Text('Quote')),
        InputChip(label: Text('Image')),
        InputChip(label: Text('Callout')),
        InputChip(label: Text('Checklist')),
      ],
    );
  }
}

// TextField uses theme's inputDecorationTheme (16px radius)
class _BodyField extends StatelessWidget {
  const _BodyField();
  @override
  Widget build(BuildContext context) {
    return const TextField(
      maxLines: 16,
      decoration: InputDecoration(
        hintText:
            'Write in a clean, blog-style format. Use headings, images, and callouts.',
        // No border override - uses theme's 16px radius
      ),
    );
  }
}

// ============================================================================
// CALENDAR SCREEN - Full-featured calendar with multiple views
// ============================================================================

enum CalendarView { yearly, monthly, weekly, daily }

enum EventCategory { classes, assignments, exams, personal, meetings, other }

enum Priority { high, medium, low }

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final EventCategory category;
  final Priority priority;
  final String? description;
  final String? location;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.priority = Priority.medium,
    this.description,
    this.location,
    this.isAllDay = false,
  });

  Color get categoryColor {
    switch (category) {
      case EventCategory.classes:
        return const Color(0xFF64B5F6); // Blue
      case EventCategory.assignments:
        return const Color(0xFFFF9800); // Orange
      case EventCategory.exams:
        return const Color(0xFFEF5350); // Red
      case EventCategory.personal:
        return const Color(0xFF66BB6A); // Green
      case EventCategory.meetings:
        return const Color(0xFFAB47BC); // Purple
      case EventCategory.other:
        return const Color(0xFF78909C); // Gray
    }
  }

  String get categoryName {
    switch (category) {
      case EventCategory.classes:
        return 'Classes';
      case EventCategory.assignments:
        return 'Assignments';
      case EventCategory.exams:
        return 'Exams';
      case EventCategory.personal:
        return 'Personal';
      case EventCategory.meetings:
        return 'Meetings';
      case EventCategory.other:
        return 'Other';
    }
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarView _currentView = CalendarView.monthly;
  DateTime _focusedDate = DateTime.now();
  Set<EventCategory> _selectedCategories = EventCategory.values.toSet();
  Set<Priority> _selectedPriorities = Priority.values.toSet();

  // Sample events for demonstration
  final List<CalendarEvent> _events = [
    CalendarEvent(
      id: '1',
      title: 'Math Class',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      category: EventCategory.classes,
      priority: Priority.high,
      location: 'Room 301',
    ),
    CalendarEvent(
      id: '2',
      title: 'Physics Assignment',
      startTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
      category: EventCategory.assignments,
      priority: Priority.high,
      description: 'Complete chapters 5-7 problems',
    ),
    CalendarEvent(
      id: '3',
      title: 'Chemistry Exam',
      startTime: DateTime.now().add(const Duration(days: 5)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 2)),
      category: EventCategory.exams,
      priority: Priority.high,
      location: 'Main Hall',
    ),
  ];

  List<CalendarEvent> get _filteredEvents {
    return _events.where((event) {
      final categoryMatch = _selectedCategories.contains(event.category);
      final priorityMatch = _selectedPriorities.contains(event.priority);
      return categoryMatch && priorityMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: cs.surfaceContainerLowest,
            title: Text('Calendar', style: textTheme.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () {
                  setState(() => _focusedDate = DateTime.now());
                },
                tooltip: 'Go to today',
              ),
            ],
          ),

          // Chip Filters
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // View mode chips
                  FilterChip(
                    label: const Text('Year'),
                    avatar: const Icon(Icons.calendar_view_month, size: 16),
                    selected: _currentView == CalendarView.yearly,
                    onSelected: (_) {
                      setState(() => _currentView = CalendarView.yearly);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Month'),
                    avatar: const Icon(Icons.calendar_month, size: 16),
                    selected: _currentView == CalendarView.monthly,
                    onSelected: (_) {
                      setState(() => _currentView = CalendarView.monthly);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Week'),
                    avatar: const Icon(Icons.view_week, size: 16),
                    selected: _currentView == CalendarView.weekly,
                    onSelected: (_) {
                      setState(() => _currentView = CalendarView.weekly);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Day'),
                    avatar: const Icon(Icons.view_day, size: 16),
                    selected: _currentView == CalendarView.daily,
                    onSelected: (_) {
                      setState(() => _currentView = CalendarView.daily);
                    },
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 1,
                    height: 24,
                    color: cs.outline.withOpacity(0.3),
                  ),
                  const SizedBox(width: 16),
                  // Category filter
                  ActionChip(
                    label: Text('Categories (${_selectedCategories.length})'),
                    avatar: const Icon(Icons.label_outline, size: 16),
                    onPressed: () => _showCategoryFilter(context),
                  ),
                  const SizedBox(width: 8),
                  // Priority filter
                  ActionChip(
                    label: Text('Priority (${_selectedPriorities.length})'),
                    avatar: const Icon(Icons.flag_outlined, size: 16),
                    onPressed: () => _showPriorityFilter(context),
                  ),
                ],
              ),
            ),
          ),

          // Date navigation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _navigateDate(-1),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(_getDateTitle(), style: textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _navigateDate(1),
                  ),
                ],
              ),
            ),
          ),

          // Calendar view content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildCalendarView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  String _getDateTitle() {
    switch (_currentView) {
      case CalendarView.yearly:
        return '${_focusedDate.year}';
      case CalendarView.monthly:
        return '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}';
      case CalendarView.weekly:
        final startOfWeek = _getStartOfWeek(_focusedDate);
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${_getMonthName(startOfWeek.month)} ${startOfWeek.day} - ${_getMonthName(endOfWeek.month)} ${endOfWeek.day}';
      case CalendarView.daily:
        return '${_getMonthName(_focusedDate.month)} ${_focusedDate.day}, ${_focusedDate.year}';
    }
  }

  void _navigateDate(int direction) {
    setState(() {
      switch (_currentView) {
        case CalendarView.yearly:
          _focusedDate = DateTime(
            _focusedDate.year + direction,
            _focusedDate.month,
            _focusedDate.day,
          );
          break;
        case CalendarView.monthly:
          _focusedDate = DateTime(
            _focusedDate.year,
            _focusedDate.month + direction,
            _focusedDate.day,
          );
          break;
        case CalendarView.weekly:
          _focusedDate = _focusedDate.add(Duration(days: 7 * direction));
          break;
        case CalendarView.daily:
          _focusedDate = _focusedDate.add(Duration(days: direction));
          break;
      }
    });
  }

  Widget _buildCalendarView() {
    switch (_currentView) {
      case CalendarView.yearly:
        return _buildYearlyView();
      case CalendarView.monthly:
        return _buildMonthlyView();
      case CalendarView.weekly:
        return _buildWeeklyView();
      case CalendarView.daily:
        return _buildDailyView();
    }
  }

  // ========== YEARLY VIEW ==========
  Widget _buildYearlyView() {
    final textTheme = Theme.of(context).textTheme;

    return SliverList(
      delegate: SliverChildListDelegate([
        // Year overview with minimal design
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final monthDate = DateTime(_focusedDate.year, month, 1);
            return _buildMinimalMonthCard(monthDate);
          },
        ),
        const SizedBox(height: 24),
        // Legend for dots
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legend', style: textTheme.titleSmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildLegendDot(const Color(0xFF64B5F6)),
                    const SizedBox(width: 8),
                    Text('Events', style: textTheme.bodySmall),
                    const SizedBox(width: 24),
                    _buildLegendDot(const Color(0xFFFF9800)),
                    const SizedBox(width: 8),
                    Text('Holidays', style: textTheme.bodySmall),
                    const SizedBox(width: 24),
                    _buildLegendDot(const Color(0xFF66BB6A)),
                    const SizedBox(width: 8),
                    Text('Seasons', style: textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildMinimalMonthCard(DateTime monthDate) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monthEvents = _events
        .where(
          (e) =>
              e.startTime.year == monthDate.year &&
              e.startTime.month == monthDate.month,
        )
        .length;

    // Check for holidays and seasons
    final hasHoliday = _isHolidayMonth(monthDate.month);
    final seasonColor = _getSeasonColor(monthDate.month);

    return GestureDetector(
      onTap: () {
        setState(() {
          _focusedDate = monthDate;
          _currentView = CalendarView.monthly;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMonthNameShort(monthDate.month),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (monthEvents > 0) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (hasHoliday) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (seasonColor != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: seasonColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            if (monthEvents > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$monthEvents ${monthEvents == 1 ? 'event' : 'events'}',
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _getMonthNameShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  bool _isHolidayMonth(int month) {
    // Common holiday months (customize based on your locale)
    return month == 12 || month == 1 || month == 7; // Dec, Jan, July
  }

  Color? _getSeasonColor(int month) {
    // Northern Hemisphere seasons
    if (month >= 3 && month <= 5)
      return const Color(0xFF66BB6A); // Spring - Green
    if (month >= 6 && month <= 8)
      return const Color(0xFFFFEE58); // Summer - Yellow
    if (month >= 9 && month <= 11)
      return const Color(0xFFFF9800); // Fall - Orange
    if (month == 12 || month == 1 || month == 2)
      return const Color(0xFF42A5F5); // Winter - Blue
    return null;
  }

  // ========== MONTHLY VIEW ==========
  Widget _buildMonthlyView() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final daysInMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    ).day;
    final firstWeekday = DateTime(
      _focusedDate.year,
      _focusedDate.month,
      1,
    ).weekday;

    // Calculate month statistics
    final monthEvents = _filteredEvents
        .where(
          (e) =>
              e.startTime.year == _focusedDate.year &&
              e.startTime.month == _focusedDate.month,
        )
        .toList();
    final highPriorityCount = monthEvents
        .where((e) => e.priority == Priority.high)
        .length;
    final upcomingCount = monthEvents
        .where((e) => e.startTime.isAfter(DateTime.now()))
        .length;

    return SliverList(
      delegate: SliverChildListDelegate([
        // Weekday headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.8,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: daysInMonth + firstWeekday - 1,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox();
            }
            final day = index - firstWeekday + 2;
            final date = DateTime(_focusedDate.year, _focusedDate.month, day);
            final dayEvents = _getEventsForDate(date);
            final isToday = _isToday(date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _focusedDate = date;
                  _currentView = CalendarView.daily;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isToday
                      ? cs.primary.withOpacity(0.1)
                      : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(color: cs.primary, width: 2)
                      : null,
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$day',
                      style: textTheme.titleSmall?.copyWith(
                        color: isToday ? cs.primary : cs.onSurface,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dayEvents.length > 3 ? 3 : dayEvents.length,
                        itemBuilder: (context, i) {
                          if (i == 2 && dayEvents.length > 3) {
                            return Text(
                              '+${dayEvents.length - 2} more',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                                color: cs.primary,
                              ),
                            );
                          }
                          return Container(
                            height: 12,
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              color: dayEvents[i].categoryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Month Summary Section
        Text(
          'Month Summary',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.event, color: cs.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '${monthEvents.length}',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Total Events',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.priority_high,
                        color: const Color(0xFFEF5350),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$highPriorityCount',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'High Priority',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upcoming,
                        color: const Color(0xFF66BB6A),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$upcomingCount',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Upcoming',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Category Breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By Category', style: textTheme.titleSmall),
                const SizedBox(height: 12),
                ...EventCategory.values.map((category) {
                  final categoryEvents = monthEvents
                      .where((e) => e.category == category)
                      .length;
                  if (categoryEvents == 0) return const SizedBox.shrink();

                  final event = CalendarEvent(
                    id: '',
                    title: '',
                    startTime: DateTime.now(),
                    endTime: DateTime.now(),
                    category: category,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: event.categoryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            event.categoryName,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '$categoryEvents',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ========== WEEKLY VIEW ==========
  Widget _buildWeeklyView() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final startOfWeek = _getStartOfWeek(_focusedDate);

    return SliverList(
      delegate: SliverChildListDelegate([
        // Time slots grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 60,
              child: Column(
                children: List.generate(24, (hour) {
                  return SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Days columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final date = startOfWeek.add(Duration(days: dayIndex));
                    final dayEvents = _getEventsForDate(date);
                    final isToday = _isToday(date);

                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 4),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? cs.primary
                                  : cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getDayNameShort(date.weekday),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isToday
                                        ? cs.onPrimary
                                        : cs.onSurface,
                                  ),
                                ),
                                Text(
                                  '${date.day}',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: isToday
                                        ? cs.onPrimary
                                        : cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Time slots
                          Stack(
                            children: [
                              // Hour lines
                              Column(
                                children: List.generate(24, (hour) {
                                  return Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: cs.outline.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              // Events
                              ...dayEvents.map((event) {
                                final startHour =
                                    event.startTime.hour +
                                    event.startTime.minute / 60;
                                final duration =
                                    event.endTime
                                        .difference(event.startTime)
                                        .inMinutes /
                                    60;
                                return Positioned(
                                  top: startHour * 60,
                                  left: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _showEventDetails(event),
                                    child: Container(
                                      height: duration * 60,
                                      decoration: BoxDecoration(
                                        color: event.categoryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        event.title,
                                        style: textTheme.bodySmall?.copyWith(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  // ========== DAILY VIEW ==========
  Widget _buildDailyView() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dayEvents = _getEventsForDate(_focusedDate);

    return SliverList(
      delegate: SliverChildListDelegate([
        // All-day events
        if (dayEvents.any((e) => e.isAllDay)) ...[
          Text('All Day', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          ...dayEvents
              .where((e) => e.isAllDay)
              .map((event) => _buildEventCard(event)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
        ],

        // Timeline
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 60,
              child: Column(
                children: List.generate(24, (hour) {
                  return SizedBox(
                    height: 80,
                    child: Center(
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Events column
            Expanded(
              child: Stack(
                children: [
                  // Hour lines
                  Column(
                    children: List.generate(24, (hour) {
                      return Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: cs.outline.withOpacity(0.3)),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Events
                  ...dayEvents.where((e) => !e.isAllDay).map((event) {
                    final startHour =
                        event.startTime.hour + event.startTime.minute / 60;
                    final duration =
                        event.endTime.difference(event.startTime).inMinutes /
                        60;
                    return Positioned(
                      top: startHour * 80,
                      left: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _showEventDetails(event),
                        child: Container(
                          height: duration * 80,
                          decoration: BoxDecoration(
                            color: event.categoryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _buildPriorityBadge(event.priority),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                              if (event.location != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.location!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: event.categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: textTheme.titleMedium,
                          ),
                        ),
                        _buildPriorityBadge(event.priority),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.categoryName,
                      style: textTheme.bodySmall?.copyWith(
                        color: event.categoryColor,
                      ),
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

  Widget _buildPriorityBadge(Priority priority) {
    Color color;
    String label;
    switch (priority) {
      case Priority.high:
        color = const Color(0xFFEF5350);
        label = 'HIGH';
        break;
      case Priority.medium:
        color = const Color(0xFFFF9800);
        label = 'MED';
        break;
      case Priority.low:
        color = const Color(0xFF66BB6A);
        label = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ========== HELPER METHODS ==========
  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return _filteredEvents.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getDayNameShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  // ========== DIALOGS ==========
  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _focusedDate = picked);
    }
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedCategories.length ==
                          EventCategory.values.length) {
                        _selectedCategories.clear();
                      } else {
                        _selectedCategories = EventCategory.values.toSet();
                      }
                    });
                  },
                  child: Text(
                    _selectedCategories.length == EventCategory.values.length
                        ? 'Clear All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventCategory.values.map((category) {
                final event = CalendarEvent(
                  id: '',
                  title: '',
                  startTime: DateTime.now(),
                  endTime: DateTime.now(),
                  category: category,
                );
                return FilterChip(
                  label: Text(event.categoryName),
                  selected: _selectedCategories.contains(category),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  avatar: CircleAvatar(
                    backgroundColor: event.categoryColor,
                    radius: 8,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Priority',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedPriorities.length ==
                          Priority.values.length) {
                        _selectedPriorities.clear();
                      } else {
                        _selectedPriorities = Priority.values.toSet();
                      }
                    });
                  },
                  child: Text(
                    _selectedPriorities.length == Priority.values.length
                        ? 'Clear All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Priority.values.map((priority) {
                Color color;
                switch (priority) {
                  case Priority.high:
                    color = const Color(0xFFEF5350);
                    break;
                  case Priority.medium:
                    color = const Color(0xFFFF9800);
                    break;
                  case Priority.low:
                    color = const Color(0xFF66BB6A);
                    break;
                }

                return FilterChip(
                  label: Text(priority.name.toUpperCase()),
                  selected: _selectedPriorities.contains(priority),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPriorities.add(priority);
                      } else {
                        _selectedPriorities.remove(priority);
                      }
                    });
                  },
                  avatar: Icon(Icons.flag, size: 16, color: color),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: event.categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.categoryName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: event.categoryColor),
                        ),
                      ],
                    ),
                  ),
                  _buildPriorityBadge(event.priority),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.access_time,
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              ),
              if (event.location != null)
                _buildDetailRow(Icons.location_on, event.location!),
              if (event.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(event.description!),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Edit event
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Delete event
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    EventCategory selectedCategory = EventCategory.classes;
    Priority selectedPriority = Priority.medium;
    bool isAllDay = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: EventCategory.values.map((category) {
                    final event = CalendarEvent(
                      id: '',
                      title: '',
                      startTime: DateTime.now(),
                      endTime: DateTime.now(),
                      category: category,
                    );
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: event.categoryColor,
                            radius: 8,
                          ),
                          const SizedBox(width: 12),
                          Text(event.categoryName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: Priority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('All Day'),
                  value: isAllDay,
                  onChanged: (value) {
                    setDialogState(() => isAllDay = value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Add event logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event added successfully!')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// AI Assist (frontend only) - All styling from theme
class AiAssistScreen extends StatelessWidget {
  const AiAssistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Quick Suggestions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          // ActionChips use theme styling
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.summarize),
                label: const Text('Summarize from Link'),
                onPressed: () {},
              ),
              ActionChip(
                avatar: const Icon(Icons.picture_as_pdf),
                label: const Text('Summarize PDF'),
                onPressed: () {},
              ),
              ActionChip(
                avatar: const Icon(Icons.ondemand_video),
                label: const Text('Summarize YouTube'),
                onPressed: () {},
              ),
              ActionChip(
                avatar: const Icon(Icons.highlight),
                label: const Text('Extract Highlights'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Personalization',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // FilterChips use theme styling
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Concise'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Academic'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Keep citations'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Add examples'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Flashcards'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          // FilledButton uses theme styling
          FilledButton.icon(
            onPressed: () => _showAiInputSheet(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showAiInputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Source'),
            SizedBox(height: 8),
            // TextField uses theme (16px radius)
            TextField(
              decoration: InputDecoration(
                hintText: 'Paste link / pick file (mock)',
                // No border override - uses theme
              ),
            ),
            SizedBox(height: 12),
            Text('This is a frontend-only prototype. No data is uploaded.'),
          ],
        ),
      ),
    );
  }
}
