import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/note.dart';
import 'note_viewer_page.dart';

/// Enhanced Notes Page with Two Distinct Sections
/// - Main Notes Section: For regular notes with full features
/// - Sticky Notes Section: For quick, pinned notes
class EnhancedNotesPage extends StatefulWidget {
  const EnhancedNotesPage({super.key});

  @override
  State<EnhancedNotesPage> createState() => _EnhancedNotesPageState();
}

class _EnhancedNotesPageState extends State<EnhancedNotesPage> {
  String? _selectedCategoryId;
  String? _currentFolderId;
  final List<String> _folderPath = []; // For breadcrumb navigation

  // Demo data
  late List<Note> _mainNotes;
  late List<NoteFolder> _folders;
  late List<StickyNote> _stickyNotes;

  @override
  void initState() {
    super.initState();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // Create demo folders (from old notes page)
    _folders = [
      // Academic folders
      NoteFolder(
        id: 'folder_1',
        name: 'Lecture Notes',
        categoryId: 'academic',
        icon: Icons.school,
      ),
      NoteFolder(
        id: 'folder_2',
        name: 'Textbooks',
        categoryId: 'academic',
        icon: Icons.menu_book,
      ),
      NoteFolder(
        id: 'folder_2_1',
        name: 'Mathematics',
        categoryId: 'academic',
        parentFolderId: 'folder_2',
        icon: Icons.calculate,
      ),
      NoteFolder(
        id: 'folder_2_2',
        name: 'Physics',
        categoryId: 'academic',
        parentFolderId: 'folder_2',
        icon: Icons.science,
      ),
      // Study folders
      NoteFolder(
        id: 'folder_3',
        name: 'Study Materials',
        categoryId: 'study',
        icon: Icons.library_books,
      ),
      NoteFolder(
        id: 'folder_4',
        name: 'Practice Papers',
        categoryId: 'study',
        icon: Icons.assignment,
      ),
      // Personal folders
      NoteFolder(
        id: 'folder_5',
        name: 'Journal',
        categoryId: 'personal',
        icon: Icons.edit_note,
      ),
      NoteFolder(
        id: 'folder_6',
        name: 'Ideas',
        categoryId: 'personal',
        icon: Icons.lightbulb,
      ),
    ];

    // Main notes (with folder organization)
    _mainNotes = [
      // Academic notes
      Note(
        id: 'note_1',
        title: 'Introduction to Calculus',
        type: NoteType.text,
        categoryId: 'academic',
        folderId: 'folder_1',
        content: '''# Calculus Fundamentals

## Key Concepts:
- Limits and continuity
- Derivatives and applications
- Integration techniques
- Fundamental theorem of calculus

## Important Formulas:
- d/dx(x^n) = nx^(n-1)
- ∫x^n dx = x^(n+1)/(n+1) + C

## Practice Problems:
1. Find the derivative of f(x) = 3x^2 + 2x + 1
2. Evaluate ∫(2x + 3)dx''',
        tags: ['math', 'calculus', 'important'],
      ),
      Note(
        id: 'note_2',
        title: 'Physics - Newton\'s Laws',
        type: NoteType.text,
        categoryId: 'academic',
        folderId: 'folder_2_2',
        content: '''# Newton's Laws of Motion

## First Law (Inertia):
An object at rest stays at rest, and an object in motion stays in motion unless acted upon by an external force.

## Second Law (F = ma):
The acceleration of an object is directly proportional to the net force acting on it and inversely proportional to its mass.

## Third Law (Action-Reaction):
For every action, there is an equal and opposite reaction.

## Applications:
- Rocket propulsion
- Car collisions
- Walking mechanics''',
        tags: ['physics', 'laws', 'mechanics'],
      ),
      Note(
        id: 'note_3',
        title: 'Linear Algebra Notes',
        type: NoteType.text,
        categoryId: 'academic',
        folderId: 'folder_2_1',
        content: '''# Linear Algebra

## Vectors and Matrices:
- Vector operations
- Matrix multiplication
- Determinants
- Eigenvalues and eigenvectors''',
        tags: ['math', 'algebra'],
      ),
      // Study notes
      Note(
        id: 'note_4',
        title: 'Study Guide - Final Exam',
        type: NoteType.text,
        categoryId: 'study',
        folderId: 'folder_3',
        content: '''# Final Exam Study Guide

## Topics to Review:
✓ Chapters 1-5
✓ All practice problems
✓ Lab reports
✓ Quiz mistakes

## Study Schedule:
- Week 1: Chapters 1-2
- Week 2: Chapters 3-4
- Week 3: Chapter 5 + Review
- Week 4: Practice exams

## Resources:
- Textbook chapters
- Professor's notes
- Online tutorials
- Study group sessions''',
        tags: ['exam', 'study', 'final'],
      ),
      Note(
        id: 'note_5',
        title: 'Practice Test 2023',
        type: NoteType.pdf,
        categoryId: 'study',
        folderId: 'folder_4',
        filePath: 'demo/practice_test.pdf',
        tags: ['practice', 'test'],
      ),
      // Personal notes
      Note(
        id: 'note_6',
        title: 'Daily Journal - October 2025',
        type: NoteType.text,
        categoryId: 'personal',
        folderId: 'folder_5',
        content: '''# Daily Reflections

## October 23, 2025
Today was productive. Completed most of my tasks.

### Achievements:
- Finished calculus assignment
- Studied for 3 hours
- Organized notes

### Tomorrow's Goals:
- Review physics chapter
- Complete practice problems''',
        tags: ['journal', 'october'],
      ),
      Note(
        id: 'note_7',
        title: 'Project Ideas',
        type: NoteType.text,
        categoryId: 'personal',
        folderId: 'folder_6',
        content: '''# Creative Project Ideas

## App Development:
1. Budget tracker with AI insights
2. Study planner with spaced repetition
3. Recipe organizer with meal planning

## Research Topics:
- Machine learning in education
- Sustainable energy solutions
- Mental health tech applications

## Side Projects:
- Personal blog about coding journey
- YouTube channel for tutorials
- Open source contributions''',
        tags: ['ideas', 'projects', 'creative'],
      ),
      Note(
        id: 'note_8',
        title: 'Reading List - Fall 2025',
        type: NoteType.text,
        categoryId: 'personal',
        content: '''# Books to Read

## Technical:
📚 Clean Code by Robert Martin
📚 Design Patterns by Gang of Four
📚 The Pragmatic Programmer

## Non-Fiction:
📖 Atomic Habits by James Clear
📖 Deep Work by Cal Newport
📖 Thinking, Fast and Slow

## Fiction:
📕 The Martian
📕 Project Hail Mary
📕 Foundation Series''',
        tags: ['books', 'reading', 'learning'],
      ),
    ];

    // Sticky notes
    _stickyNotes = [
      StickyNote(
        id: 'sticky_1',
        content: '🎯 Exam on Friday - Review chapters 3-5',
        color: const Color(0xFFFFEB3B), // Yellow
        isPinned: true,
      ),
      StickyNote(
        id: 'sticky_2',
        content: '📝 Submit assignment by Monday 11:59 PM',
        color: const Color(0xFFFF9800), // Orange
        isPinned: true,
      ),
      StickyNote(
        id: 'sticky_3',
        content: '💡 Project idea: Build a study tracker app',
        color: const Color(0xFF4CAF50), // Green
        isPinned: false,
      ),
      StickyNote(
        id: 'sticky_4',
        content: '📞 Call advisor about course selection',
        color: const Color(0xFF2196F3), // Blue
        isPinned: false,
      ),
      StickyNote(
        id: 'sticky_5',
        content: '🏃 Don\'t forget gym at 5 PM today',
        color: const Color(0xFFE91E63), // Pink
        isPinned: false,
      ),
      StickyNote(
        id: 'sticky_6',
        content: '🛒 Buy: notebooks, pens, highlighters',
        color: const Color(0xFF9C27B0), // Purple
        isPinned: false,
      ),
    ];
  }

