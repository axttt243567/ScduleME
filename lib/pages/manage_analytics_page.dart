import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

/// Manage Analytics Page with filtering capabilities
class ManageAnalyticsPage extends StatefulWidget {
  const ManageAnalyticsPage({super.key});

  @override
  State<ManageAnalyticsPage> createState() => _ManageAnalyticsPageState();
}

class _ManageAnalyticsPageState extends State<ManageAnalyticsPage> {
  // Filter states
  String _actionFilter = 'all'; // all, add, edit, delete
  String _timeFilter =
      'all'; // all, today, last3days, thisweek, lastweek, thismonth, lastmonth
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedEventIds = {};
  bool _selectAllMode = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Pure black X-style
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest, // Pure black
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Analytics',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedEventIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete, color: cs.error),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          final filteredEvents = _applyFilters(eventProvider.events);

          return Column(
            children: [
              // Info Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: cs.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: cs.onPrimaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Filter and manage your event analytics',
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
              ),

              // Action Filter Row (Add, Edit, Delete)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Type',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildActionChip('All', 'all', Icons.list, cs),
                          _buildActionChip(
                            'Completed',
                            'done',
                            Icons.check_circle,
                            cs,
                          ),
                          _buildActionChip(
                            'Pending',
                            'pending',
                            Icons.pending,
                            cs,
                          ),
                          _buildActionChip(
                            'Skipped',
                            'skip',
                            Icons.skip_next,
                            cs,
                          ),
                          _buildActionChip(
                            'Missed',
                            'missed',
                            Icons.cancel,
                            cs,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Time Filter Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Period',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTimeChip('All Time', 'all', cs),
                          _buildTimeChip('Today', 'today', cs),
                          _buildTimeChip('Last 3 Days', 'last3days', cs),
                          _buildTimeChip('This Week', 'thisweek', cs),
                          _buildTimeChip('Last Week', 'lastweek', cs),
                          _buildTimeChip('This Month', 'thismonth', cs),
                          _buildTimeChip('Last Month', 'lastmonth', cs),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedCategories.length ==
                                  Categories.all.length) {
                                _selectedCategories.clear();
                              } else {
                                _selectedCategories.addAll(
                                  Categories.all.map((c) => c.id),
                                );
                              }
                            });
                          },
                          child: Text(
                            _selectedCategories.length == Categories.all.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: Categories.all.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryChip(category, cs),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Divider(color: cs.outlineVariant),

              // Results Summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredEvents.length} events found',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (filteredEvents.isNotEmpty)
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectAllMode = !_selectAllMode;
                                if (_selectAllMode) {
                                  _selectedEventIds.addAll(
                                    filteredEvents
                                        .where((e) => e.id != null)
                                        .map((e) => e.id!),
                                  );
                                } else {
                                  _selectedEventIds.clear();
                                }
                              });
                            },
                            icon: Icon(
                              _selectAllMode
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                            ),
                            label: Text(
                              _selectAllMode ? 'Deselect All' : 'Select All',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Events List
              Expanded(
                child: filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events match your filters',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _resetFilters,
                              child: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          final isSelected =
                              event.id != null &&
                              _selectedEventIds.contains(event.id!);
                          return _EventAnalyticsCard(
                            event: event,
                            isSelected: isSelected,
                            onSelectChanged: (selected) {
                              setState(() {
                                if (selected && event.id != null) {
                                  _selectedEventIds.add(event.id!);
                                } else if (event.id != null) {
                                  _selectedEventIds.remove(event.id!);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionChip(
    String label,
    String value,
    IconData icon,
    ColorScheme cs,
  ) {
    final isSelected = _actionFilter == value;
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
          setState(() {
            _actionFilter = value;
            _selectedEventIds.clear();
            _selectAllMode = false;
          });
        },
        selectedColor: cs.primaryContainer,
        checkmarkColor: cs.onPrimaryContainer,
      ),
    );
  }

  Widget _buildTimeChip(String label, String value, ColorScheme cs) {
    final isSelected = _timeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _timeFilter = value;
            _selectedEventIds.clear();
            _selectAllMode = false;
          });
        },
        selectedColor: cs.secondaryContainer,
        checkmarkColor: cs.onSecondaryContainer,
      ),
    );
  }

  Widget _buildCategoryChip(EventCategory category, ColorScheme cs) {
    final isSelected = _selectedCategories.contains(category.id);
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 16, color: category.color),
          const SizedBox(width: 4),
          Text(category.name),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(category.id);
          } else {
            _selectedCategories.remove(category.id);
          }
          _selectedEventIds.clear();
          _selectAllMode = false;
        });
      },
      selectedColor: category.color.withOpacity(0.3),
      checkmarkColor: category.color,
    );
  }

  List<Event> _applyFilters(List<Event> events) {
    var filtered = events;

    // Apply action filter
    if (_actionFilter != 'all') {
      filtered = filtered.where((event) {
        switch (_actionFilter) {
          case 'done':
            return event.remark == EventRemark.done;
          case 'pending':
            return event.remark == EventRemark.none;
          case 'skip':
            return event.remark == EventRemark.skip;
          case 'missed':
            return event.remark == EventRemark.missed;
          default:
            return true;
        }
      }).toList();
    }

    // Apply time filter
    if (_timeFilter != 'all') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filtered = filtered.where((event) {
        switch (_timeFilter) {
          case 'today':
            final eventDate = DateTime(
              event.startDate.year,
              event.startDate.month,
              event.startDate.day,
            );
            return eventDate == today;
          case 'last3days':
            return event.startDate.isAfter(
              today.subtract(const Duration(days: 3)),
            );
          case 'thisweek':
            final weekStart = today.subtract(Duration(days: today.weekday - 1));
            return event.startDate.isAfter(weekStart);
          case 'lastweek':
            final lastWeekStart = today.subtract(
              Duration(days: today.weekday + 6),
            );
            final lastWeekEnd = today.subtract(Duration(days: today.weekday));
            return event.startDate.isAfter(lastWeekStart) &&
                event.startDate.isBefore(lastWeekEnd);
          case 'thismonth':
            return event.startDate.year == now.year &&
                event.startDate.month == now.month;
          case 'lastmonth':
            final lastMonth = DateTime(now.year, now.month - 1);
            return event.startDate.year == lastMonth.year &&
                event.startDate.month == lastMonth.month;
          default:
            return true;
        }
      }).toList();
    }

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.categoryIds.any((id) => _selectedCategories.contains(id));
      }).toList();
    }

    return filtered;
  }

  void _resetFilters() {
    setState(() {
      _actionFilter = 'all';
      _timeFilter = 'all';
      _selectedCategories.clear();
      _selectedEventIds.clear();
      _selectAllMode = false;
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Delete Events', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to delete ${_selectedEventIds.length} selected event(s)? This action cannot be undone.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSelectedEvents(context);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text('Delete', style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedEvents(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final cs = Theme.of(context).colorScheme;

    for (final eventId in _selectedEventIds) {
      await eventProvider.deleteEvent(eventId);
    }

    setState(() {
      _selectedEventIds.clear();
      _selectAllMode = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedEventIds.length} event(s) deleted'),
          backgroundColor: cs.error,
        ),
      );
    }
  }
}

class _EventAnalyticsCard extends StatelessWidget {
  final Event event;
  final bool isSelected;
  final ValueChanged<bool> onSelectChanged;

  const _EventAnalyticsCard({
    required this.event,
    required this.isSelected,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final category = Categories.all.firstWhere(
      (c) => event.categoryIds.contains(c.id),
      orElse: () => Categories.other,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectChanged(value ?? false),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(event.icon, size: 20, color: category.color),
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(category.icon, size: 12, color: category.color),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd').format(event.startDate),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildRemarkBadge(event.remark),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkBadge(EventRemark remark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: remark.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(remark.icon, size: 12, color: remark.color),
          const SizedBox(width: 4),
          Text(
            remark.displayName,
            style: TextStyle(
              color: remark.color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
