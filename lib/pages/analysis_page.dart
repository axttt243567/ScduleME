import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;

    // Calculate statistics
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

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Analytics',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primaryContainer, cs.tertiaryContainer],
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
                // Overview Stats
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

                const SizedBox(height: 32),

                // Completion Rate
                if (totalEvents > 0) ...[
                  Text(
                    'Completion Rate',
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
                  const SizedBox(height: 32),
                ],

                // Category Analysis
                Text(
                  'Category Analysis',
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

                  if (categoryEvents.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryAnalysisCard(
                      category: category,
                      totalEvents: categoryEvents.length,
                      completedEvents: categoryCompleted,
                      events: categoryEvents,
                    ),
                  );
                }),

                const SizedBox(height: 32),

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

                const SizedBox(height: 100), // Space for nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

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
                fontSize: 28,
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

class _CategoryAnalysisCard extends StatelessWidget {
  final EventCategory category;
  final int totalEvents;
  final int completedEvents;
  final List<Event> events;

  const _CategoryAnalysisCard({
    required this.category,
    required this.totalEvents,
    required this.completedEvents,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = totalEvents > 0
        ? ((completedEvents / totalEvents) * 100).round()
        : 0;

    // Priority breakdown
    final highPriority = events
        .where((e) => e.priority == EventPriority.high)
        .length;
    final urgentPriority = events
        .where((e) => e.priority == EventPriority.urgent)
        .length;

    return Card(
      color: cs.surfaceContainerHigh,
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
            if (highPriority > 0 || urgentPriority > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (urgentPriority > 0) ...[
                    Icon(
                      Icons.priority_high,
                      size: 14,
                      color: const Color(0xFFFF4757),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$urgentPriority urgent',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (highPriority > 0) ...[
                    Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: const Color(0xFFFF6B9D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$highPriority high',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
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
