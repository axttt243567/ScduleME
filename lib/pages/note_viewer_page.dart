import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/category.dart';

class NoteViewerPage extends StatelessWidget {
  final Note note;

  const NoteViewerPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final category = Categories.getById(note.categoryId);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Pure black X-style
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest, // Pure black
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          note.title,
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: cs.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: cs.onSurface),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: note.type == NoteType.text
          ? _buildTextNoteView(context, cs, category)
          : _buildPDFNoteView(context, cs, category),
    );
  }

  Widget _buildTextNoteView(
    BuildContext context,
    ColorScheme cs,
    EventCategory category,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Note metadata
          _buildMetadataCard(cs, category),
          const SizedBox(height: 20),

          // Note content
          Card(
            color: cs.surfaceContainerHigh,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                note.content ?? 'No content',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tags
          if (note.tags.isNotEmpty) _buildTagsSection(cs),
        ],
      ),
    );
  }

  Widget _buildPDFNoteView(
    BuildContext context,
    ColorScheme cs,
    EventCategory category,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Note metadata
          _buildMetadataCard(cs, category),
          const SizedBox(height: 20),

          // PDF Viewer placeholder
          Card(
            color: cs.surfaceContainerHigh,
            child: Container(
              width: double.infinity,
              height: 500,
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 100,
                    color: const Color(0xFFFF4757),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PDF Viewer',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    note.title,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.filePath ?? '',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PDF viewing requires pdf_viewer package',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open PDF'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4757),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Demo PDF - Full viewer integration available',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tags
          if (note.tags.isNotEmpty) _buildTagsSection(cs),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(ColorScheme cs, EventCategory category) {
    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        note.type.displayName,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: note.type == NoteType.pdf
                        ? const Color(0xFFFF4757).withOpacity(0.2)
                        : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    note.type.icon,
                    color: note.type == NoteType.pdf
                        ? const Color(0xFFFF4757)
                        : cs.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(note.createdAt)}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.update, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${_formatDate(note.updatedAt)}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: note.tags.map((tag) {
            return Chip(
              label: Text(
                tag,
                style: TextStyle(color: cs.onSecondaryContainer, fontSize: 12),
              ),
              backgroundColor: cs.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showOptionsMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: cs.primary),
              title: Text('Edit', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit functionality')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: cs.primary),
              title: Text('Duplicate', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Duplicate functionality')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.drive_file_move, color: cs.primary),
              title: Text('Move to', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Move functionality')),
                );
              },
            ),
            Divider(color: cs.outlineVariant),
            ListTile(
              leading: Icon(Icons.delete, color: cs.error),
              title: Text('Delete', style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Delete Note?', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to delete "${note.title}"?',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to notes list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Note "${note.title}" deleted'),
                  backgroundColor: cs.error,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text('Delete', style: TextStyle(color: cs.onError)),
          ),
        ],
      ),
    );
  }
}
