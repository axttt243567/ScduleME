import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

/// Individual Category Analytics Page
class CategoryAnalyticsPage extends StatefulWidget {
  final EventCategory category;

  const CategoryAnalyticsPage({super.key, required this.category});

  @override
  State<CategoryAnalyticsPage> createState() => _CategoryAnalyticsPageState();
}

class _CategoryAnalyticsPageState extends State<CategoryAnalyticsPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Pure black X-style
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          final allCategoryEvents = eventProvider.events
              .where((e) => e.categoryIds.contains(widget.category.id))
              .toList();

          // Filter by selected month
          final monthEvents = allCategoryEvents.where((e) {
            return e.startDate.year == _selectedMonth.year &&
                e.startDate.month == _selectedMonth.month;
          }).toList();

          return CustomScrollView(
            slivers: [
              // App Bar - X-style
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: widget.category.color.withOpacity(
                  0.3,
                ), // Subtle color
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.category.icon, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.category.color,
                          widget.category.color.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              allCategoryEvents.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Total Events',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Overall Statistics
                    _buildOverallStats(allCategoryEvents, cs),
                    const SizedBox(height: 24),

                    // Month Selector
                    Text(
                      'Monthly Analysis',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMonthSelector(cs),
                    const SizedBox(height: 16),

                    // Monthly Stats
                    _buildMonthlyStats(monthEvents, cs),
                    const SizedBox(height: 24),

                    // Priority Breakdown
                    Text(
                      'Priority Breakdown',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPriorityBreakdown(allCategoryEvents, cs),
                    const SizedBox(height: 24),

                    // Recent Events
                    Text(
                      'Recent Events',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentEvents(allCategoryEvents, cs),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallStats(List<Event> events, ColorScheme cs) {
    final completed = events.where((e) => e.remark == EventRemark.done).length;
    final upcoming = events
        .where(
          (e) =>
              e.startDate.isAfter(DateTime.now()) &&
              e.remark == EventRemark.none,
        )
        .length;
    final missed = events.where((e) => e.remark == EventRemark.missed).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Completed',
            value: completed.toString(),
            icon: Icons.check_circle,
            color: const Color(0xFF26DE81),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Upcoming',
            value: upcoming.toString(),
            icon: Icons.upcoming,
            color: const Color(0xFF00D9FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Missed',
            value: missed.toString(),
            icon: Icons.cancel,
            color: const Color(0xFFFF4757),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(ColorScheme cs) {
    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: cs.onSurface),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: cs.onSurface),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(List<Event> events, ColorScheme cs) {
    final completed = events.where((e) => e.remark == EventRemark.done).length;
    final skipped = events.where((e) => e.remark == EventRemark.skip).length;
    final missed = events.where((e) => e.remark == EventRemark.missed).length;

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Month Summary',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryColumn(
                  label: 'Total',
                  value: events.length.toString(),
                  color: widget.category.color,
                  icon: Icons.event,
                ),
                _SummaryColumn(
                  label: 'Done',
                  value: completed.toString(),
                  color: const Color(0xFF26DE81),
                  icon: Icons.check_circle,
                ),
                _SummaryColumn(
                  label: 'Skipped',
                  value: skipped.toString(),
                  color: const Color(0xFFFFA502),
                  icon: Icons.skip_next,
                ),
                _SummaryColumn(
                  label: 'Missed',
                  value: missed.toString(),
                  color: const Color(0xFFFF4757),
                  icon: Icons.cancel,
                ),
              ],
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completed / events.length,
                  minHeight: 12,
                  backgroundColor: cs.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation(widget.category.color),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${((completed / events.length) * 100).toStringAsFixed(1)}% completion rate',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBreakdown(List<Event> events, ColorScheme cs) {
    final urgentCount = events
        .where((e) => e.priority == EventPriority.urgent)
        .length;
    final highCount = events
        .where((e) => e.priority == EventPriority.high)
        .length;
    final mediumCount = events
        .where((e) => e.priority == EventPriority.medium)
        .length;
    final lowCount = events
        .where((e) => e.priority == EventPriority.low)
        .length;
    final total = events.length;

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _PriorityRow(
              priority: EventPriority.urgent,
              count: urgentCount,
              total: total,
            ),
            const SizedBox(height: 12),
            _PriorityRow(
              priority: EventPriority.high,
              count: highCount,
              total: total,
            ),
            const SizedBox(height: 12),
            _PriorityRow(
              priority: EventPriority.medium,
              count: mediumCount,
              total: total,
            ),
            const SizedBox(height: 12),
            _PriorityRow(
              priority: EventPriority.low,
              count: lowCount,
              total: total,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEvents(List<Event> events, ColorScheme cs) {
    final recentEvents = events.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final displayEvents = recentEvents.take(10).toList();

    if (displayEvents.isEmpty) {
      return Card(
        color: cs.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: cs.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No events in this category yet',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: displayEvents.map((event) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      event.icon,
                      size: 20,
                      color: widget.category.color,
                    ),
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
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(event.startDate),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRemarkBadge(event.remark),
                ],
              ),
            );
          }).toList(),
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

// Supporting Widgets

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final EventPriority priority;
  final int count;
  final int total;

  const _PriorityRow({
    required this.priority,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(priority.icon, size: 16, color: priority.color),
                const SizedBox(width: 8),
                Text(
                  priority.displayName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$count events',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: cs.surfaceContainer,
            valueColor: AlwaysStoppedAnimation(priority.color),
          ),
        ),
      ],
    );
  }
}
