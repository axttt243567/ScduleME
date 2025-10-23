import 'package:flutter/material.dart';

/// Note type enum
enum NoteType {
  text,
  pdf;

  String get displayName {
    switch (this) {
      case NoteType.text:
        return 'Text Note';
      case NoteType.pdf:
        return 'PDF Document';
    }
  }

  IconData get icon {
    switch (this) {
      case NoteType.text:
        return Icons.description;
      case NoteType.pdf:
        return Icons.picture_as_pdf;
    }
  }
}

/// Note model with category and folder support
class Note {
  final String id;
  final String title;
  final NoteType type;
  final String categoryId; // Must belong to a category
  final String? folderId; // Optional: can be in a folder
  final String? content; // For text notes
  final String? filePath; // For PDF notes
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.type,
    required this.categoryId,
    this.folderId,
    this.content,
    this.filePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    NoteType? type,
    String? categoryId,
    String? folderId,
    String? content,
    String? filePath,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      folderId: folderId ?? this.folderId,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'categoryId': categoryId,
      'folderId': folderId,
      'content': content,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags.join(','),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      type: NoteType.values.firstWhere((e) => e.name == map['type']),
      categoryId: map['categoryId'],
      folderId: map['folderId'],
      content: map['content'],
      filePath: map['filePath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
    );
  }
}

/// Folder model for organizing notes
class NoteFolder {
  final String id;
  final String name;
  final String categoryId; // Folder must belong to a category
  final String? parentFolderId; // For nested folders
  final IconData icon;
  final DateTime createdAt;

  NoteFolder({
    required this.id,
    required this.name,
    required this.categoryId,
    this.parentFolderId,
    this.icon = Icons.folder,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'parentFolderId': parentFolderId,
      'icon': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteFolder.fromMap(Map<String, dynamic> map) {
    return NoteFolder(
      id: map['id'],
      name: map['name'],
      categoryId: map['categoryId'],
      parentFolderId: map['parentFolderId'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
