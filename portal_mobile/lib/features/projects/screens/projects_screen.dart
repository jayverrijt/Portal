import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import 'flowboard_screen.dart';
import 'note_editor_screen.dart';
import 'package:go_router/go_router.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  void _showNewProjectDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NordColors.nord1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nieuw Project', style: TextStyle(color: NordColors.nord6)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: NordColors.nord6),
              decoration: InputDecoration(
                labelText: 'Titel',
                labelStyle: const TextStyle(color: NordColors.nord4),
                filled: true,
                fillColor: NordColors.nord0,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: const TextStyle(color: NordColors.nord6),
              decoration: InputDecoration(
                labelText: 'Beschrijving (optioneel)',
                labelStyle: const TextStyle(color: NordColors.nord4),
                filled: true,
                fillColor: NordColors.nord0,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: NordColors.nord8,
              foregroundColor: NordColors.nord0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                await ref
                    .read(projectActionsProvider.notifier)
                    .createProject(title, descController.text.trim());
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Aanmaken'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, WidgetRef ref, String projectId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NordColors.nord1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Project verwijderen', style: TextStyle(color: NordColors.nord6)),
        content: Text(
          'Weet je zeker dat je "$title" wilt verwijderen? Dit kan niet ongedaan worden gemaakt.',
          style: const TextStyle(color: NordColors.nord4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuleren', style: TextStyle(color: NordColors.nord4)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NordColors.nord11,
              foregroundColor: NordColors.nord6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(projectActionsProvider.notifier).deleteProject(projectId);
            },
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('Projecten', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            tooltip: 'Vernieuwen',
            onPressed: () => ref.refresh(projectsProvider),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: NordColors.nord1,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: NordColors.nord0,
                border: Border(bottom: BorderSide(color: NordColors.nord2)),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: NordColors.nord1,
                            shape: BoxShape.circle,
                            border: Border.all(color: NordColors.nord2),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: NordColors.nord13,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Portal',
                          style: TextStyle(
                            color: NordColors.nord6,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Productivity Suite',
                      style: TextStyle(color: NordColors.nord4, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: NordColors.nord4),
              title: const Text('Home', style: TextStyle(color: NordColors.nord4)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: NordColors.nord8),
              title: const Text('Projecten', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
              selected: true,
              selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
              title: const Text('Budget & Financiën', style: TextStyle(color: NordColors.nord4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/budget');
              },
            ),
            ListTile(
              leading: const Icon(Icons.widgets_outlined, color: NordColors.nord4),
              title: const Text('Tools', style: TextStyle(color: NordColors.nord4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/tools');
              },
            ),
            const Spacer(),
            const Divider(color: NordColors.nord2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                leading: const Icon(Icons.logout, color: NordColors.nord11),
                title: const Text('Uitloggen', style: TextStyle(color: NordColors.nord11)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authNotifierProvider.notifier).logout();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_off_outlined, size: 64, color: NordColors.nord3),
                  const SizedBox(height: 16),
                  const Text(
                    'Geen projecten gevonden.',
                    style: TextStyle(color: NordColors.nord4, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Dashboard Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NordColors.nord1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NordColors.nord2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Actieve Projecten', '${projects.length}', Icons.folder_special, NordColors.nord8),
                    Container(height: 30, width: 1, color: NordColors.nord2),
                    _buildStatItem('Totaal Notities', '${projects.fold(0, (sum, p) => sum + p.notes.length)}', Icons.note_alt, NordColors.nord14),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Project Cards List
              ...projects.map((project) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: NordColors.nord1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NordColors.nord2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  collapsedIconColor: NordColors.nord4,
                  iconColor: NordColors.nord8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NordColors.nord8.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder, color: NordColors.nord8),
                  ),
                  title: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NordColors.nord6,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${project.notes.length} notities • ${project.cards.length} taken • ${DateFormat('dd MMM yyyy').format(project.createdAt)}',
                      style: const TextStyle(color: NordColors.nord4, fontSize: 12),
                    ),
                  ),
                  children: [
                    // Grotere, prominentere actieknoppen
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: NordColors.nord8.withValues(alpha: 0.2),
                                    foregroundColor: NordColors.nord8,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.view_kanban_outlined, size: 20),
                                  label: const Text('FlowBoard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => FlowboardScreen(project: project),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: NordColors.nord14.withValues(alpha: 0.2),
                                    foregroundColor: NordColors.nord14,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.notes_rounded, size: 20),
                                  label: Text('Notities (${project.notes.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProjectNotesScreen(project: project),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NordColors.nord11,
                                side: BorderSide(color: NordColors.nord11.withValues(alpha: 0.4)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Project Verwijderen'),
                              onPressed: () => _confirmDeleteProject(
                                context,
                                ref,
                                project.id,
                                project.title,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: NordColors.nord2, height: 24),

                    // Compacte Preview van max 2 notities
                    if (project.notes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Text(
                          'Geen documentatie voor dit project.',
                          style: TextStyle(
                            color: NordColors.nord3,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recente Notities (Preview)',
                              style: TextStyle(color: NordColors.nord4, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...project.notes.take(2).map((note) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: NordColors.nord0,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: NordColors.nord2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.note, size: 16, color: NordColors.nord8),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: NordColors.nord6,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 16, color: NordColors.nord3),
                                ],
                              ),
                            )),
                            if (project.notes.length > 2)
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProjectNotesScreen(project: project),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Bekijk alle ${project.notes.length} notities...',
                                    style: const TextStyle(color: NordColors.nord8, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: NordColors.nord4, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

// Dedicated Notes Overzichtsscherm per Project
class ProjectNotesScreen extends StatelessWidget {
  final dynamic project;

  const ProjectNotesScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: Text('Notities: ${project.title}', style: const TextStyle(color: NordColors.nord6, fontSize: 18)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: NordColors.nord8),
            tooltip: 'Nieuwe Notitie',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(projectId: project.id),
                ),
              );
            },
          ),
        ],
      ),
      body: project.notes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 64, color: NordColors.nord3),
            const SizedBox(height: 16),
            const Text(
              'Geen notities voor dit project.',
              style: TextStyle(color: NordColors.nord4, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: NordColors.nord8,
                foregroundColor: NordColors.nord0,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Eerste notitie maken'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteEditorScreen(projectId: project.id),
                  ),
                );
              },
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: project.notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = project.notes[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NordColors.nord1,
              borderRadius: BorderRadius.circular(16),
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
                          fontWeight: FontWeight.bold,
                          color: NordColors.nord8,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: NordColors.nord4, size: 20),
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
                const Divider(color: NordColors.nord2, height: 16),
                MarkdownBody(
                  data: note.content,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: NordColors.nord5, fontSize: 13),
                    code: const TextStyle(color: NordColors.nord7, backgroundColor: NordColors.nord0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}