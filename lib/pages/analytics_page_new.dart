import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';
import 'category_analytics_page.dart';

/// Enhanced Analytics Page with multiple views
class AnalyticsPageNew extends StatefulWidget {
  const AnalyticsPageNew({super.key});

  @override
  State<AnalyticsPageNew> createState() => _AnalyticsPageNewState();
}

class _AnalyticsPageNewState extends State<AnalyticsPageNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Pure black X-style
      body: CustomScrollView(
        slivers: [
          // App Bar with Tabs - X-style
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: cs.surfaceContainerLowest, // Pure black
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 48),
              title: Text(
                'Analytics Dashboard',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700, // X-style bold
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.15), // Twitter blue
                      cs.secondary.withOpacity(0.1), // Pink
                      cs.tertiary.withOpacity(0.08), // Purple
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              tabs: const [
                Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
                Tab(text: 'Categories', icon: Icon(Icons.category, size: 20)),
                Tab(text: 'Reports', icon: Icon(Icons.assessment, size: 20)),
              ],
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCategoriesTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Overview Tab - General statistics
  Widget _buildOverviewTab() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final cs = Theme.of(context).colorScheme;
        final events = eventProvider.events;

        final totalEvents = events.length;
        final completedEvents = events
            .where((e) => e.remark == EventRemark.done)
            .length;
        final upcomingEvents = events
            .where(
              (e) =>
                  e.startDate.isAfter(DateTime.now()) &&
                  e.remark == EventRemark.none,
            )
            .length;
        final missedEvents = events
            .where((e) => e.remark == EventRemark.missed)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total',
                      value: totalEvents.toString(),
                      icon: Icons.event,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Completed',
                      value: completedEvents.toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF26DE81),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Upcoming',
                      value: upcomingEvents.toString(),
                      icon: Icons.upcoming,
                      color: const Color(0xFF00D9FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Missed',
                      value: missedEvents.toString(),
                      icon: Icons.cancel,
                      color: const Color(0xFFFF4757),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Completion Rate
              if (totalEvents > 0) ...[
                Text(
                  'Overall Completion Rate',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _CompletionRateCard(
                  completed: completedEvents,
                  total: totalEvents,
                ),
                const SizedBox(height: 24),
              ],

              // Priority Distribution
              Text(
                'Priority Distribution',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _PriorityDistributionCard(events: events),

              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentActivity(events, cs),
            ],
          ),
        );
      },
    );
  }

  /// Categories Tab - Category with subcategories analytics
  Widget _buildCategoriesTab() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final cs = Theme.of(context).colorScheme;
        final events = eventProvider.events;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: cs.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap any category to view detailed analytics',
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

              // Category Analytics Cards
              Text(
                'Category Performance',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...Categories.all.map((category) {
                final categoryEvents = events
                    .where((e) => e.categoryIds.contains(category.id))
                    .toList();
                final categoryCompleted = categoryEvents
                    .where((e) => e.remark == EventRemark.done)
                    .length;

                if (categoryEvents.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryAnalyticsCard(
                    category: category,
                    totalEvents: categoryEvents.length,
                    completedEvents: categoryCompleted,
                    events: categoryEvents,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryAnalyticsPage(category: category),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Reports Tab - Monthly summary and analytics
  Widget _buildReportsTab() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final cs = Theme.of(context).colorScheme;
        final events = eventProvider.events;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector
              Card(
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
              ),

              const SizedBox(height: 24),

              // Monthly Summary
              _buildMonthlySummary(events, cs),

              const SizedBox(height: 24),

              // Category Breakdown for Month
              Text(
                'Category Breakdown',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildMonthCategoryBreakdown(events, cs),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlySummary(List<Event> events, ColorScheme cs) {
    final monthEvents = events.where((e) {
      return e.startDate.year == _selectedMonth.year &&
          e.startDate.month == _selectedMonth.month;
    }).toList();

    final completed = monthEvents
        .where((e) => e.remark == EventRemark.done)
        .length;
    final skipped = monthEvents
        .where((e) => e.remark == EventRemark.skip)
        .length;
    final missed = monthEvents
        .where((e) => e.remark == EventRemark.missed)
        .length;

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
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
                _SummaryItem(
                  label: 'Total',
                  value: monthEvents.length.toString(),
                  color: cs.primary,
                  icon: Icons.event,
                ),
                _SummaryItem(
                  label: 'Done',
                  value: completed.toString(),
                  color: const Color(0xFF26DE81),
                  icon: Icons.check_circle,
                ),
                _SummaryItem(
                  label: 'Skipped',
                  value: skipped.toString(),
                  color: const Color(0xFFFFA502),
                  icon: Icons.skip_next,
                ),
                _SummaryItem(
                  label: 'Missed',
                  value: missed.toString(),
                  color: const Color(0xFFFF4757),
                  icon: Icons.cancel,
                ),
              ],
            ),
            if (monthEvents.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completed / monthEvents.length,
                  minHeight: 12,
                  backgroundColor: cs.surfaceContainer,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF26DE81)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${((completed / monthEvents.length) * 100).toStringAsFixed(1)}% completion rate',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCategoryBreakdown(List<Event> events, ColorScheme cs) {
    final monthEvents = events.where((e) {
      return e.startDate.year == _selectedMonth.year &&
          e.startDate.month == _selectedMonth.month;
    }).toList();

    return Column(
      children: Categories.all.map((category) {
        final categoryEvents = monthEvents
            .where((e) => e.categoryIds.contains(category.id))
            .toList();

        if (categoryEvents.isEmpty) return const SizedBox.shrink();

        final completed = categoryEvents
            .where((e) => e.remark == EventRemark.done)
            .length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: cs.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$completed/${categoryEvents.length} completed',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${((completed / categoryEvents.length) * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: category.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completed / categoryEvents.length,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation(category.color),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(List<Event> events, ColorScheme cs) {
    final recentEvents = events
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final displayEvents = recentEvents.take(5).toList();

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: displayEvents.map((event) {
            final category = Categories.all.firstWhere(
              (c) => event.categoryIds.contains(c.id),
              orElse: () => Categories.other,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
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
                  _buildRemarkBadge(event.remark, cs),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRemarkBadge(EventRemark remark, ColorScheme cs) {
    Color color;
    IconData icon;
    String label;

    switch (remark) {
      case EventRemark.done:
        color = const Color(0xFF26DE81);
        icon = Icons.check_circle;
        label = 'Done';
        break;
      case EventRemark.skip:
        color = const Color(0xFFFFA502);
        icon = Icons.skip_next;
        label = 'Skipped';
        break;
      case EventRemark.missed:
        color = const Color(0xFFFF4757);
        icon = Icons.cancel;
        label = 'Missed';
        break;
      default:
        color = cs.onSurfaceVariant;
        icon = Icons.pending;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionRateCard extends StatelessWidget {
  final int completed;
  final int total;

  const _CompletionRateCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = ((completed / total) * 100).round();

    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completed / $total events',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completed / total,
                minHeight: 12,
                backgroundColor: cs.surfaceContainer,
                valueColor: AlwaysStoppedAnimation(
                  percentage >= 75
                      ? const Color(0xFF26DE81)
                      : percentage >= 50
                      ? const Color(0xFFFFA502)
                      : const Color(0xFFFF4757),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryAnalyticsCard extends StatelessWidget {
  final EventCategory category;
  final int totalEvents;
  final int completedEvents;
  final List<Event> events;
  final VoidCallback onTap;

  const _CategoryAnalyticsCard({
    required this.category,
    required this.totalEvents,
    required this.completedEvents,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = totalEvents > 0
        ? ((completedEvents / totalEvents) * 100).round()
        : 0;

    return Card(
      color: cs.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  const SizedBox(width: 12),
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
                          '$totalEvents events • $completedEvents completed',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        color: category.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalEvents > 0 ? completedEvents / totalEvents : 0,
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation(category.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityDistributionCard extends StatelessWidget {
  final List<Event> events;

  const _PriorityDistributionCard({required this.events});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
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
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
