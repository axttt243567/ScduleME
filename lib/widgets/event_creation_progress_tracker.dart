import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';

/// Progress tracker showing event creation steps
class EventCreationProgressTracker extends StatelessWidget {
  final List<EventCreationStep> steps;
  final int currentStepIndex;
  final Function(int)? onStepTap;
  final bool isCompact;

  const EventCreationProgressTracker({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    this.onStepTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView(context);
    }
    return _buildFullView(context);
  }

  Widget _buildFullView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.checklist, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Event Creation Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${steps.where((s) => s.isCompleted).length}/${steps.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: steps.isEmpty
                  ? 0
                  : steps.where((s) => s.isCompleted).length / steps.length,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),

          // Steps list
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return _StepItem(
              step: step,
              isActive: index == currentStepIndex,
              isLast: isLast,
              onTap: step.isEditable && onStepTap != null
                  ? () => onStepTap!(index)
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creating Event',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: steps.isEmpty
                        ? 0
                        : steps.where((s) => s.isCompleted).length /
                              steps.length,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${steps.where((s) => s.isCompleted).length}/${steps.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final EventCreationStep step;
  final bool isActive;
  final bool isLast;
  final VoidCallback? onTap;

  const _StepItem({
    required this.step,
    required this.isActive,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Step indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? colorScheme.primary
                    : isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isCompleted || isActive
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: step.isCompleted
                    ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                    : Text(
                        '${step.stepNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: step.isCompleted || isActive
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (step.value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.value!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Edit button
            if (step.isCompleted && step.isEditable && onTap != null)
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: colorScheme.primary),
                onPressed: onTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper to create common event creation steps
class EventCreationSteps {
  static List<EventCreationStep> getDefaultSteps() {
    return [
      EventCreationStep(id: 'purpose', title: 'Event Purpose', stepNumber: 1),
      EventCreationStep(id: 'type', title: 'Event Type', stepNumber: 2),
      EventCreationStep(id: 'date', title: 'Date & Time', stepNumber: 3),
      EventCreationStep(id: 'repetition', title: 'Repetition', stepNumber: 4),
      EventCreationStep(id: 'priority', title: 'Priority', stepNumber: 5),
      EventCreationStep(
        id: 'details',
        title: 'Additional Details',
        stepNumber: 6,
      ),
    ];
  }

  static EventCreationStep updateStepValue(
    EventCreationStep step,
    String value,
  ) {
    return step.copyWith(value: value, isCompleted: true);
  }
}
