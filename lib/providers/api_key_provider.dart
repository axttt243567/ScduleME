import 'package:flutter/foundation.dart';
import '../models/api_key.dart';
import '../database/database_helper.dart';

/// Provider for managing API keys
class ApiKeyProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ApiKey> _apiKeys = [];
  ApiKey? _activeApiKey;
  bool _isLoading = false;

  List<ApiKey> get apiKeys => _apiKeys;
  ApiKey? get activeApiKey => _activeApiKey;
  bool get isLoading => _isLoading;
  bool get hasActiveKey => _activeApiKey != null;

  /// Initialize and load API keys from database
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error initializing API keys: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all API keys from database
  Future<void> loadApiKeys() async {
    _apiKeys = await _dbHelper.readAllApiKeys();
    _activeApiKey = await _dbHelper.readActiveApiKey();
    notifyListeners();
  }

  /// Add a new API key
  Future<ApiKey> addApiKey({
    required String name,
    required String keyValue,
    bool setAsActive = false,
  }) async {
    try {
      final apiKey = ApiKey(
        name: name,
        keyValue: keyValue,
        isActive: setAsActive,
        createdAt: DateTime.now(),
      );

      final createdKey = await _dbHelper.createApiKey(apiKey);

      if (setAsActive) {
        await _dbHelper.setActiveApiKey(createdKey.id!);
      }

      await loadApiKeys();
      return createdKey;
    } catch (e) {
      debugPrint('Error adding API key: $e');
      rethrow;
    }
  }

  /// Update an existing API key
  Future<void> updateApiKey(ApiKey apiKey) async {
    try {
      await _dbHelper.updateApiKey(apiKey);
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error updating API key: $e');
      rethrow;
    }
  }

  /// Set an API key as active (deactivates all others)
  Future<void> setActiveKey(String id) async {
    try {
      await _dbHelper.setActiveApiKey(id);
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error setting active API key: $e');
      rethrow;
    }
  }

  /// Delete an API key
  Future<void> deleteApiKey(String id) async {
    try {
      await _dbHelper.deleteApiKey(id);
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error deleting API key: $e');
      rethrow;
    }
  }

  /// Update API key validation status
  Future<void> updateValidationStatus({
    required String id,
    required bool isValid,
  }) async {
    try {
      final apiKey = _apiKeys.firstWhere((key) => key.id == id);
      final updatedKey = apiKey.copyWith(
        isValid: isValid,
        lastValidatedAt: DateTime.now(),
      );

      await _dbHelper.updateApiKey(updatedKey);
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error updating validation status: $e');
      rethrow;
    }
  }

  /// Update last used timestamp for an API key
  Future<void> updateLastUsed(String id) async {
    try {
      final apiKey = _apiKeys.firstWhere((key) => key.id == id);
      final updatedKey = apiKey.copyWith(lastUsedAt: DateTime.now());

      await _dbHelper.updateApiKey(updatedKey);
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error updating last used timestamp: $e');
      rethrow;
    }
  }

  /// Get API key by ID
  ApiKey? getApiKeyById(String id) {
    try {
      return _apiKeys.firstWhere((key) => key.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if a key name already exists
  bool keyNameExists(String name, {String? excludeId}) {
    return _apiKeys.any(
      (key) =>
          key.name.toLowerCase() == name.toLowerCase() && key.id != excludeId,
    );
  }

  /// Get total number of API keys
  int get totalKeys => _apiKeys.length;

  /// Get number of valid API keys
  int get validKeysCount => _apiKeys.where((key) => key.isValid == true).length;

  /// Clear all API keys (for data management)
  Future<void> clearAllApiKeys() async {
    try {
      await _dbHelper.deleteAllApiKeys();
      await loadApiKeys();
    } catch (e) {
      debugPrint('Error clearing all API keys: $e');
      rethrow;
    }
  }
}
