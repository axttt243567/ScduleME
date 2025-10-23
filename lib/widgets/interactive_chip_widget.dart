import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';

/// Interactive chip widget with selection animations
class InteractiveChipWidget extends StatefulWidget {
  final ChipGroup chipGroup;
  final Function(List<ChipOption>) onChipsSelected;
  final Function(ChipOption)? onChipLongPress;

  const InteractiveChipWidget({
    super.key,
    required this.chipGroup,
    required this.onChipsSelected,
    this.onChipLongPress,
  });

  @override
  State<InteractiveChipWidget> createState() => _InteractiveChipWidgetState();
}

class _InteractiveChipWidgetState extends State<InteractiveChipWidget>
    with SingleTickerProviderStateMixin {
  late List<ChipOption> _options;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.chipGroup.options);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleChipTap(int index) {
    setState(() {
      switch (widget.chipGroup.selectionMode) {
        case ChipSelectionMode.single:
          // Single selection with auto-submit
          for (var i = 0; i < _options.length; i++) {
            _options[i] = _options[i].copyWith(isSelected: i == index);
          }
          // Auto-submit immediately
          Future.delayed(const Duration(milliseconds: 300), () {
            widget.onChipsSelected(
              _options.where((o) => o.isSelected).toList(),
            );
          });
          break;

        case ChipSelectionMode.singleWithConfirm:
          // Single selection but needs confirmation
          for (var i = 0; i < _options.length; i++) {
            _options[i] = _options[i].copyWith(isSelected: i == index);
          }
          break;

        case ChipSelectionMode.multiple:
          // Multiple selection
          _options[index] = _options[index].copyWith(
            isSelected: !_options[index].isSelected,
          );
          break;

        case ChipSelectionMode.toggle:
          // Toggle mode (only one can be selected)
          for (var i = 0; i < _options.length; i++) {
            _options[i] = _options[i].copyWith(isSelected: i == index);
          }
          // Auto-submit for toggle
          Future.delayed(const Duration(milliseconds: 300), () {
            widget.onChipsSelected(
              _options.where((o) => o.isSelected).toList(),
            );
          });
          break;
      }
    });
  }

  void _handleSubmit() {
    final selected = _options.where((o) => o.isSelected).toList();
    if (selected.isNotEmpty) {
      widget.onChipsSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _animationController,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Question text
            if (widget.chipGroup.question.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.chipGroup.question,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Subtitle
            if (widget.chipGroup.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.chipGroup.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),

            // Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildChip(_options[index], index),
                  );
                }),
              ),
            ),

            // Submit button (for multiple selection mode)
            if (widget.chipGroup.showSubmitButton ||
                widget.chipGroup.selectionMode == ChipSelectionMode.multiple ||
                widget.chipGroup.selectionMode ==
                    ChipSelectionMode.singleWithConfirm)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _options.any((o) => o.isSelected)
                        ? _handleSubmit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.chipGroup.submitButtonText),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(ChipOption option, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = option.isSelected;

    return GestureDetector(
      onTap: () => _handleChipTap(index),
      onLongPress: () {
        if (widget.onChipLongPress != null) {
          widget.onChipLongPress!(option);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null) ...[
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  option.icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick action chips (Retry, Bad Response, etc.)
class QuickActionChips extends StatelessWidget {
  final Function(String action) onActionSelected;

  const QuickActionChips({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = [
      {'id': 'retry', 'label': 'Retry', 'icon': Icons.refresh},
      {'id': 'bad_response', 'label': 'Bad Response', 'icon': Icons.thumb_down},
      {'id': 'shorter', 'label': 'Shorter', 'icon': Icons.remove},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onActionSelected(action['id'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        action['label'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Loading animation for chip generation
class ChipLoadingAnimation extends StatefulWidget {
  const ChipLoadingAnimation({super.key});

  @override
  State<ChipLoadingAnimation> createState() => _ChipLoadingAnimationState();
}

class _ChipLoadingAnimationState extends State<ChipLoadingAnimation>
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

    return Container(
      height: 40,
      child: Row(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final opacity = ((_controller.value + delay) % 1.0);
                return Opacity(
                  opacity: 0.3 + (opacity * 0.7),
                  child: Container(
                    width: 80,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