  // Helper methods for folder navigation
  List<NoteFolder> _getFoldersForCurrentView() {
    if (_selectedCategoryId == null) return [];

    return _folders.where((folder) {
      return folder.categoryId == _selectedCategoryId &&
          folder.parentFolderId == _currentFolderId;
    }).toList();
  }

  List<Note> _getNotesForCurrentView() {
    if (_selectedCategoryId == null) return [];

    return _mainNotes.where((note) {
      return note.categoryId == _selectedCategoryId &&
          note.folderId == _currentFolderId;
    }).toList();
  }

  void _navigateToFolder(NoteFolder folder) {
    setState(() {
      _currentFolderId = folder.id;
      _folderPath.add(folder.name);
    });
  }

  void _navigateBack() {
    if (_folderPath.isNotEmpty) {
      setState(() {
        _folderPath.removeLast();
        // Find parent folder
        if (_currentFolderId != null) {
          final currentFolder = _folders.firstWhere(
            (f) => f.id == _currentFolderId,
          );
          _currentFolderId = currentFolder.parentFolderId;
        }
      });
    } else {
      setState(() {
        _selectedCategoryId = null;
        _currentFolderId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest, // Pure black X-style
      body: CustomScrollView(
        slivers: [
          // App Bar - X-style minimal
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: cs.surfaceContainerLowest, // Pure black
            surfaceTintColor: Colors.transparent,
            leading: (_selectedCategoryId != null || _folderPath.isNotEmpty)
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.onSurface),
                    onPressed: _navigateBack,
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                _selectedCategoryId != null
                    ? Categories.getById(_selectedCategoryId!).name
                    : 'My Notes',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 24, // X-style bold title
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.15), // Twitter blue hint
                      cs.secondary.withOpacity(0.1), // Pink hint
                      cs.tertiary.withOpacity(0.1), // Purple hint
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Breadcrumb navigation if in folder
          if (_folderPath.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _BreadcrumbNavigation(
                  path: _folderPath,
                  onTap: (index) {
                    setState(() {
                      _folderPath.removeRange(index + 1, _folderPath.length);
                      // Navigate to appropriate folder
                      if (index == -1) {
                        _currentFolderId = null;
                      } else {
                        // Find folder by path
                        String? targetId;
                        for (var folder in _folders) {
                          if (folder.name == _folderPath[index]) {
                            targetId = folder.id;
                            break;
                          }
                        }
                        _currentFolderId = targetId;
                      }
                    });
                  },
                ),
              ),
            ),

          // Show sticky notes only on main view (no category selected)
          if (_selectedCategoryId == null) ...[
            // Sticky Notes Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.push_pin, color: cs.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Sticky Notes',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.info_outline,
                      color: cs.onSurfaceVariant,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Notes Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final sticky = _stickyNotes[index];
                  return _StickyNoteCard(
                    stickyNote: sticky,
                    onTap: () => _editStickyNote(sticky),
                    onPin: () => _togglePin(sticky),
                  );
                }, childCount: _stickyNotes.length),
              ),
            ),

