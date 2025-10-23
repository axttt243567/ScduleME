import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';
import 'interactive_chip_widget.dart';
import 'inline_date_time_picker.dart';
import 'event_type_cards_widget.dart';
import 'package:intl/intl.dart';

/// Chat bubble that can display different message types
class AiChatBubble extends StatelessWidget {
  final AiChatMessage message;
  final Function(List<ChipOption>)? onChipsSelected;
  final Function(DateTime)? onDateSelected;
  final Function(TimeOfDay)? onTimeSelected;
  final Function(EventTypeCard)? onEventTypeSelected;
  final Function(String)? onQuickAction;

  const AiChatBubble({
    super.key,
    required this.message,
    this.onChipsSelected,
    this.onDateSelected,
    this.onTimeSelected,
    this.onEventTypeSelected,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // AI avatar
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _buildMessageContent(context),
                ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                  child: Text(
                    DateFormat.jm().format(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ),

                // Quick actions (for AI messages)
                if (!message.isUser && message.type == ChatMessageType.text)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: QuickActionChips(
                      onActionSelected: (action) {
                        if (onQuickAction != null) {
                          onQuickAction!(action);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),

          // User avatar
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 18, color: colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (message.isLoading) {
      return _buildLoadingContent(context);
    }

    if (message.errorMessage != null) {
      return _buildErrorContent(context);
    }

    switch (message.type) {
      case ChatMessageType.text:
        return Text(
          message.text ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),
        );

      case ChatMessageType.chips:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null && message.text!.isNotEmpty) ...[
              Text(
                message.text!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (message.chipGroup != null)
              InteractiveChipWidget(
                chipGroup: message.chipGroup!,
                onChipsSelected: (selected) {
                  if (onChipsSelected != null) {
                    onChipsSelected!(selected);
                  }
                },
              ),
          ],
        );

      case ChatMessageType.dateTimePicker:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null && message.text!.isNotEmpty) ...[
              Text(
                message.text!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            InlineDatePicker(
              initialDate: DateTime.now(),
              onDateSelected: (date) {
                if (onDateSelected != null) {
                  onDateSelected!(date);
                }
              },
              label: 'Select Date',
            ),
            const SizedBox(height: 12),
            InlineTimePicker(
              initialTime: TimeOfDay.now(),
              onTimeSelected: (time) {
                if (onTimeSelected != null) {
                  onTimeSelected!(time);
                }
              },
              label: 'Select Time',
            ),
          ],
        );

      case ChatMessageType.eventTypeCards:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null && message.text!.isNotEmpty) ...[
              Text(
                message.text!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (message.eventTypeCards != null)
              EventTypeCardsWidget(
                cards: message.eventTypeCards!,
                onCardSelected: (card) {
                  if (onEventTypeSelected != null) {
                    onEventTypeSelected!(card);
                  }
                },
              ),
          ],
        );

      case ChatMessageType.loading:
        return _buildLoadingContent(context);

      case ChatMessageType.error:
        return _buildErrorContent(context);

      default:
        return Text(
          message.text ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),
        );
    }
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AI is thinking...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 20, color: colorScheme.error),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message.errorMessage ?? 'An error occurred',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}

/// Typing indicator for AI
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = (_controller.value + delay) % 1.0;
                    final scale = 0.5 + (value * 0.5);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
