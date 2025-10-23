import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

/// Event detail and editing page
class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.event.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateRemark(EventRemark remark) async {
    await context.read<EventProvider>().updateEventRemark(
      widget.event.id!,
      remark,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event marked as ${remark.displayName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<EventProvider>().deleteEvent(widget.event.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final event = widget.event;

    final mainCategory = event.categoryIds.isNotEmpty
        ? Categories.getById(event.categoryIds.first)
        : Categories.other;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest, // Pure black X-style
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest, // Pure black
        surfaceTintColor: Colors.transparent,
        title: Text('Event Details', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event header card
          Card(
            color: mainCategory.color.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(event.icon, size: 32, color: mainCategory.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Priority
                  _DetailRow(
                    icon: event.priority.icon,
                    label: 'Priority',
                    value: event.priority.displayName,
                    color: event.priority.color,
                  ),
                  const SizedBox(height: 8),
                  // Date
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: event.endDate != null
                        ? '${DateFormat('MMM d, y').format(event.startDate)} - ${DateFormat('MMM d, y').format(event.endDate!)}'
                        : DateFormat('EEEE, MMMM d, y').format(event.startDate),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  // Time
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: event.getTimeString(),
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  // Repetition
                  if (event.repetitionPattern != RepetitionPattern.none)
                    _DetailRow(
                      icon: Icons.repeat,
                      label: 'Repeats',
                      value: _getRepetitionString(event),
                      color: colorScheme.tertiary,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories section
          Text(
            'Categories',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final categoryId in event.categoryIds)
                Builder(
                  builder: (context) {
                    final category = Categories.getById(categoryId);
                    return Chip(
                      avatar: Icon(
                        category.icon,
                        size: 18,
                        color: category.color,
                      ),
                      label: Text(category.name),
                      backgroundColor: category.color.withOpacity(0.2),
                      labelStyle: TextStyle(color: category.color),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes section
          Text(
            'Notes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add notes here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),

          // Quick actions section
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RemarkButton(
                  remark: EventRemark.done,
                  isSelected: event.remark == EventRemark.done,
                  onPressed: () => _updateRemark(EventRemark.done),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RemarkButton(
                  remark: EventRemark.skip,
                  isSelected: event.remark == EventRemark.skip,
                  onPressed: () => _updateRemark(EventRemark.skip),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _RemarkButton(
                  remark: EventRemark.missed,
                  isSelected: event.remark == EventRemark.missed,
                  onPressed: () => _updateRemark(EventRemark.missed),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RemarkButton(
                  remark: EventRemark.none,
                  isSelected: event.remark == EventRemark.none,
                  onPressed: () => _updateRemark(EventRemark.none),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRepetitionString(Event event) {
    switch (event.repetitionPattern) {
      case RepetitionPattern.daily:
        return 'Every day';
      case RepetitionPattern.weekly:
        return 'Every ${DateFormat('EEEE').format(event.startDate)}';
      case RepetitionPattern.custom:
        if (event.customWeekdays == null || event.customWeekdays!.isEmpty) {
          return 'Custom';
        }
        final days = event.customWeekdays!
            .map((day) {
              switch (day) {
                case 1:
                  return 'Mon';
                case 2:
                  return 'Tue';
                case 3:
                  return 'Wed';
                case 4:
                  return 'Thu';
                case 5:
                  return 'Fri';
                case 6:
                  return 'Sat';
                case 7:
                  return 'Sun';
                default:
                  return '';
              }
            })
            .join(', ');
        return 'Every $days';
      case RepetitionPattern.none:
        return 'Does not repeat';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RemarkButton extends StatelessWidget {
  final EventRemark remark;
  final bool isSelected;
  final VoidCallback onPressed;

  const _RemarkButton({
    required this.remark,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(remark.icon, size: 20),
      label: Text(remark.displayName),
      style: FilledButton.styleFrom(
        backgroundColor: isSelected
            ? remark.color
            : colorScheme.surfaceContainerHigh,
        foregroundColor: isSelected ? Colors.white : colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
