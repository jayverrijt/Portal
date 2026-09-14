import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

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
      body: projectsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NordColors.nord8),
        ),
        error: (err, _) => Center(
          child: Text(
            'Fout bij ophalen: $err',
            style: const TextStyle(color: NordColors.nord11),
          ),
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
                    '${project.notes.length} notities • ${DateFormat('dd MMM yyyy').format(project.createdAt)}',
                    style: const TextStyle(color: NordColors.nord4, fontSize: 12),
                  ),
                  children: [
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
                                Text(
                                  DateFormat('dd MMM HH:mm').format(note.createdAt),
                                  style: const TextStyle(
                                    color: NordColors.nord3,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: NordColors.nord2, height: 16),
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