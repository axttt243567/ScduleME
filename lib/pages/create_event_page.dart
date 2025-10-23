import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

/// Page for creating new events with comprehensive options
class CreateEventPage extends StatefulWidget {
  final DateTime? initialDate;
  final Event? editEvent;

  const CreateEventPage({super.key, this.initialDate, this.editEvent});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  int _durationMinutes = 60;
  bool _isAllDay = false;
  EventPriority _priority = EventPriority.medium;
  RepetitionPattern _repetitionPattern = RepetitionPattern.none;
  List<int> _customWeekdays = [];
  Set<String> _selectedCategories = {};
  IconData _selectedIcon = Icons.event;

  @override
  void initState() {
    super.initState();

    if (widget.editEvent != null) {
      // Editing existing event
      final event = widget.editEvent!;
      _titleController.text = event.title;
      _notesController.text = event.notes ?? '';
      _startDate = event.startDate;
      _endDate = event.endDate;
      _startTime = event.startTime;
      _durationMinutes = event.durationMinutes ?? 60;
      _isAllDay = event.isAllDay;
      _priority = event.priority;
      _repetitionPattern = event.repetitionPattern;
      _customWeekdays = event.customWeekdays ?? [];
      _selectedCategories = Set.from(event.categoryIds);
      _selectedIcon = event.icon;
    } else {
      // New event
      _startDate = widget.initialDate ?? DateTime.now();
      _startTime = TimeOfDay.now();
      _selectedCategories.add(Categories.academic.id);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 1)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _IconPickerSheet(
        selectedIcon: _selectedIcon,
        onIconSelected: (icon) {
          setState(() {
            _selectedIcon = icon;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CategoryPickerSheet(
        selectedCategories: _selectedCategories,
        onCategoriesChanged: (categories) {
          setState(() {
            _selectedCategories = categories;
          });
        },
      ),
    );
  }

  void _showWeekdayPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _WeekdayPickerSheet(
        selectedWeekdays: _customWeekdays,
        onWeekdaysChanged: (weekdays) {
          setState(() {
            _customWeekdays = weekdays;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final event = Event(
      id: widget.editEvent?.id,
      title: _titleController.text.trim(),
      categoryIds: _selectedCategories.toList(),
      priority: _priority,
      startDate: _startDate,
      endDate: _endDate,
      isAllDay: _isAllDay,
      startTime: _isAllDay ? null : _startTime,
      durationMinutes: _isAllDay ? null : _durationMinutes,
      repetitionPattern: _repetitionPattern,
      customWeekdays: _repetitionPattern == RepetitionPattern.custom
          ? _customWeekdays
          : null,
      icon: _selectedIcon,
      remark: widget.editEvent?.remark ?? EventRemark.none,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      if (widget.editEvent != null) {
        await context.read<EventProvider>().updateEvent(event);
      } else {
        await context.read<EventProvider>().createEvent(event);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving event: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.editEvent != null;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest, // Pure black X-style
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest, // Pure black
        surfaceTintColor: Colors.transparent,
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
        actions: [
          TextButton.icon(
            onPressed: _saveEvent,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Icon selector
            Card(
              child: InkWell(
                onTap: _showIconPicker,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(_selectedIcon, size: 32, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Event Icon',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category selector
            Card(
              child: InkWell(
                onTap: _showCategoryPicker,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category, color: colorScheme.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Categories',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      if (_selectedCategories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final catId in _selectedCategories)
                              Builder(
                                builder: (context) {
                                  final cat = Categories.getById(catId);
                                  return Chip(
                                    avatar: Icon(cat.icon, size: 16),
                                    label: Text(cat.name),
                                    backgroundColor: cat.color.withOpacity(0.2),
                                    labelStyle: TextStyle(color: cat.color),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedCategories.remove(catId);
                                      });
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag, color: colorScheme.primary),
                        const SizedBox(width: 16),
                        Text('Priority', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: EventPriority.values.map((priority) {
                        final isSelected = _priority == priority;
                        return ChoiceChip(
                          label: Text(priority.displayName),
                          avatar: Icon(
                            priority.icon,
                            size: 16,
                            color: isSelected ? priority.color : null,
                          ),
                          selected: isSelected,
                          selectedColor: priority.color.withOpacity(0.3),
                          onSelected: (selected) {
                            setState(() {
                              _priority = priority;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: colorScheme.primary),
                        const SizedBox(width: 16),
                        Text('Date & Time', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Start date
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Start Date'),
                      subtitle: Text(
                        DateFormat('EEEE, MMMM d, y').format(_startDate),
                      ),
                      onTap: _selectStartDate,
                      contentPadding: EdgeInsets.zero,
                    ),
                    // End date (optional)
                    ListTile(
                      leading: const Icon(Icons.event_repeat),
                      title: const Text('End Date (Multi-day)'),
                      subtitle: Text(
                        _endDate != null
                            ? DateFormat('EEEE, MMMM d, y').format(_endDate!)
                            : 'Not set',
                      ),
                      trailing: _endDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _endDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: _selectEndDate,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    // All day switch
                    SwitchListTile(
                      title: const Text('All Day'),
                      subtitle: const Text('Event lasts the entire day'),
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    // Time picker (if not all day)
                    if (!_isAllDay) ...[
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Start Time'),
                        subtitle: Text(
                          _startTime != null
                              ? _startTime!.format(context)
                              : 'Not set',
                        ),
                        onTap: _selectStartTime,
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.timer),
                        title: const Text('Duration'),
                        subtitle: Text('$_durationMinutes minutes'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      Slider(
                        value: _durationMinutes.toDouble(),
                        min: 15,
                        max: 480,
                        divisions: 31,
                        label: '$_durationMinutes min',
                        onChanged: (value) {
                          setState(() {
                            _durationMinutes = value.toInt();
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Repetition section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.repeat, color: colorScheme.primary),
                        const SizedBox(width: 16),
                        Text('Repetition', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final pattern in RepetitionPattern.values)
                          ChoiceChip(
                            label: Text(pattern.displayName),
                            selected: _repetitionPattern == pattern,
                            onSelected: (selected) {
                              setState(() {
                                _repetitionPattern = pattern;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_repetitionPattern == RepetitionPattern.custom) ...[
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.calendar_view_week),
                        title: const Text('Select Days'),
                        subtitle: Text(
                          _customWeekdays.isEmpty
                              ? 'No days selected'
                              : _customWeekdays
                                    .map(
                                      (day) => [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun',
                                      ][day - 1],
                                    )
                                    .join(', '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showWeekdayPicker,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional notes here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Icon picker bottom sheet
class _IconPickerSheet extends StatelessWidget {
  final IconData selectedIcon;
  final Function(IconData) onIconSelected;

  const _IconPickerSheet({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  static final List<IconData> icons = [
    Icons.event,
    Icons.school,
    Icons.work,
    Icons.assignment,
    Icons.quiz,
    Icons.book,
    Icons.edit,
    Icons.science,
    Icons.calculate,
    Icons.language,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.music_note,
    Icons.brush,
    Icons.sports_soccer,
    Icons.directions_run,
    Icons.shopping_bag,
    Icons.movie,
    Icons.videogame_asset,
    Icons.flight,
    Icons.hotel,
    Icons.medication,
    Icons.favorite,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Icon', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: icons.length,
                  itemBuilder: (context, index) {
                    final icon = icons[index];
                    final isSelected = icon == selectedIcon;

                    return InkWell(
                      onTap: () => onIconSelected(icon),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Category picker bottom sheet
class _CategoryPickerSheet extends StatefulWidget {
  final Set<String> selectedCategories;
  final Function(Set<String>) onCategoriesChanged;

  const _CategoryPickerSheet({
    required this.selectedCategories,
    required this.onCategoriesChanged,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Categories', style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      widget.onCategoriesChanged(_selected);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in Categories.all)
                        FilterChip(
                          label: Text(category.name),
                          avatar: Icon(category.icon, size: 18),
                          selected: _selected.contains(category.id),
                          selectedColor: category.color.withOpacity(0.3),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selected.add(category.id);
                              } else {
                                _selected.remove(category.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Weekday picker bottom sheet
class _WeekdayPickerSheet extends StatefulWidget {
  final List<int> selectedWeekdays;
  final Function(List<int>) onWeekdaysChanged;

  const _WeekdayPickerSheet({
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
  });

  @override
  State<_WeekdayPickerSheet> createState() => _WeekdayPickerSheetState();
}

class _WeekdayPickerSheetState extends State<_WeekdayPickerSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedWeekdays);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final weekdays = [
      (1, 'Monday', 'Mon'),
      (2, 'Tuesday', 'Tue'),
      (3, 'Wednesday', 'Wed'),
      (4, 'Thursday', 'Thu'),
      (5, 'Friday', 'Fri'),
      (6, 'Saturday', 'Sat'),
      (7, 'Sunday', 'Sun'),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Repeat on', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final (day, name, abbr) in weekdays)
                      CheckboxListTile(
                        title: Text(name),
                        subtitle: Text(abbr),
                        value: _selected.contains(day),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selected.add(day);
                            } else {
                              _selected.remove(day);
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onWeekdaysChanged(_selected.toList()..sort());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
