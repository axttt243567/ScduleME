import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';
import '../models/category.dart';

/// Visual event type cards for category selection
class EventTypeCardsWidget extends StatefulWidget {
  final List<EventTypeCard> cards;
  final Function(EventTypeCard) onCardSelected;
  final bool allowMultipleSelection;

  const EventTypeCardsWidget({
    super.key,
    required this.cards,
    required this.onCardSelected,
    this.allowMultipleSelection = false,
  });

  @override
  State<EventTypeCardsWidget> createState() => _EventTypeCardsWidgetState();
}

class _EventTypeCardsWidgetState extends State<EventTypeCardsWidget> {
  late List<EventTypeCard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);
  }

  void _handleCardTap(int index) {
    setState(() {
      if (widget.allowMultipleSelection) {
        _cards[index] = _cards[index].copyWith(
          isSelected: !_cards[index].isSelected,
        );
      } else {
        for (var i = 0; i < _cards.length; i++) {
          _cards[i] = _cards[i].copyWith(isSelected: i == index);
        }
      }
    });
    widget.onCardSelected(_cards[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_cards.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _EventTypeCardItem(
                card: _cards[index],
                onTap: () => _handleCardTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _EventTypeCardItem extends StatelessWidget {
  final EventTypeCard card;
  final VoidCallback onTap;

  const _EventTypeCardItem({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card.isSelected
              ? card.color.withOpacity(0.2)
              : colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: card.isSelected
                ? card.color
                : colorScheme.outline.withOpacity(0.2),
            width: card.isSelected ? 2 : 1,
          ),
          boxShadow: card.isSelected
              ? [
                  BoxShadow(
                    color: card.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card.color.withOpacity(card.isSelected ? 0.3 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(card.icon, size: 32, color: card.color),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              card.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: card.isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (card.description != null) ...[
              const SizedBox(height: 4),
              Text(
                card.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // AI suggested badge
            if (card.isAiSuggested) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Pick',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Selected checkmark
            if (card.isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(Icons.check_circle, color: card.color, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper to convert existing categories to EventTypeCards
class EventTypeCardHelper {
  static List<EventTypeCard> fromCategories(
    List<EventCategory> categories, {
    List<String>? aiSuggestedIds,
  }) {
    return categories.map((category) {
      return EventTypeCard(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        description: _getCategoryDescription(category.id),
        isAiSuggested: aiSuggestedIds?.contains(category.id) ?? false,
      );
    }).toList();
  }

  static String? _getCategoryDescription(String categoryId) {
    final descriptions = {
      'academic': 'Classes, lectures, study',
      'assignment': 'Homework, tasks',
      'exam': 'Tests, quizzes',
      'project': 'Long-term projects',
      'study': 'Study sessions',
      'personal': 'Personal activities',
      'health': 'Exercise, health',
      'social': 'Meet friends',
      'work': 'Work related',
      'other': 'Other events',
    };
    return descriptions[categoryId];
  }

  static List<EventTypeCard> getDefaultCards() {
    return [
      EventTypeCard(
        id: 'academic',
        name: 'Academic',
        icon: Icons.school,
        color: const Color(0xFF00D9FF),
        description: 'Classes, lectures, study',
      ),
      EventTypeCard(
        id: 'assignment',
        name: 'Assignment',
        icon: Icons.assignment,
        color: const Color(0xFFFF6B9D),
        description: 'Homework, tasks',
      ),
      EventTypeCard(
        id: 'exam',
        name: 'Exam',
        icon: Icons.quiz,
        color: const Color(0xFFFF5252),
        description: 'Tests, quizzes',
      ),
      EventTypeCard(
        id: 'project',
        name: 'Project',
        icon: Icons.computer,
        color: const Color(0xFF9C27B0),
        description: 'Long-term projects',
      ),
      EventTypeCard(
        id: 'study',
        name: 'Study',
        icon: Icons.book,
        color: const Color(0xFF4CAF50),
        description: 'Study sessions',
      ),
      EventTypeCard(
        id: 'personal',
        name: 'Personal',
        icon: Icons.person,
        color: const Color(0xFFFF9800),
        description: 'Personal activities',
      ),
      EventTypeCard(
        id: 'health',
        name: 'Health',
        icon: Icons.favorite,
        color: const Color(0xFFE91E63),
        description: 'Exercise, health',
      ),
      EventTypeCard(
        id: 'social',
        name: 'Social',
        icon: Icons.people,
        color: const Color(0xFF00BCD4),
        description: 'Meet friends',
      ),
      EventTypeCard(
        id: 'work',
        name: 'Work',
        icon: Icons.work,
        color: const Color(0xFF607D8B),
        description: 'Work related',
      ),
    ];
  }
}

/// Loading animation for event type cards
class EventTypeCardsLoadingAnimation extends StatefulWidget {
  const EventTypeCardsLoadingAnimation({super.key});

  @override
  State<EventTypeCardsLoadingAnimation> createState() =>
      _EventTypeCardsLoadingAnimationState();
}

class _EventTypeCardsLoadingAnimationState
    extends State<EventTypeCardsLoadingAnimation>
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

    return SizedBox(
      height: 160,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final opacity = ((_controller.value + delay) % 1.0);
                  return Opacity(
                    opacity: 0.3 + (opacity * 0.7),
                    child: Container(
                      width: 140,
                      height: 160,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