            // Spacing between sections
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Categories Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.category, color: cs.secondary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Categories',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Grid
            _buildCategoryGrid(cs),
          ],

          // Show folder and notes list when category is selected
          if (_selectedCategoryId != null) _buildFolderAndNotesList(cs),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: _selectedCategoryId == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Add Sticky Note
                FloatingActionButton.small(
                  heroTag: 'sticky',
                  onPressed: () => _addStickyNote(),
                  backgroundColor: cs.tertiaryContainer,
                  child: Icon(Icons.add, color: cs.onTertiaryContainer),
                ),
                const SizedBox(height: 12),
                // Add Main Note
                FloatingActionButton.extended(
                  heroTag: 'note',
                  onPressed: () => _addMainNote(),
                  backgroundColor: cs.primaryContainer,
                  icon: Icon(Icons.edit, color: cs.onPrimaryContainer),
                  label: Text(
                    'New Note',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: () => _showCreateNoteDialog(context),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('New Note'),
            ),
    );
  }

  Widget _buildCategoryGrid(ColorScheme cs) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final category = Categories.all[index];
          final noteCount = _mainNotes
              .where((n) => n.categoryId == category.id)
              .length;

          return _CategoryCard(
            category: category,
            noteCount: noteCount,
            onTap: () {
              setState(() {
                _selectedCategoryId = category.id;
                _currentFolderId = null;
                _folderPath.clear();
              });
            },
          );
        }, childCount: Categories.all.length),
      ),
    );
  }

  Widget _buildFolderAndNotesList(ColorScheme cs) {
    final folders = _getFoldersForCurrentView();
    final notes = _getNotesForCurrentView();

    if (folders.isEmpty && notes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 80,
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No notes yet',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first note to get started',
                style: TextStyle(
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Folders
          if (folders.isNotEmpty) ...[
            Text(
              'Folders',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...folders.map(
              (folder) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FolderCard(
                  folder: folder,
                  onTap: () => _navigateToFolder(folder),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Notes
          if (notes.isNotEmpty) ...[
            Text(
              'Notes',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...notes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MainNoteCard(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteViewerPage(note: note),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 100), // Space for FAB
        ]),
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text('Create New Note', style: TextStyle(color: cs.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.description, color: cs.primary),
              title: Text('Text Note', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text note creation')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: cs.error),
              title: Text(
                'PDF Document',
                style: TextStyle(color: cs.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('PDF upload')));
              },
            ),
            ListTile(
              leading: Icon(Icons.folder, color: cs.tertiary),
              title: Text('New Folder', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Folder creation')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _togglePin(StickyNote sticky) {
    setState(() {
      final index = _stickyNotes.indexWhere((s) => s.id == sticky.id);
      if (index != -1) {
        _stickyNotes[index] = sticky.copyWith(isPinned: !sticky.isPinned);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sticky.isPinned ? 'Note unpinned' : 'Note pinned'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _editStickyNote(StickyNote sticky) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit sticky note (feature coming soon)')),
    );
  }

  void _addStickyNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add sticky note (feature coming soon)')),
    );
  }

  void _addMainNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add main note (feature coming soon)')),
    );
  }
}

/// Sticky Note Card Widget
class _StickyNoteCard extends StatelessWidget {
  final StickyNote stickyNote;
  final VoidCallback onTap;
  final VoidCallback onPin;

  const _StickyNoteCard({
    required this.stickyNote,
    required this.onTap,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: stickyNote.color.withOpacity(0.9),
      elevation: stickyNote.isPinned ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: stickyNote.isPinned
            ? BorderSide(color: stickyNote.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      stickyNote.content,
                      style: const TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Timestamp
                  Text(
                    _formatTime(stickyNote.createdAt),
                    style: TextStyle(
                      color: const Color(0xFF212121).withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Pin button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  stickyNote.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  color: const Color(0xFF212121),
                  size: 18,
                ),
                onPressed: onPin,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Main Note Card Widget
class _MainNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _MainNoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final category = Categories.getById(note.categoryId);

    return Card(
      color: cs.surfaceContainerHigh,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and icon
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 14, color: category.color),
                        const SizedBox(width: 6),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: category.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Note type icon
                  Icon(note.type.icon, color: cs.onSurfaceVariant, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                note.title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Content preview
              if (note.content != null)
                Text(
                  note.content!,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 16),
              // Tags and metadata
              Row(
                children: [
                  // Tags
                  if (note.tags.isNotEmpty)
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: note.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Updated time
                  Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final EventCategory category;
  final int noteCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.noteCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: category.color.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 40, color: category.color),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Folder Card Widget
class _FolderCard extends StatelessWidget {
  final NoteFolder folder;
  final VoidCallback onTap;

  const _FolderCard({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(folder.icon, size: 32, color: cs.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  folder.name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Breadcrumb Navigation Widget
class _BreadcrumbNavigation extends StatelessWidget {
  final List<String> path;
  final Function(int) onTap;

  const _BreadcrumbNavigation({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < path.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ),
            GestureDetector(
              onTap: () => onTap(i),
              child: Text(
                path[i],
                style: TextStyle(
                  color: i == path.length - 1
                      ? cs.primary
                      : cs.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: i == path.length - 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sticky Note Model
class StickyNote {
  final String id;
  final String content;
  final Color color;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  StickyNote({
    required this.id,
    required this.content,
    required this.color,
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  StickyNote copyWith({
    String? content,
    Color? color,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return StickyNote(
      id: id,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
