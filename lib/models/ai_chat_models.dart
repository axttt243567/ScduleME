import 'package:flutter/material.dart';

/// Enum for different types of chat messages
enum ChatMessageType {
  text,
  chips,
  dateTimePicker,
  eventTypeCards,
  progressUpdate,
  eventPreview,
  loading,
  error,
}

/// Enum for chip selection modes
enum ChipSelectionMode {
  single, // Single selection, auto-submit
  singleWithConfirm, // Single selection, needs confirmation
  multiple, // Multiple selection with submit button
  toggle, // Toggle state chips (yes/no)
}

/// Model for individual chip options
class ChipOption {
  final String id;
  final String label;
  final IconData? icon;
  final dynamic value; // The actual value to send to AI
  final bool isSelected;
  final String? description; // Optional tooltip/description

  ChipOption({
    required this.id,
    required this.label,
    this.icon,
    required this.value,
    this.isSelected = false,
    this.description,
  });

  ChipOption copyWith({
    String? id,
    String? label,
    IconData? icon,
    dynamic value,
    bool? isSelected,
    String? description,
  }) {
    return ChipOption(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'value': value, 'isSelected': isSelected};
  }

  factory ChipOption.fromJson(Map<String, dynamic> json) {
    return ChipOption(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] != null ? _parseIcon(json['icon']) : null,
      value: json['value'],
      isSelected: json['isSelected'] ?? false,
      description: json['description'],
    );
  }

  static IconData? _parseIcon(String iconName) {
    // Map common icon names to IconData
    final iconMap = {
      'event': Icons.event,
      'school': Icons.school,
      'work': Icons.work,
      'personal': Icons.person,
      'health': Icons.favorite,
      'social': Icons.people,
      'repeat': Icons.repeat,
      'today': Icons.today,
      'calendar': Icons.calendar_today,
      'alarm': Icons.alarm,
      'check': Icons.check,
      'close': Icons.close,
      'star': Icons.star,
      'flag': Icons.flag,
    };
    return iconMap[iconName];
  }
}

/// Model for chip groups
class ChipGroup {
  final String id;
  final String question;
  final List<ChipOption> options;
  final ChipSelectionMode selectionMode;
  final String? subtitle;
  final bool showSubmitButton;
  final String submitButtonText;

  ChipGroup({
    required this.id,
    required this.question,
    required this.options,
    this.selectionMode = ChipSelectionMode.single,
    this.subtitle,
    this.showSubmitButton = false,
    this.submitButtonText = 'Submit',
  });

  ChipGroup copyWith({
    String? id,
    String? question,
    List<ChipOption>? options,
    ChipSelectionMode? selectionMode,
    String? subtitle,
    bool? showSubmitButton,
    String? submitButtonText,
  }) {
    return ChipGroup(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      selectionMode: selectionMode ?? this.selectionMode,
      subtitle: subtitle ?? this.subtitle,
      showSubmitButton: showSubmitButton ?? this.showSubmitButton,
      submitButtonText: submitButtonText ?? this.submitButtonText,
    );
  }

  List<ChipOption> get selectedOptions =>
      options.where((chip) => chip.isSelected).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'selectionMode': selectionMode.name,
      'subtitle': subtitle,
    };
  }

  factory ChipGroup.fromJson(Map<String, dynamic> json) {
    return ChipGroup(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options:
          (json['options'] as List?)
              ?.map((o) => ChipOption.fromJson(o))
              .toList() ??
          [],
      selectionMode: _parseSelectionMode(json['selectionMode']),
      subtitle: json['subtitle'],
      showSubmitButton: json['showSubmitButton'] ?? false,
      submitButtonText: json['submitButtonText'] ?? 'Submit',
    );
  }

  static ChipSelectionMode _parseSelectionMode(String? mode) {
    switch (mode) {
      case 'single':
        return ChipSelectionMode.single;
      case 'singleWithConfirm':
        return ChipSelectionMode.singleWithConfirm;
      case 'multiple':
        return ChipSelectionMode.multiple;
      case 'toggle':
        return ChipSelectionMode.toggle;
      default:
        return ChipSelectionMode.single;
    }
  }
}

/// Model for event type cards
class EventTypeCard {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? description;
  final bool isAiSuggested;
  final bool isSelected;

  EventTypeCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description,
    this.isAiSuggested = false,
    this.isSelected = false,
  });

  EventTypeCard copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? description,
    bool? isAiSuggested,
    bool? isSelected,
  }) {
    return EventTypeCard(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      isAiSuggested: isAiSuggested ?? this.isAiSuggested,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Model for event creation progress
class EventCreationStep {
  final String id;
  final String title;
  final String? value;
  final bool isCompleted;
  final bool isEditable;
  final int stepNumber;

  EventCreationStep({
    required this.id,
    required this.title,
    this.value,
    this.isCompleted = false,
    this.isEditable = true,
    required this.stepNumber,
  });

  EventCreationStep copyWith({
    String? id,
    String? title,
    String? value,
    bool? isCompleted,
    bool? isEditable,
    int? stepNumber,
  }) {
    return EventCreationStep(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
      isEditable: isEditable ?? this.isEditable,
      stepNumber: stepNumber ?? this.stepNumber,
    );
  }
}

/// Model for AI chat messages
class AiChatMessage {
  final String id;
  final String? text;
  final ChatMessageType type;
  final bool isUser;
  final DateTime timestamp;
  final ChipGroup? chipGroup;
  final EventTypeCard? eventTypeCard;
  final List<EventTypeCard>? eventTypeCards;
  final List<EventCreationStep>? progressSteps;
  final Map<String, dynamic>? eventPreviewData;
  final bool isLoading;
  final String? errorMessage;

  AiChatMessage({
    required this.id,
    this.text,
    required this.type,
    required this.isUser,
    required this.timestamp,
    this.chipGroup,
    this.eventTypeCard,
    this.eventTypeCards,
    this.progressSteps,
    this.eventPreviewData,
    this.isLoading = false,
    this.errorMessage,
  });

  AiChatMessage copyWith({
    String? id,
    String? text,
    ChatMessageType? type,
    bool? isUser,
    DateTime? timestamp,
    ChipGroup? chipGroup,
    EventTypeCard? eventTypeCard,
    List<EventTypeCard>? eventTypeCards,
    List<EventCreationStep>? progressSteps,
    Map<String, dynamic>? eventPreviewData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      chipGroup: chipGroup ?? this.chipGroup,
      eventTypeCard: eventTypeCard ?? this.eventTypeCard,
      eventTypeCards: eventTypeCards ?? this.eventTypeCards,
      progressSteps: progressSteps ?? this.progressSteps,
      eventPreviewData: eventPreviewData ?? this.eventPreviewData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Model for AI response structure
class AiResponse {
  final String? text;
  final ChatMessageType responseType;
  final ChipGroup? chipGroup;
  final List<EventTypeCard>? eventTypeCards;
  final bool requiresDatePicker;
  final bool requiresTimePicker;
  final Map<String, dynamic>? metadata;

  AiResponse({
    this.text,
    required this.responseType,
    this.chipGroup,
    this.eventTypeCards,
    this.requiresDatePicker = false,
    this.requiresTimePicker = false,
    this.metadata,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      text: json['text'],
      responseType: _parseResponseType(json['responseType']),
      chipGroup: json['chipGroup'] != null
          ? ChipGroup.fromJson(json['chipGroup'])
          : null,
      eventTypeCards: json['eventTypeCards'] != null
          ? (json['eventTypeCards'] as List)
                .map(
                  (card) => EventTypeCard(
                    id: card['id'] ?? '',
                    name: card['name'] ?? '',
                    icon: ChipOption._parseIcon(card['icon']) ?? Icons.event,
                    color: Color(int.parse(card['color'] ?? '0xFF00D9FF')),
                    description: card['description'],
                    isAiSuggested: card['isAiSuggested'] ?? false,
                  ),
                )
                .toList()
          : null,
      requiresDatePicker: json['requiresDatePicker'] ?? false,
      requiresTimePicker: json['requiresTimePicker'] ?? false,
      metadata: json['metadata'],
    );
  }

  static ChatMessageType _parseResponseType(String? type) {
    switch (type) {
      case 'text':
        return ChatMessageType.text;
      case 'chips':
        return ChatMessageType.chips;
      case 'dateTimePicker':
        return ChatMessageType.dateTimePicker;
      case 'eventTypeCards':
        return ChatMessageType.eventTypeCards;
      case 'progressUpdate':
        return ChatMessageType.progressUpdate;
      case 'eventPreview':
        return ChatMessageType.eventPreview;
      default:
        return ChatMessageType.text;
    }
  }
}
