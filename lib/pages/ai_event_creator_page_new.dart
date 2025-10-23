import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/ai_chat_models.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';
import '../providers/api_key_provider.dart';
import '../utils/ai_event_service.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/event_creation_progress_tracker.dart';
import '../widgets/event_preview_screen.dart';

/// Enhanced AI-powered event creation page with interactive chat interface
class AiEventCreatorPageNew extends StatefulWidget {
  const AiEventCreatorPageNew({super.key});

  @override
  State<AiEventCreatorPageNew> createState() => _AiEventCreatorPageNewState();
}

class _AiEventCreatorPageNewState extends State<AiEventCreatorPageNew>
    with SingleTickerProviderStateMixin {
  final List<AiChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isTyping = false;
  String _conversationContext = '';
  List<EventCreationStep> _creationSteps = [];
  int _currentStepIndex = 0;
  Map<String, dynamic> _eventData = {};

  late AnimationController _messageAnimationController;

  @override
  void initState() {
    super.initState();
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initializeSteps();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _initializeSteps() {
    _creationSteps = EventCreationSteps.getDefaultSteps();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '''👋 Hi! I'm your AI Event Creator assistant.

I'll help you create events through natural conversation. I can ask questions and provide quick options to make scheduling faster and easier.

What would you like to schedule today?''',
      type: ChatMessageType.text,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(welcomeMessage);
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? text}) async {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    final apiKeyProvider = Provider.of<ApiKeyProvider>(context, listen: false);
    if (!apiKeyProvider.hasActiveKey) {
      _showNoApiKeyDialog();
      return;
    }

    // Add user message
    final userMessage = AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText,
      type: ChatMessageType.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _inputFocusNode.unfocus();
    _scrollToBottom();

    // Update conversation context
    _conversationContext = _buildConversationHistory();

    try {
      // Generate AI response
      final response = await AiEventService.generateEventCreationResponse(
        apiKey: apiKeyProvider.activeApiKey!.keyValue,
        userMessage: messageText,
        conversationContext: _conversationContext,
        currentDate: DateTime.now(),
        existingCategories: Categories.all.map((c) => c.id).toList(),
      );

      _handleAiResponse(response);
    } catch (e) {
      setState(() {
        _messages.add(
          AiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ChatMessageType.error,
            isUser: false,
            timestamp: DateTime.now(),
            errorMessage: 'Failed to get AI response: ${e.toString()}',
          ),
        );
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _handleAiResponse(AiResponse response) {
    setState(() {
      _isTyping = false;

      AiChatMessage message;

      switch (response.responseType) {
        case ChatMessageType.chips:
          message = AiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: response.text,
            type: ChatMessageType.chips,
            isUser: false,
            timestamp: DateTime.now(),
            chipGroup: response.chipGroup,
          );
          break;

        case ChatMessageType.eventTypeCards:
          message = AiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: response.text,
            type: ChatMessageType.eventTypeCards,
            isUser: false,
            timestamp: DateTime.now(),
            eventTypeCards: response.eventTypeCards,
          );
          break;

        case ChatMessageType.dateTimePicker:
          message = AiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: response.text,
            type: ChatMessageType.dateTimePicker,
            isUser: false,
            timestamp: DateTime.now(),
          );
          break;

        default:
          message = AiChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: response.text ?? 'No response',
            type: ChatMessageType.text,
            isUser: false,
            timestamp: DateTime.now(),
          );
      }

      _messages.add(message);
    });
  }

  String _buildConversationHistory() {
    return _messages
        .where((m) => m.type == ChatMessageType.text)
        .take(_messages.length > 10 ? 10 : _messages.length)
        .map((m) {
          return '${m.isUser ? "User" : "Assistant"}: ${m.text ?? ""}';
        })
        .join('\n');
  }

  void _handleChipsSelected(List<ChipOption> selectedChips) {
    if (selectedChips.isEmpty) return;

    final chipLabels = selectedChips.map((c) => c.label).join(', ');
    _sendMessage(text: chipLabels);

    // Store data based on context
    for (var chip in selectedChips) {
      _eventData[chip.id] = chip.value;
    }

    _updateProgress();
  }

  void _handleDateSelected(DateTime date) {
    _eventData['date'] = date.toIso8601String();
    _sendMessage(text: 'Selected date: ${date.toString().split(' ')[0]}');
    _updateProgress();
  }

  void _handleTimeSelected(TimeOfDay time) {
    _eventData['time'] = '${time.hour}:${time.minute}';
    _sendMessage(
      text:
          'Selected time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
    );
    _updateProgress();
  }

  void _handleEventTypeSelected(EventTypeCard card) {
    _eventData['category'] = card.id;
    _sendMessage(text: 'Selected ${card.name}');
    _updateProgress();
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'retry':
        _sendMessage(
          text: 'Can you provide a different suggestion or rephrase that?',
        );
        break;
      case 'bad_response':
        _sendMessage(text: 'That response wasn\'t helpful. Can you try again?');
        break;
      case 'shorter':
        _sendMessage(text: 'Make it shorter please');
        break;
    }
  }

  void _updateProgress() {
    setState(() {
      // Update step completion based on collected data
      if (_eventData.containsKey('purpose')) {
        _creationSteps[0] = _creationSteps[0].copyWith(
          value: _eventData['purpose'].toString(),
          isCompleted: true,
        );
      }
      if (_eventData.containsKey('category')) {
        _creationSteps[1] = _creationSteps[1].copyWith(
          value: _eventData['category'].toString(),
          isCompleted: true,
        );
      }
      if (_eventData.containsKey('date')) {
        _creationSteps[2] = _creationSteps[2].copyWith(
          value: _eventData['date'].toString().split(' ')[0],
          isCompleted: true,
        );
      }

      // Move to next incomplete step
      _currentStepIndex = _creationSteps.indexWhere((s) => !s.isCompleted);
      if (_currentStepIndex == -1) {
        _currentStepIndex = _creationSteps.length - 1;
      }
    });
  }

  void _showEventPreview() {
    if (_eventData.isEmpty) return;

    // Create event from collected data
    final event = _createEventFromData();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventPreviewScreen(
          event: event,
          onConfirm: () {
            _saveEvent(event);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onEdit: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Event _createEventFromData() {
    // Parse collected data into Event object
    final now = DateTime.now();
    final startDate = _eventData['date'] != null
        ? DateTime.parse(_eventData['date'])
        : now;

    TimeOfDay? startTime;
    if (_eventData['time'] != null) {
      final timeParts = _eventData['time'].toString().split(':');
      startTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    return Event(
      title: _eventData['title'] ?? 'New Event',
      categoryIds: [_eventData['category'] ?? 'other'],
      priority: _parsePriority(_eventData['priority']),
      startDate: startDate,
      isAllDay: _eventData['isAllDay'] ?? false,
      startTime: startTime,
      durationMinutes: _eventData['duration'] ?? 60,
      repetitionPattern: _parseRepetition(_eventData['repetition']),
      icon: Icons.event,
      iconCodePoint: Icons.event.codePoint.toString(),
      remark: EventRemark.none,
      notes: _eventData['notes'],
    );
  }

  EventPriority _parsePriority(dynamic priority) {
    if (priority == null) return EventPriority.medium;
    switch (priority.toString().toLowerCase()) {
      case 'low':
        return EventPriority.low;
      case 'high':
        return EventPriority.high;
      case 'urgent':
        return EventPriority.urgent;
      default:
        return EventPriority.medium;
    }
  }

  RepetitionPattern _parseRepetition(dynamic repetition) {
    if (repetition == null) return RepetitionPattern.none;
    switch (repetition.toString().toLowerCase()) {
      case 'daily':
        return RepetitionPattern.daily;
      case 'weekly':
        return RepetitionPattern.weekly;
      case 'custom':
        return RepetitionPattern.custom;
      default:
        return RepetitionPattern.none;
    }
  }

  Future<void> _saveEvent(Event event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.createEvent(event);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNoApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key Required'),
        content: const Text(
          'Please add and activate a Gemini API key in your profile settings to use AI features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create Event with AI'),
        actions: [
          if (_eventData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: _showEventPreview,
              tooltip: 'Preview Event',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _eventData.clear();
                _initializeSteps();
                _currentStepIndex = 0;
                _conversationContext = '';
                _addWelcomeMessage();
              });
            },
            tooltip: 'Start Over',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress tracker
          if (_creationSteps.any((s) => s.isCompleted))
            EventCreationProgressTracker(
              steps: _creationSteps,
              currentStepIndex: _currentStepIndex,
              isCompact: true,
              onStepTap: (index) {
                // Handle step navigation/editing
              },
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const TypingIndicator();
                }

                final message = _messages[index];
                return AiChatBubble(
                  message: message,
                  onChipsSelected: _handleChipsSelected,
                  onDateSelected: _handleDateSelected,
                  onTimeSelected: _handleTimeSelected,
                  onEventTypeSelected: _handleEventTypeSelected,
                  onQuickAction: _handleQuickAction,
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: colorScheme.onPrimary),
                      onPressed: _isTyping ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
