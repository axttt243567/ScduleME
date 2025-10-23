/// Model representing a Gemini API Key
class ApiKey {
  final String? id;
  final String name;
  final String keyValue;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? lastValidatedAt;
  final bool? isValid;

  const ApiKey({
    this.id,
    required this.name,
    required this.keyValue,
    this.isActive = false,
    required this.createdAt,
    this.lastUsedAt,
    this.lastValidatedAt,
    this.isValid,
  });

  /// Copy with method for creating modified copies
  ApiKey copyWith({
    String? id,
    String? name,
    String? keyValue,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? lastValidatedAt,
    bool? isValid,
  }) {
    return ApiKey(
      id: id ?? this.id,
      name: name ?? this.name,
      keyValue: keyValue ?? this.keyValue,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
      isValid: isValid ?? this.isValid,
    );
  }

  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'keyValue': keyValue,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'lastValidatedAt': lastValidatedAt?.toIso8601String(),
      'isValid': isValid == null ? null : (isValid! ? 1 : 0),
    };
  }

  /// Create from map (database)
  factory ApiKey.fromMap(Map<String, dynamic> map) {
    return ApiKey(
      id: map['id'] as String?,
      name: map['name'] as String,
      keyValue: map['keyValue'] as String,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUsedAt: map['lastUsedAt'] != null
          ? DateTime.parse(map['lastUsedAt'] as String)
          : null,
      lastValidatedAt: map['lastValidatedAt'] != null
          ? DateTime.parse(map['lastValidatedAt'] as String)
          : null,
      isValid: map['isValid'] != null ? (map['isValid'] as int) == 1 : null,
    );
  }

  /// Get masked key for display (shows only last 8 characters)
  String get maskedKey {
    if (keyValue.length <= 8) {
      return '***';
    }
    return '•' * (keyValue.length - 8) + keyValue.substring(keyValue.length - 8);
  }

  @override
  String toString() {
    return 'ApiKey(id: $id, name: $name, isActive: $isActive, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiKey &&
        other.id == id &&
        other.name == name &&
        other.keyValue == keyValue &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        keyValue.hashCode ^
        isActive.hashCode;
  }
}
