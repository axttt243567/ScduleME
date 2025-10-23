import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final Set<String> _selectedCategories = {};
  bool _selectionMode = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectionMode
              ? '${_selectedCategories.length} selected'
              : 'Manage Categories',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: Icon(Icons.delete, color: cs.error),
              onPressed: () => _showDeleteConfirmation(context, eventProvider),
            ),
            IconButton(
              icon: Icon(Icons.close, color: cs.onSurface),
              onPressed: () {
                setState(() {
                  _selectionMode = false;
                  _selectedCategories.clear();
                });
              },
            ),
          ] else ...[
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: cs.onSurface),
              onSelected: (value) {
                if (value == 'create') {
                  _showCreateCategoryDialog(context);
                } else if (value == 'select') {
                  setState(() {
                    _selectionMode = true;
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'create',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Create Category'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.check_box),
                      SizedBox(width: 8),
                      Text('Select Categories'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: cs.onPrimaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'View your categories and see how many events are associated with each',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Categories grid
          ...Categories.all.map((category) {
            final eventCount = eventProvider.events
                .where((event) => event.categoryIds.contains(category.id))
                .length;
            final isSelected = _selectedCategories.contains(category.id);

            return _CategoryManagementCard(
              category: category,
              eventCount: eventCount,
              isSelected: isSelected,
              selectionMode: _selectionMode,
              onSelectChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category.id);
                  } else {
                    _selectedCategories.remove(category.id);
                  }
                });
              },
              onTap: () {
                if (_selectionMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category.id);
                    } else {
                      _selectedCategories.add(category.id);
                    }
                  });
                } else {
                  _showCategoryDetails(context, category, eventCount);
                }
              },
            );
          }),

          const SizedBox(height: 100), // Space for nav bar
        ],
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Create Category', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Category creation is currently managed through the app configuration. This feature will be available in a future update.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    EventProvider eventProvider,
  ) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Delete Categories', style: TextStyle(color: cs.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete analytics from ${_selectedCategories.length} selected categor${_selectedCategories.length == 1 ? 'y' : 'ies'}?',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: cs.onErrorContainer, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will delete all events in selected categories',
                      style: TextStyle(
                        color: cs.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEventsFromCategories(context, eventProvider);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text('Delete', style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEventsFromCategories(
    BuildContext context,
    EventProvider eventProvider,
  ) async {
    final cs = Theme.of(context).colorScheme;
    int deletedCount = 0;

    for (final categoryId in _selectedCategories) {
      final eventsToDelete = eventProvider.events
          .where((event) => event.categoryIds.contains(categoryId))
          .toList();

      for (final event in eventsToDelete) {
        if (event.id != null) {
          await eventProvider.deleteEvent(event.id!);
          deletedCount++;
        }
      }
    }

    setState(() {
      _selectedCategories.clear();
      _selectionMode = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $deletedCount event(s)'),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  void _showCategoryDetails(
    BuildContext context,
    EventCategory category,
    int eventCount,
  ) {
    final cs = Theme.of(context).colorScheme;
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final categoryEvents = eventProvider.events
        .where((event) => event.categoryIds.contains(category.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, size: 32, color: category.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$eventCount ${eventCount == 1 ? 'event' : 'events'}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: cs.outlineVariant),

            // Events list
            Expanded(
              child: categoryEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: cs.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events in this category',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: categoryEvents.length,
                      itemBuilder: (context, index) {
                        final event = categoryEvents[index];
                        return _EventListItem(event: event, category: category);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryManagementCard extends StatelessWidget {
  final EventCategory category;
  final int eventCount;
  final VoidCallback onTap;
  final bool isSelected;
  final bool selectionMode;
  final ValueChanged<bool> onSelectChanged;

  const _CategoryManagementCard({
    required this.category,
    required this.eventCount,
    required this.onTap,
    required this.isSelected,
    required this.selectionMode,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => onSelectChanged(value ?? false),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, size: 28, color: category.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$eventCount ${eventCount == 1 ? 'event' : 'events'}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: category.color.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      eventCount.toString(),
                      style: TextStyle(
                        color: category.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Event event;
  final EventCategory category;

  const _EventListItem({required this.event, required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cs.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(event.icon, size: 20, color: category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      if (!event.isAllDay && event.startTime != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.startTime!.format(context),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: event.priority.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                event.priority.displayName,
                style: TextStyle(
                  color: event.priority.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
