import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for interacting with Gemini AI
class GeminiService {
  /// Validate an API key by making a test request
  static Future<bool> validateApiKey(String apiKey) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      // Make a simple test request
      final response = await model.generateContent([
        Content.text('Hello')
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      // If we get a response without errors, the key is valid
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      // Key is invalid if any error occurs
      return false;
    }
  }

  /// Generate content using Gemini AI
  static Future<String?> generateContent({
    required String apiKey,
    required String prompt,
    String model = 'gemini-pro',
  }) async {
    try {
      final generativeModel = GenerativeModel(
        model: model,
        apiKey: apiKey,
      );

      final response = await generativeModel.generateContent([
        Content.text(prompt)
      ]);

      return response.text;
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  /// Generate content with streaming
  static Stream<String> generateContentStream({
    required String apiKey,
    required String prompt,
    String model = 'gemini-pro',
  }) async* {
    try {
      final generativeModel = GenerativeModel(
        model: model,
        apiKey: apiKey,
      );

      final response = generativeModel.generateContentStream([
        Content.text(prompt)
      ]);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      throw Exception('Failed to generate content stream: $e');
    }
  }

  /// Chat with Gemini AI
  static Future<ChatSession> startChat({
    required String apiKey,
    String model = 'gemini-pro',
    List<Content>? history,
  }) async {
    try {
      final generativeModel = GenerativeModel(
        model: model,
        apiKey: apiKey,
      );

      return generativeModel.startChat(history: history);
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }

  /// Get available models (requires valid API key)
  static Future<List<String>> getAvailableModels(String apiKey) async {
    // As of now, we'll return the commonly available models
    // In a real implementation, you might want to query the API for this
    return [
      'gemini-pro',
      'gemini-pro-vision',
    ];
  }

  /// Check if API key format is valid (basic format check)
  static bool isValidKeyFormat(String apiKey) {
    // Gemini API keys typically start with "AIza" and are 39 characters long
    // This is just a basic format check, not actual validation
    if (apiKey.isEmpty) return false;
    if (apiKey.length < 20) return false; // Minimum reasonable length
    if (apiKey.contains(' ')) return false; // No spaces
    
    return true;
  }

  /// Get error message from exception
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('Invalid API key') || 
        errorString.contains('API_KEY_INVALID')) {
      return 'Invalid API key. Please check your key and try again.';
    } else if (errorString.contains('quota') || 
               errorString.contains('limit exceeded')) {
      return 'API quota exceeded. Please try again later or use a different key.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (errorString.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    
    return 'An error occurred: ${errorString.length > 100 ? errorString.substring(0, 100) + "..." : errorString}';
  }
}
