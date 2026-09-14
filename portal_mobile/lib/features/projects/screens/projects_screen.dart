import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import 'flowboard_screen.dart';
import 'note_editor_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  void _showNewProjectDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NordColors.nord1,
        title: const Text('Nieuw Project', style: TextStyle(color: NordColors.nord6)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: NordColors.nord6),
              decoration: const InputDecoration(
                labelText: 'Titel',
                labelStyle: TextStyle(color: NordColors.nord4),
              ),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(color: NordColors.nord6),
              decoration: const InputDecoration(
                labelText: 'Beschrijving (optioneel)',
                labelStyle: TextStyle(color: NordColors.nord4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuleren', style: TextStyle(color: NordColors.nord4)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NordColors.nord8),
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                await ref
                    .read(projectActionsProvider.notifier)
                    .createProject(title, descController.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Aanmaken', style: TextStyle(color: NordColors.nord0)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard_outlined, color: NordColors.nord8, size: 22),
            SizedBox(width: 8),
            Text('Portal Projecten'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            onPressed: () => ref.refresh(projectsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: NordColors.nord11),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordColors.nord8,
        foregroundColor: NordColors.nord0,
        onPressed: () => _showNewProjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NordColors.nord8),
        ),
        error: (err, _) => Center(
          child: Text('Fout: $err', style: const TextStyle(color: NordColors.nord11)),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(
              child: Text(
                'Geen projecten gevonden.',
                style: TextStyle(color: NordColors.nord3),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.folder_outlined, color: NordColors.nord8),
                  title: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NordColors.nord6,
                    ),
                  ),
                  subtitle: Text(
                    '${project.notes.length} notities • ${project.cards.length} taken • ${DateFormat('dd MMM yyyy').format(project.createdAt)}',
                    style: const TextStyle(color: NordColors.nord4, fontSize: 12),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.view_kanban_outlined,
                              size: 16,
                              color: NordColors.nord8,
                            ),
                            label: const Text(
                              'FlowBoard',
                              style: TextStyle(color: NordColors.nord8),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FlowboardScreen(project: project),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.note_add_outlined,
                              size: 16,
                              color: NordColors.nord14,
                            ),
                            label: const Text(
                              'Notitie',
                              style: TextStyle(color: NordColors.nord14),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NoteEditorScreen(projectId: project.id),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: NordColors.nord11,
                            ),
                            onPressed: () => ref
                                .read(projectActionsProvider.notifier)
                                .deleteProject(project.id),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: NordColors.nord2),
                    if (project.notes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Geen documentatie voor dit project.',
                          style: TextStyle(
                            color: NordColors.nord3,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...project.notes.map((note) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NordColors.nord0,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: NordColors.nord2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: NordColors.nord8,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: NordColors.nord4,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => NoteEditorScreen(
                                          projectId: project.id,
                                          initialNote: note,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: NordColors.nord2, height: 12),
                            MarkdownBody(
                              data: note.content,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  color: NordColors.nord5,
                                  fontSize: 12,
                                ),
                                code: const TextStyle(
                                  color: NordColors.nord7,
                                  backgroundColor: NordColors.nord1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}