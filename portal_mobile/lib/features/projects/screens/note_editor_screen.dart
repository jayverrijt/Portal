import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/nord_theme.dart';
import '../models/project_models.dart';
import '../providers/project_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String projectId;
  final NoteDto? initialNote;

  const NoteEditorScreen({
    super.key,
    required this.projectId,
    this.initialNote,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TabController _tabController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _contentController = TextEditingController(text: widget.initialNote?.content ?? '');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    final success = await ref.read(projectActionsProvider.notifier).saveNote(
      noteId: widget.initialNote?.id,
      projectId: widget.projectId,
      title: title,
      content: _contentController.text,
    );
    setState(() => _isSaving = false);

    if (mounted && success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialNote == null ? 'Nieuwe Notitie' : 'Bewerk Notitie'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: NordColors.nord8,
          labelColor: NordColors.nord8,
          unselectedLabelColor: NordColors.nord4,
          tabs: const [Tab(text: 'Bewerken'), Tab(text: 'Preview')],
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: NordColors.nord8,
              ),
            )
                : const Icon(Icons.check, color: NordColors.nord14),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: NordColors.nord6,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Titel van notitie...',
                    hintStyle: TextStyle(color: NordColors.nord3),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(color: NordColors.nord2),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(color: NordColors.nord5, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Schrijf markdown content hier...',
                      hintStyle: TextStyle(color: NordColors.nord3),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: _contentController.text.isEmpty
                    ? '*Geen inhoud*'
                    : _contentController.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: NordColors.nord5, fontSize: 14),
                  h1: const TextStyle(color: NordColors.nord8, fontWeight: FontWeight.bold),
                  code: const TextStyle(
                    color: NordColors.nord7,
                    backgroundColor: NordColors.nord1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}