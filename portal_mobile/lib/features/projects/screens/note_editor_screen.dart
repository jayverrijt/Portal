import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/nord_theme.dart';
import '../providers/project_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String projectId;
  final dynamic initialNote;

  const NoteEditorScreen({
    super.key,
    required this.projectId,
    this.initialNote,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _contentController = TextEditingController(text: widget.initialNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titel is verplicht')),
      );
      return;
    }

    try {
      final notifier = ref.read(projectActionsProvider.notifier);

      final success = await notifier.saveNote(
        noteId: widget.initialNote?.id,
        projectId: widget.projectId,
        title: title,
        content: content,
      );

      if (success && mounted) {
        // Forceer direct verversing van zowel de notities als de projectenlijst
        ref.invalidate(projectNotesProvider(widget.projectId));
        ref.invalidate(projectsProvider);

        // Kleine pauze zodat de provider de nieuwe data ophaalt voordat we terugkeren
        await Future.delayed(const Duration(milliseconds: 50));

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opslaan mislukt op de server'), backgroundColor: NordColors.nord11),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij opslaan: $e'), backgroundColor: NordColors.nord11),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: Text(
          widget.initialNote == null ? 'Nieuwe Notitie' : 'Notitie Bewerken',
          style: const TextStyle(color: NordColors.nord6),
        ),
        iconTheme: const IconThemeData(color: NordColors.nord6),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: NordColors.nord8),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: NordColors.nord6, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Notitietitel...',
                hintStyle: const TextStyle(color: NordColors.nord3),
                filled: true,
                fillColor: NordColors.nord1,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: NordColors.nord5),
                decoration: InputDecoration(
                  hintText: 'Schrijf je markdown content hier...',
                  hintStyle: const TextStyle(color: NordColors.nord3),
                  filled: true,
                  fillColor: NordColors.nord1,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}