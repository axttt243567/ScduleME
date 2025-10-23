import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../utils/sample_data_helper.dart';

/// Welcome dialog shown on first app launch
class WelcomeDialog extends StatelessWidget {
  const WelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.celebration, color: colorScheme.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Welcome to ScheduleMe!')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your personal event management system is ready!',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Features:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _FeatureItem(
            icon: Icons.event,
            text: 'Create events with categories & priorities',
          ),
          _FeatureItem(
            icon: Icons.repeat,
            text: 'Set recurring events (daily, weekly, custom)',
          ),
          _FeatureItem(
            icon: Icons.calendar_today,
            text: 'View events in calendar & timeline',
          ),
          _FeatureItem(
            icon: Icons.check_circle,
            text: 'Track completion status',
          ),
          _FeatureItem(
            icon: Icons.save,
            text: 'All data saved permanently on your device',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Would you like to add sample events to get started?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
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
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('No, Start Fresh'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Sample Data'),
        ),
      ],
    );
  }

  static Future<void> showIfFirstLaunch(BuildContext context) async {
    final provider = context.read<EventProvider>();

    // Wait for events to load
    await provider.loadEvents();

    // Show dialog if no events exist
    if (provider.events.isEmpty && context.mounted) {
      final addSampleData = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WelcomeDialog(),
      );

      if (addSampleData == true && context.mounted) {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Adding sample events...'),
                  ],
                ),
              ),
            ),
          ),
        );

        // Add sample data
        await SampleDataHelper.createSampleEvents(provider);

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Sample events added! Explore the app.'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
