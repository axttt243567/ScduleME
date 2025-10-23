import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/event.dart';
import '../models/category.dart';
import '../models/priority.dart';
import '../providers/event_provider.dart';
import '../providers/api_key_provider.dart';
import '../utils/gemini_service.dart';

/// AI-powered event creation page with conversational interface
class AiEventCreatorPage extends StatefulWidget {
  const AiEventCreatorPage({super.key});

  @override
  State<AiEventCreatorPage> createState() => _AiEventCreatorPageState();
}

class _AiEventCreatorPageState extends State<AiEventCreatorPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _conversationContext = '';

  final String _systemPrompt =
      '''You are an AI assistant specialized in helping users create events for their schedule. 

Your role is to:
1. Ask clarifying questions about the event details (title, date, time, priority, category, etc.)
2. Confirm the user's intent before creating events
3. Generate multiple events if the user requests it
4. Always respond with valid JSON when creating events

Available Categories: Academic, Assignment, Exam, Project, Study, Personal, Health, Social, Work, Other
Available Priorities: Low, Medium, High, Urgent
Available Icons: event, school, assignment, quiz, book, person, favorite, people, work, home, fitness_center, restaurant, flight, shopping_cart, music_note, movie, sports, computer, phone, mail, calendar_today, chat, photo, videocam

When the user is ready to create events, respond ONLY with a JSON object in this exact format:
{
  "action": "create_events",
  "events": [
    {
      "title": "Event Title",
      "categoryId": "academic",
      "priority": "medium",
      "startDate": "2025-10-25",
      "startTime": "14:30",
      "durationMinutes": 60,
      "isAllDay": false,
      "repetitionPattern": "none",
      "notes": "Optional notes",
      "icon": "event"
    }
  ]
}

Important:
- Use ISO date format (YYYY-MM-DD) for dates
- Use 24-hour format (HH:MM) for times
- Priority must be: "low", "medium", "high", or "urgent"
- CategoryId must be one of: "academic", "assignment", "exam", "project", "study", "personal", "health", "social", "work", "other"
- RepetitionPattern must be: "none", "daily", "weekly", or "custom"
- Icon must be from the available icons list above
- Always confirm details before generating the JSON

Be conversational and friendly. Ask follow-up questions if details are missing.''';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        _ChatMessage(
          text: '''👋 Hi! I'm your AI Event Creator assistant.

I can help you create events for your schedule. Just tell me what you need to schedule, and I'll ask you questions to make sure we get all the details right.

For example, you could say:
• "I need to study for my exam next week"
• "Schedule my gym sessions for this month"
• "Create a meeting for tomorrow at 2 PM"

What would you like to schedule?''',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final apiKeyProvider = Provider.of<ApiKeyProvider>(context, listen: false);
    if (!apiKeyProvider.hasActiveKey) {
      _showNoApiKeyDialog();
      return;
    }

    // Add user message
    setState(() {
      _messages.add(
        _ChatMessage(
          text: messageText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Build conversation context
    _conversationContext = _buildConversationHistory();

    try {
      // Create full prompt with system instructions and conversation history
      final fullPrompt =
          '$_systemPrompt\n\nConversation History:\n$_conversationContext\n\nUser: $messageText\n\nAssistant:';

      final response = await GeminiService.generateContent(
        apiKey: apiKeyProvider.activeApiKey!.keyValue,
        prompt: fullPrompt,
        model: 'gemini-2.0-flash-exp',
      );

      if (response != null && response.isNotEmpty) {
        // Try to parse as JSON (event creation)
        if (_isJsonResponse(response)) {
          _handleEventCreationResponse(response);
        } else {
          // Regular conversational response
          setState(() {
            _messages.add(
              _ChatMessage(
                text: response,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
            _isLoading = false;
          });
        }
      }
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Error: ${e.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _buildConversationHistory() {
    return _messages
        .where((m) => !m.hasEvents) // Exclude event preview messages
        .take(_messages.length > 10 ? 10 : _messages.length)
        .map((m) => '${m.isUser ? "User" : "Assistant"}: ${m.text}')
        .join('\n');
  }

  bool _isJsonResponse(String response) {
    final trimmed = response.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  void _handleEventCreationResponse(String jsonResponse) {
    try {
      // Clean the response
      String cleanedJson = jsonResponse.trim();

      // Remove markdown code blocks if present
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      } else if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3);
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }
      cleanedJson = cleanedJson.trim();

      final parsed = json.decode(cleanedJson);

      if (parsed['action'] == 'create_events' && parsed['events'] != null) {
        final events = (parsed['events'] as List)
            .map((e) => _parseEventFromJson(e))
            .where((e) => e != null)
            .cast<Event>()
            .toList();

        if (events.isNotEmpty) {
          setState(() {
            _messages.add(
              _ChatMessage(
                text:
                    'I\'ve prepared ${events.length} event${events.length > 1 ? 's' : ''} for you. Please review and approve each one:',
                isUser: false,
                timestamp: DateTime.now(),
                events: events,
              ),
            );
            _isLoading = false;
          });
        } else {
          throw Exception('No valid events parsed');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'I had trouble creating the events. Let me try again with more details. Could you confirm the event details?',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
      });
    }
  }

  Event? _parseEventFromJson(Map<String, dynamic> json) {
    try {
      // Parse date and time
      final startDate = DateTime.parse(json['startDate']);
      TimeOfDay? startTime;
      if (json['startTime'] != null && json['isAllDay'] != true) {
        final timeParts = (json['startTime'] as String).split(':');
        startTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }

      // Parse priority
      EventPriority priority;
      switch ((json['priority'] as String).toLowerCase()) {
        case 'urgent':
          priority = EventPriority.urgent;
          break;
        case 'high':
          priority = EventPriority.high;
          break;
        case 'low':
          priority = EventPriority.low;
          break;
        default:
          priority = EventPriority.medium;
      }

      // Parse category
      final categoryId = (json['categoryId'] as String).toLowerCase();
      EventCategory category;
      switch (categoryId) {
        case 'academic':
          category = Categories.academic;
          break;
        case 'assignment':
          category = Categories.assignment;
          break;
        case 'exam':
          category = Categories.exam;
          break;
        case 'project':
          category = Categories.project;
          break;
        case 'study':
          category = Categories.study;
          break;
        case 'personal':
          category = Categories.personal;
          break;
        case 'health':
          category = Categories.health;
          break;
        case 'social':
          category = Categories.social;
          break;
        case 'work':
          category = Categories.work;
          break;
        default:
          category = Categories.other;
      }

      // Parse icon
      IconData icon;
      final iconName = json['icon'] as String? ?? 'event';
      switch (iconName) {
        case 'school':
          icon = Icons.school;
          break;
        case 'assignment':
          icon = Icons.assignment;
          break;
        case 'quiz':
          icon = Icons.quiz;
          break;
        case 'book':
          icon = Icons.book;
          break;
        case 'person':
          icon = Icons.person;
          break;
        case 'favorite':
          icon = Icons.favorite;
          break;
        case 'people':
          icon = Icons.people;
          break;
        case 'work':
          icon = Icons.work;
          break;
        case 'home':
          icon = Icons.home;
          break;
        case 'fitness_center':
          icon = Icons.fitness_center;
          break;
        case 'restaurant':
          icon = Icons.restaurant;
          break;
        case 'flight':
          icon = Icons.flight;
          break;
        case 'shopping_cart':
          icon = Icons.shopping_cart;
          break;
        case 'music_note':
          icon = Icons.music_note;
          break;
        case 'movie':
          icon = Icons.movie;
          break;
        case 'sports':
          icon = Icons.sports;
          break;
        case 'computer':
          icon = Icons.computer;
          break;
        case 'phone':
          icon = Icons.phone;
          break;
        case 'mail':
          icon = Icons.mail;
          break;
        case 'calendar_today':
          icon = Icons.calendar_today;
          break;
        case 'chat':
          icon = Icons.chat;
          break;
        case 'photo':
          icon = Icons.photo;
          break;
        case 'videocam':
          icon = Icons.videocam;
          break;
        default:
          icon = Icons.event;
      }

      // Parse repetition pattern
      RepetitionPattern repetitionPattern;
      switch ((json['repetitionPattern'] as String? ?? 'none').toLowerCase()) {
        case 'daily':
          repetitionPattern = RepetitionPattern.daily;
          break;
        case 'weekly':
          repetitionPattern = RepetitionPattern.weekly;
          break;
        case 'custom':
          repetitionPattern = RepetitionPattern.custom;
          break;
        default:
          repetitionPattern = RepetitionPattern.none;
      }

      return Event(
        title: json['title'],
        categoryIds: [category.id],
        priority: priority,
        startDate: startDate,
        isAllDay: json['isAllDay'] ?? false,
        startTime: startTime,
        durationMinutes: json['durationMinutes'] ?? 60,
        repetitionPattern: repetitionPattern,
        icon: icon,
        remark: EventRemark.none,
        notes: json['notes'],
      );
    } catch (e) {
      debugPrint('Error parsing event: $e');
      return null;
    }
  }

  Future<void> _approveEvent(
    Event event,
    int messageIndex,
    int eventIndex,
  ) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    try {
      await eventProvider.createEvent(event);

      setState(() {
        // Mark the event as approved in the message
        final message = _messages[messageIndex];
        message.approvedEvents ??= [];
        message.approvedEvents!.add(eventIndex);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ "${event.title}" added to your schedule'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectEvent(int messageIndex, int eventIndex) {
    setState(() {
      final message = _messages[messageIndex];
      message.rejectedEvents ??= [];
      message.rejectedEvents!.add(eventIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event rejected'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showNoApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.key_off,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('No API Key'),
        content: const Text(
          'Please add and activate a Gemini API key in your profile settings to use AI features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will delete all messages and reset the conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _conversationContext = '';
              });
              _addWelcomeMessage();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create Events with AI'),
                Text(
                  'Powered by Gemini',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'clear') {
                  _clearChat();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  messageIndex: index,
                  onApprove: (eventIndex) => _approveEvent(
                    message.events![eventIndex],
                    index,
                    eventIndex,
                  ),
                  onReject: (eventIndex) => _rejectEvent(index, eventIndex),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Describe the event you want to create...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
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
                  IconButton.filled(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
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

/// Chat message model
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final List<Event>? events;
  List<int>? approvedEvents;
  List<int>? rejectedEvents;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.events,
  });

  bool get hasEvents => events != null && events!.isNotEmpty;
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final int messageIndex;
  final Function(int)? onApprove;
  final Function(int)? onReject;

  const _MessageBubble({
    required this.message,
    required this.messageIndex,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? cs.primaryContainer
                        : (message.isError
                              ? cs.errorContainer
                              : cs.surfaceContainerHigh),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? cs.onPrimaryContainer
                          : (message.isError
                                ? cs.onErrorContainer
                                : cs.onSurface),
                    ),
                  ),
                ),
                // Event preview cards
                if (message.hasEvents) ...[
                  const SizedBox(height: 12),
                  ...message.events!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final event = entry.value;
                    final isApproved =
                        message.approvedEvents?.contains(index) ?? false;
                    final isRejected =
                        message.rejectedEvents?.contains(index) ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _EventPreviewCard(
                        event: event,
                        eventIndex: index,
                        isApproved: isApproved,
                        isRejected: isRejected,
                        onApprove: () => onApprove?.call(index),
                        onReject: () => onReject?.call(index),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 16,
                color: cs.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Event preview card with approve/reject actions
class _EventPreviewCard extends StatelessWidget {
  final Event event;
  final int eventIndex;
  final bool isApproved;
  final bool isRejected;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _EventPreviewCard({
    required this.event,
    required this.eventIndex,
    required this.isApproved,
    required this.isRejected,
    required this.onApprove,
    required this.onReject,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == tomorrow) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final category = Categories.getById(event.categoryIds.first);

    return Card(
      color: cs.surfaceContainerHigh,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(event.icon, color: category.color, size: 20),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: category.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: event.priority.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.priority.displayName,
                              style: TextStyle(
                                color: event.priority.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(event.startDate),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
                if (!event.isAllDay && event.startTime != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(event.startTime!),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${event.durationMinutes} min)',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
                if (event.isAllDay)
                  Text(
                    'All Day',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
              ],
            ),

            // Notes
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.notes!,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            if (!isApproved && !isRejected)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              )
            else if (isApproved)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: cs.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Event Added',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (isRejected)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: cs.error, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Rejected',
                      style: TextStyle(
                        color: cs.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
