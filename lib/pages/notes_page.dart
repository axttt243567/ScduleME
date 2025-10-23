import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/note.dart';
import 'note_viewer_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? _selectedCategoryId;
  String? _currentFolderId;
  final List<String> _folderPath = []; // For breadcrumb navigation

  // Demo data
  late List<Note> _notes;
  late List<NoteFolder> _folders;

  @override
  void initState() {
    super.initState();
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // Create demo folders
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

    // Create demo notes
    _notes = [
      // Academic notes
      Note(
        id: 'note_1',
        title: 'Introduction to Calculus',
        type: NoteType.pdf,
        categoryId: 'academic',
        folderId: 'folder_1',
        filePath: 'demo/calculus_intro.pdf',
        tags: ['math', 'calculus'],
      ),
      Note(
        id: 'note_2',
        title: 'Class Notes - Week 1',
        type: NoteType.text,
        categoryId: 'academic',
        folderId: 'folder_1',
        content: '''# Week 1 - Introduction

## Topics Covered:
- Course overview
- Basic concepts
- Key terminology

## Important Points:
1. Review previous knowledge
2. Complete assigned readings
3. Prepare for next week's quiz

## Notes:
The professor emphasized the importance of understanding fundamental concepts before moving to advanced topics.''',
        tags: ['week1', 'introduction'],
      ),
      Note(
        id: 'note_3',
        title: 'Linear Algebra Textbook',
        type: NoteType.pdf,
        categoryId: 'academic',
        folderId: 'folder_2_1',
        filePath: 'demo/linear_algebra.pdf',
        tags: ['math', 'algebra'],
      ),
      Note(
        id: 'note_4',
        title: 'Physics Formulas',
        type: NoteType.text,
        categoryId: 'academic',
        folderId: 'folder_2_2',
        content: '''# Physics Formulas Cheat Sheet

## Mechanics:
- F = ma (Force = mass × acceleration)
- v = u + at (Final velocity)
- s = ut + ½at² (Displacement)

## Energy:
- KE = ½mv² (Kinetic Energy)
- PE = mgh (Potential Energy)
- W = Fd (Work)

## Waves:
- v = fλ (Wave velocity)
- f = 1/T (Frequency)''',
        tags: ['physics', 'formulas'],
      ),
      // Study notes
      Note(
        id: 'note_5',
        title: 'Study Guide - Final Exam',
        type: NoteType.pdf,
        categoryId: 'study',
        folderId: 'folder_3',
        filePath: 'demo/study_guide.pdf',
        tags: ['exam', 'final'],
      ),
      Note(
        id: 'note_6',
        title: 'Key Concepts Summary',
        type: NoteType.text,
        categoryId: 'study',
        folderId: 'folder_3',
        content: '''# Key Concepts to Remember

## Chapter 1: Fundamentals
- Definition of key terms
- Basic principles
- Core concepts

## Chapter 2: Applications
- Real-world examples
- Case studies
- Problem-solving techniques

## Chapter 3: Advanced Topics
- Complex theories
- Research methods
- Critical analysis

## Exam Tips:
✓ Review all highlighted sections
✓ Practice problems from each chapter
✓ Create concept maps
✓ Study in groups''',
        tags: ['summary', 'concepts'],
      ),
      Note(
        id: 'note_7',
        title: 'Practice Test 2023',
        type: NoteType.pdf,
        categoryId: 'study',
        folderId: 'folder_4',
        filePath: 'demo/practice_test.pdf',
        tags: ['practice', 'test'],
      ),
      // Personal notes
      Note(
        id: 'note_8',
        title: 'Daily Reflection - Oct 2025',
        type: NoteType.text,
        categoryId: 'personal',
        folderId: 'folder_5',
        content: '''# Daily Journal - October 2025

## October 23, 2025
Today was productive. Completed most of my tasks and felt accomplished.

### Achievements:
- Finished the calculus assignment
- Studied for 3 hours
- Organized my notes

### Tomorrow's Goals:
- Review physics chapter
- Complete practice problems
- Attend study group

### Reflections:
Time management is getting better. Need to maintain consistency.''',
        tags: ['journal', 'october'],
      ),
      Note(
        id: 'note_9',
        title: 'Project Ideas',
        type: NoteType.text,
        categoryId: 'personal',
        folderId: 'folder_6',
        content: '''# Project Ideas Collection

## App Development:
1. Study buddy matching app
2. Note-taking with AI assistance
3. Schedule optimizer

## Research Topics:
1. Machine learning in education
2. Productivity techniques
3. Sustainable learning methods

## Creative Projects:
1. Educational YouTube channel
2. Study blog
3. Podcast about student life

## Next Steps:
- Research feasibility
- Create action plans
- Set deadlines''',
        tags: ['ideas', 'projects'],
      ),
      // Notes without folders (directly under category)
      Note(
        id: 'note_10',
        title: 'Quick Notes',
        type: NoteType.text,
        categoryId: 'personal',
        content: '''# Quick Thoughts

- Remember to backup files
- Check email for assignment updates
- Buy new notebooks
- Schedule dentist appointment''',
        tags: ['quick', 'reminders'],
      ),
    ];
  }

  List<NoteFolder> _getFoldersForCurrentView() {
    if (_selectedCategoryId == null) return [];

    return _folders.where((folder) {
      return folder.categoryId == _selectedCategoryId &&
          folder.parentFolderId == _currentFolderId;
    }).toList();
  }

  List<Note> _getNotesForCurrentView() {
    if (_selectedCategoryId == null) return [];

    return _notes.where((note) {
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

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: cs.surface,
            leading: (_selectedCategoryId != null || _folderPath.isNotEmpty)
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.onSurface),
                    onPressed: _navigateBack,
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _selectedCategoryId != null
                    ? Categories.getById(_selectedCategoryId!).name
                    : 'Notes',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primaryContainer, cs.secondaryContainer],
                  ),
                ),
              ),
            ),
          ),

          // Breadcrumb if in folder
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

          // Content
          _selectedCategoryId == null
              ? _buildCategoryGrid(cs)
              : _buildFolderAndNotesList(cs),
        ],
      ),
      floatingActionButton: _selectedCategoryId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                _showCreateNoteDialog(context);
              },
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('New Note'),
            )
          : null,
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
          final noteCount = _notes
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
                padding: const EdgeInsets.only(bottom: 8),
                child: _NoteCard(
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
}

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

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: note.type == NoteType.pdf
                      ? const Color(0xFFFF4757).withOpacity(0.2)
                      : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  note.type.icon,
                  size: 24,
                  color: note.type == NoteType.pdf
                      ? const Color(0xFFFF4757)
                      : cs.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          note.type.displayName,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        if (note.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${note.tags.first}',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

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
