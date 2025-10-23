import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';
import 'event_detail_page.dart';
import '../models/category.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eventProvider = Provider.of<EventProvider>(context);

    // Filter events based on search and category
    List<Event> filteredEvents = eventProvider.events;

    if (_selectedCategory != 'all') {
      filteredEvents = filteredEvents
          .where((event) => event.categoryIds.contains(_selectedCategory))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents
          .where(
            (event) =>
                event.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (event.notes?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // Sort by date (newest first)
    filteredEvents.sort((a, b) => b.startDate.compareTo(a.startDate));

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
          'Manage Events',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              // Category filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('all', 'All', Icons.all_inclusive, cs),
                    ...Categories.all.map(
                      (category) => _buildCategoryChip(
                        category.id,
                        category.name,
                        category.icon,
                        cs,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: eventProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : filteredEvents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty || _selectedCategory != 'all'
                        ? 'No events found'
                        : 'No events yet',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty || _selectedCategory != 'all'
                        ? 'Try a different search or filter'
                        : 'Create your first event to get started',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return _EventManagementCard(
                  event: event,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: event),
                      ),
                    );
                    // Refresh if event was modified
                    if (result == true) {
                      await eventProvider.loadEvents();
                    }
                  },
                  onDelete: () async {
                    final confirmed = await _showDeleteConfirmation(
                      context,
                      event,
                    );
                    if (confirmed == true) {
                      await eventProvider.deleteEvent(event.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Event "${event.title}" deleted'),
                            backgroundColor: cs.error,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create event page (you may need to import and navigate)
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create event from Today or Calendar page'),
            ),
          );
        },
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildCategoryChip(
    String id,
    String label,
    IconData icon,
    ColorScheme cs,
  ) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() => _selectedCategory = id);
        },
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        labelStyle: TextStyle(
          color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: cs.onPrimaryContainer,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Event event) {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Delete Event?', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text('Delete', style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );
  }
}

class _EventManagementCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EventManagementCard({
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final category = Categories.all.firstWhere(
      (c) => event.categoryIds.contains(c.id),
      orElse: () => Categories.academic,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cs.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(event.icon, size: 24, color: category.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              category.icon,
                              size: 14,
                              color: category.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: category.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: cs.error),
                    onPressed: onDelete,
                    tooltip: 'Delete event',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(event.startDate),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  if (!event.isAllDay && event.startTime != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.startTime!.format(context),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _PriorityChip(priority: event.priority),
                ],
              ),
              if (event.notes != null && event.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.notes!,
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
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

class _PriorityChip extends StatelessWidget {
  final EventPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: priority.color.withOpacity(0.5)),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: priority.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
