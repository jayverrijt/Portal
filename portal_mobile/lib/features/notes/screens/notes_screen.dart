import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../projects/screens/note_editor_screen.dart';

final allNotesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.dio.get('/Notes');
    if (res.statusCode == 200 && res.data is List) {
      return res.data as List;
    }
    return [];
  } catch (e) {
    debugPrint('Fout bij ophalen alle notities: $e');
    return [];
  }
});

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  void _confirmDeleteNote(BuildContext context, WidgetRef ref, String noteId, String noteTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: NordColors.nord11, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Notitie Verwijderen',
                      style: TextStyle(
                        color: NordColors.nord6,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: NordColors.nord4),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Weet je zeker dat je "$noteTitle" wilt verwijderen? Dit kan niet ongedaan worden gemaakt.',
              style: const TextStyle(color: NordColors.nord4, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: NordColors.nord2,
                      foregroundColor: NordColors.nord6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Annuleren'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NordColors.nord11,
                      foregroundColor: NordColors.nord6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await ref.read(projectActionsProvider.notifier).deleteNote('', noteId);
                      ref.invalidate(allNotesProvider);
                    },
                    child: const Text('Verwijderen', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);
    final apiClient = ref.read(apiClientProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('Notities', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            tooltip: 'Vernieuwen',
            onPressed: () => ref.refresh(allNotesProvider),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: NordColors.nord1,
        child: FutureBuilder<Response>(
          future: apiClient.dio.get('/UserSettings'),
          builder: (context, snapshot) {
            String displayName = 'Portal Gebruiker';
            String? profilePictureUrl;

            if (snapshot.hasData && snapshot.data?.data != null) {
              final data = snapshot.data!.data;
              displayName = data['fullName'] ?? 'Portal Gebruiker';
              if (displayName.trim().isEmpty) displayName = 'Portal Gebruiker';
              profilePictureUrl = data['profilePictureUrl'];
            }

            return Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: NordColors.nord0,
                    border: Border(bottom: BorderSide(color: NordColors.nord2)),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: NordColors.nord8, width: 1.5),
                            color: NordColors.nord1,
                          ),
                          child: ClipOval(
                            child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                                ? Image.network(
                              profilePictureUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 24,
                                color: NordColors.nord4,
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 24,
                              color: NordColors.nord4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              color: NordColors.nord6,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: NordColors.nord4),
                  title: const Text('Dashboard', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_outlined, color: NordColors.nord4),
                  title: const Text('Projecten', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/projects');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_kanban_outlined, color: NordColors.nord4),
                  title: const Text('FlowBoards', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/flowboards');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined, color: NordColors.nord8),
                  title: const Text('Notities', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
                  selected: true,
                  selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
                  title: const Text('Financiën', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/budget');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.widgets_outlined, color: NordColors.nord4),
                  title: const Text('Utils', style: TextStyle(color: NordColors.nord4)),
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
                    leading: const Icon(Icons.settings_outlined, color: NordColors.nord4),
                    title: const Text('Instellingen', style: TextStyle(color: NordColors.nord4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/settings');
                    },
                  ),
                ),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordColors.nord8,
        foregroundColor: NordColors.nord0,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NoteEditorScreen(projectId: '')),
          ).then((_) => ref.refresh(allNotesProvider));
        },
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NordColors.nord8)),
        error: (err, _) => Center(child: Text('Fout bij laden notities: $err', style: const TextStyle(color: NordColors.nord11))),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('Geen notities gevonden.', style: TextStyle(color: NordColors.nord3)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final title = note['title'] ?? 'Geen titel';
              final content = note['content'] ?? 'Geen inhoud...';
              final noteId = note['id']?.toString() ?? '';
              final projectId = note['projectId']?.toString() ?? '';
              final hasProject = projectId.isNotEmpty;

              DateTime? createdAt;
              if (note['createdAt'] != null) {
                createdAt = DateTime.tryParse(note['createdAt']);
              }

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NoteEditorScreen(
                        projectId: projectId,
                        initialNote: note,
                      ),
                    ),
                  ).then((_) => ref.refresh(allNotesProvider));
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                              title,
                              style: const TextStyle(
                                color: NordColors.nord6,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NoteEditorScreen(
                                        projectId: projectId,
                                        initialNote: note,
                                      ),
                                    ),
                                  ).then((_) => ref.refresh(allNotesProvider));
                                },
                                child: const Icon(Icons.edit_outlined, size: 16, color: NordColors.nord4),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _confirmDeleteNote(context, ref, noteId, title),
                                child: const Icon(Icons.delete_outline, size: 16, color: NordColors.nord11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          content.isEmpty ? 'Geen inhoud...' : content,
                          style: const TextStyle(color: NordColors.nord5, fontSize: 12),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Divider(color: NordColors.nord2, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt) : '',
                            style: const TextStyle(color: NordColors.nord3, fontSize: 10),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: hasProject ? NordColors.nord8.withValues(alpha: 0.15) : NordColors.nord3.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              hasProject ? 'Gekoppeld' : 'Persoonlijk',
                              style: TextStyle(
                                color: hasProject ? NordColors.nord8 : NordColors.nord4,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}