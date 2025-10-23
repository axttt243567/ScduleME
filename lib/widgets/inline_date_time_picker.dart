import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Inline compact date picker that fits in a chat bubble
class InlineDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;
  final String? label;

  const InlineDatePicker({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.label,
  });

  @override
  State<InlineDatePicker> createState() => _InlineDatePickerState();
}

class _InlineDatePickerState extends State<InlineDatePicker> {
  late DateTime _selectedDate;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDay = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final days = <DateTime>[];

    // Add previous month's trailing days
    final firstWeekday = firstDay.weekday;
    for (var i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Add current month's days
    for (var i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_displayMonth.year, _displayMonth.month, i));
    }

    // Add next month's leading days to complete the week
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (var i = 1; i <= remainingDays; i++) {
        days.add(DateTime(_displayMonth.year, _displayMonth.month + 1, i));
      }
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final days = _getDaysInMonth();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.label!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                DateFormat.yMMMM().format(_displayMonth),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    day,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 4),

          // Calendar grid
          ...List.generate((days.length / 7).ceil(), (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final index = weekIndex * 7 + dayIndex;
                  if (index >= days.length) {
                    return const SizedBox(width: 32, height: 32);
                  }

                  final date = days[index];
                  final isCurrentMonth = date.month == _displayMonth.month;
                  final isSelected =
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isToday =
                      date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  return GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : isToday
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : isToday
                                ? colorScheme.onPrimaryContainer
                                : isCurrentMonth
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withOpacity(0.3),
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Quick selection buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickDateButton(
                  label: 'Today',
                  onPressed: () => _selectDate(DateTime.now()),
                ),
                const SizedBox(width: 8),
                _QuickDateButton(
                  label: 'Tomorrow',
                  onPressed: () =>
                      _selectDate(DateTime.now().add(const Duration(days: 1))),
                ),
                const SizedBox(width: 8),
                _QuickDateButton(
                  label: 'Next Week',
                  onPressed: () =>
                      _selectDate(DateTime.now().add(const Duration(days: 7))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickDateButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

/// Inline compact time picker that fits in a chat bubble
class InlineTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final String? label;

  const InlineTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
    this.label,
  });

  @override
  State<InlineTimePicker> createState() => _InlineTimePickerState();
}

class _InlineTimePickerState extends State<InlineTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  void _updateTime() {
    widget.onTimeSelected(
      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.label!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Time display and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour selector
              _TimeSelector(
                value: _selectedHour,
                maxValue: 23,
                onChanged: (value) {
                  setState(() => _selectedHour = value);
                  _updateTime();
                },
                label: 'Hour',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  ':',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Minute selector
              _TimeSelector(
                value: _selectedMinute,
                maxValue: 59,
                onChanged: (value) {
                  setState(() => _selectedMinute = value);
                  _updateTime();
                },
                label: 'Minute',
                step: 5, // 5-minute intervals
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick time selections
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickTimeButton(
                  label: 'Now',
                  onPressed: () {
                    final now = TimeOfDay.now();
                    setState(() {
                      _selectedHour = now.hour;
                      _selectedMinute = now.minute;
                    });
                    _updateTime();
                  },
                ),
                const SizedBox(width: 8),
                _QuickTimeButton(
                  label: '9:00 AM',
                  onPressed: () {
                    setState(() {
                      _selectedHour = 9;
                      _selectedMinute = 0;
                    });
                    _updateTime();
                  },
                ),
                const SizedBox(width: 8),
                _QuickTimeButton(
                  label: '2:00 PM',
                  onPressed: () {
                    setState(() {
                      _selectedHour = 14;
                      _selectedMinute = 0;
                    });
                    _updateTime();
                  },
                ),
                const SizedBox(width: 8),
                _QuickTimeButton(
                  label: '6:00 PM',
                  onPressed: () {
                    setState(() {
                      _selectedHour = 18;
                      _selectedMinute = 0;
                    });
                    _updateTime();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final int value;
  final int maxValue;
  final Function(int) onChanged;
  final String label;
  final int step;

  const _TimeSelector({
    required this.value,
    required this.maxValue,
    required this.onChanged,
    required this.label,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up),
          onPressed: () {
            final newValue = (value + step) > maxValue ? 0 : value + step;
            onChanged(newValue);
          },
          iconSize: 32,
        ),
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: () {
            final newValue = (value - step) < 0 ? maxValue : value - step;
            onChanged(newValue);
          },
          iconSize: 32,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickTimeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
