import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/ai_chat_models.dart';

/// Enhanced service for AI-powered event creation with structured responses
class AiEventService {
  /// Generate structured AI response for event creation
  static Future<AiResponse> generateEventCreationResponse({
    required String apiKey,
    required String userMessage,
    required String conversationContext,
    required DateTime currentDate,
    List<String>? existingCategories,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 2048,
        ),
      );

      final systemPrompt = _buildSystemPrompt(currentDate, existingCategories);
      final fullPrompt =
          '''$systemPrompt

CONVERSATION CONTEXT:
$conversationContext

USER MESSAGE:
$userMessage

Respond with a valid JSON object following the specified format.''';

      final response = await model.generateContent([Content.text(fullPrompt)]);

      final responseText = response.text ?? '';

      // Extract JSON from response (handle markdown code blocks)
      final jsonText = _extractJson(responseText);

      if (jsonText.isEmpty) {
        // Fallback to simple text response
        return AiResponse(
          text: responseText,
          responseType: ChatMessageType.text,
        );
      }

      final jsonData = jsonDecode(jsonText);
      return AiResponse.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to generate AI response: $e');
    }
  }

  /// Build comprehensive system prompt for event creation
  static String _buildSystemPrompt(
    DateTime currentDate,
    List<String>? existingCategories,
  ) {
    final categories =
        existingCategories?.join(', ') ??
        'Academic, Assignment, Exam, Project, Study, Personal, Health, Social, Work, Other';

    return '''You are an AI assistant specialized in helping users create calendar events through natural conversation.

CURRENT CONTEXT:
- Today's Date: ${currentDate.toString().split(' ')[0]} (${_getDayOfWeek(currentDate)})
- Current Time: ${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}
- Available Categories: $categories

YOUR CAPABILITIES:
1. Ask clarifying questions to gather event details
2. Provide quick-action chips for efficient user input
3. Suggest event types with visual cards
4. Request date/time selection when needed
5. Guide users through event creation step-by-step

RESPONSE FORMAT:
You MUST respond with a valid JSON object in one of these formats:

1. TEXT WITH CHIPS (for yes/no or multiple choice questions):
{
  "responseType": "chips",
  "text": "Your question or statement here",
  "chipGroup": {
    "id": "unique_id",
    "question": "The question being asked",
    "options": [
      {"id": "opt1", "label": "Yes", "value": true, "icon": "check"},
      {"id": "opt2", "label": "No", "value": false, "icon": "close"}
    ],
    "selectionMode": "single|multiple|toggle|singleWithConfirm",
    "showSubmitButton": false
  }
}

Selection Modes:
- "single": Auto-submit on selection (for simple yes/no)
- "multiple": Allow multiple selections with submit button
- "toggle": Toggle buttons (for yes/no questions)
- "singleWithConfirm": Single selection but needs confirmation

2. EVENT TYPE CARDS (for suggesting event categories):
{
  "responseType": "eventTypeCards",
  "text": "What type of event would you like to create?",
  "eventTypeCards": [
    {
      "id": "academic",
      "name": "Academic",
      "icon": "school",
      "color": "0xFF00D9FF",
      "description": "Classes, lectures, study sessions",
      "isAiSuggested": false
    }
  ]
}

3. DATE/TIME PICKER REQUEST:
{
  "responseType": "dateTimePicker",
  "text": "When should this event take place?",
  "requiresDatePicker": true,
  "requiresTimePicker": true,
  "metadata": {
    "suggestedDate": "2025-10-25",
    "suggestedTime": "14:00"
  }
}

4. SIMPLE TEXT (for clarifications or confirmations):
{
  "responseType": "text",
  "text": "Your message here"
}

CONVERSATION FLOW:
1. Greet and ask about event purpose (open-ended)
2. Based on purpose, suggest event types via cards or ask clarifying questions
3. Ask about repetition pattern using chips (None, Daily, Weekly, Custom)
4. Ask about date/time using date-time picker
5. Ask about priority using chips (Low, Medium, High, Urgent)
6. Confirm all details and create event

CHIP DESIGN GUIDELINES:
- Use single selection with auto-submit for simple binary choices
- Use multiple selection for features that can be combined
- Limit chip options to 6 for better UX
- Include icons when possible for visual clarity
- Use clear, concise labels (2-3 words max)

QUICK ACTION CHIPS:
When appropriate, offer these quick actions:
- "Retry": Generate alternative suggestion
- "Shorter": Make event duration shorter
- "Longer": Make event duration longer
- "Tomorrow": Quick date selection
- "Next Week": Quick date selection
- "Skip": Skip optional field

EXAMPLE INTERACTIONS:

User: "I need to study for my math exam"
Response:
{
  "responseType": "chips",
  "text": "I'll help you create a study event for your math exam. Is this exam happening soon?",
  "chipGroup": {
    "id": "exam_timing",
    "question": "When is your exam?",
    "options": [
      {"id": "tomorrow", "label": "Tomorrow", "value": "tomorrow", "icon": "today"},
      {"id": "this_week", "label": "This Week", "value": "this_week", "icon": "calendar"},
      {"id": "next_week", "label": "Next Week", "value": "next_week", "icon": "calendar"},
      {"id": "custom", "label": "Custom Date", "value": "custom", "icon": "event"}
    ],
    "selectionMode": "single"
  }
}

User: "Create a workout routine"
Response:
{
  "responseType": "chips",
  "text": "Great! Let's set up your workout routine. How often would you like to work out?",
  "chipGroup": {
    "id": "workout_frequency",
    "question": "Workout frequency",
    "options": [
      {"id": "daily", "label": "Daily", "value": "daily", "icon": "repeat"},
      {"id": "3days", "label": "3x per week", "value": "weekly_3", "icon": "repeat"},
      {"id": "weekly", "label": "Weekly", "value": "weekly", "icon": "repeat"},
      {"id": "custom", "label": "Custom", "value": "custom", "icon": "event"}
    ],
    "selectionMode": "single"
  }
}

REMEMBER:
- Always respond with valid JSON
- Keep conversation natural and friendly
- Use current date context for relative date suggestions
- Provide helpful quick-action chips when appropriate
- Guide users step by step through event creation
- Confirm all details before finalizing
''';
  }

  /// Extract JSON from response text (handles markdown code blocks)
  static String _extractJson(String text) {
    // Try to find JSON in markdown code block
    final codeBlockRegex = RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```');
    final match = codeBlockRegex.firstMatch(text);

    if (match != null) {
      return match.group(1) ?? '';
    }

    // Try to find raw JSON
    final jsonRegex = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonRegex.firstMatch(text);

    if (jsonMatch != null) {
      return jsonMatch.group(0) ?? '';
    }

    return '';
  }

  /// Get day of week name
  static String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  /// Generate chip options for quick actions
  static List<ChipOption> getQuickActionChips() {
    return [
      ChipOption(
        id: 'retry',
        label: 'Retry',
        icon: Icons.refresh,
        value: 'retry',
      ),
      ChipOption(
        id: 'bad_response',
        label: 'Bad Response',
        icon: Icons.thumb_down,
        value: 'bad_response',
      ),
      ChipOption(
        id: 'shorter',
        label: 'Shorter',
        icon: Icons.remove,
        value: 'shorter',
      ),
    ];
  }

  /// Generate date suggestion chips
  static List<ChipOption> getDateSuggestionChips(DateTime currentDate) {
    return [
      ChipOption(
        id: 'today',
        label: 'Today',
        icon: Icons.today,
        value: currentDate.toIso8601String(),
      ),
      ChipOption(
        id: 'tomorrow',
        label: 'Tomorrow',
        icon: Icons.today,
        value: currentDate.add(const Duration(days: 1)).toIso8601String(),
      ),
      ChipOption(
        id: 'next_week',
        label: 'Next Week',
        icon: Icons.calendar_today,
        value: currentDate.add(const Duration(days: 7)).toIso8601String(),
      ),
      ChipOption(
        id: 'custom',
        label: 'Custom Date',
        icon: Icons.event,
        value: 'custom',
      ),
    ];
  }

  /// Generate repetition chips
  static List<ChipOption> getRepetitionChips() {
    return [
      ChipOption(
        id: 'none',
        label: 'No Repeat',
        icon: Icons.event,
        value: 'none',
      ),
      ChipOption(
        id: 'daily',
        label: 'Daily',
        icon: Icons.repeat,
        value: 'daily',
      ),
      ChipOption(
        id: 'weekly',
        label: 'Weekly',
        icon: Icons.repeat_one,
        value: 'weekly',
      ),
      ChipOption(
        id: 'custom',
        label: 'Custom',
        icon: Icons.settings,
        value: 'custom',
      ),
    ];
  }

  /// Generate priority chips
  static List<ChipOption> getPriorityChips() {
    return [
      ChipOption(
        id: 'low',
        label: 'Low',
        icon: Icons.arrow_downward,
        value: 'low',
      ),
      ChipOption(
        id: 'medium',
        label: 'Medium',
        icon: Icons.remove,
        value: 'medium',
      ),
      ChipOption(
        id: 'high',
        label: 'High',
        icon: Icons.arrow_upward,
        value: 'high',
      ),
      ChipOption(
        id: 'urgent',
        label: 'Urgent',
        icon: Icons.warning,
        value: 'urgent',
      ),
    ];
  }
}
