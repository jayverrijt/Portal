import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../models/project_models.dart';
import 'flowboard_screen.dart';

final allBoardsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.dio.get('/Boards');
    if (res.statusCode == 200 && res.data is List) {
      return res.data as List;
    }
    return [];
  } catch (e) {
    debugPrint('Fout bij ophalen boards: $e');
    return [];
  }
});

class FlowboardsHubScreen extends ConsumerWidget {
  const FlowboardsHubScreen({super.key});

  void _showNewBoardDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.view_kanban_outlined, color: NordColors.nord8, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Nieuw Bord Aanmaken',
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
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: NordColors.nord6),
                decoration: InputDecoration(
                  labelText: 'Bord Titel',
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
                maxLines: 3,
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
              const SizedBox(height: 20),
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
                        backgroundColor: NordColors.nord8,
                        foregroundColor: NordColors.nord0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isNotEmpty) {
                          try {
                            final client = ref.read(apiClientProvider);
                            await client.dio.post('/Boards', data: {
                              'title': title,
                              'description': descController.text.trim(),
                            });
                            ref.invalidate(allBoardsProvider);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } catch (e) {
                            debugPrint('Fout bij aanmaken bord: $e');
                          }
                        }
                      },
                      child: const Text('Aanmaken', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _confirmDeleteBoard(BuildContext context, WidgetRef ref, String boardId, String boardTitle) {
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
                      'Bord Verwijderen',
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
              'Weet je zeker dat je het bord "$boardTitle" wilt verwijderen? Dit kan niet ongedaan worden gemaakt.',
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
                      try {
                        final client = ref.read(apiClientProvider);
                        await client.dio.delete('/Boards/$boardId');
                        ref.invalidate(allBoardsProvider);
                      } catch (e) {
                        debugPrint('Fout bij verwijderen bord: $e');
                      }
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
    final boardsAsync = ref.watch(allBoardsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final apiClient = ref.read(apiClientProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('FlowBoards Hub', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            tooltip: 'Vernieuwen',
            onPressed: () => ref.refresh(allBoardsProvider),
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
                  leading: const Icon(Icons.view_kanban_outlined, color: NordColors.nord8),
                  title: const Text('FlowBoards', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
                  selected: true,
                  selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined, color: NordColors.nord4),
                  title: const Text('Notities', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/notes');
                  },
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FlowBoard Hub',
                        style: TextStyle(color: NordColors.nord6, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Beheer al je losse Trello/Kanban borden',
                        style: TextStyle(color: NordColors.nord4, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NordColors.nord8,
                    foregroundColor: NordColors.nord0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nieuw Bord'),
                  onPressed: () => _showNewBoardDialog(context, ref),
                ),
              ],
            ),
          ),
          Expanded(
            child: boardsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: NordColors.nord8)),
              error: (err, _) => Center(child: Text('Fout bij laden borden: $err', style: const TextStyle(color: NordColors.nord11))),
              data: (boards) {
                if (boards.isEmpty) {
                  return const Center(
                    child: Text('Geen borden gevonden.', style: TextStyle(color: NordColors.nord3)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final board = boards[index];
                    final boardId = board['id']?.toString() ?? '';
                    final title = board['title'] ?? 'Naamloos bord';
                    final description = board['description'] ?? '';
                    final projectId = board['projectId']?.toString() ?? '';

                    DateTime? createdAt;
                    if (board['createdAt'] != null) {
                      createdAt = DateTime.tryParse(board['createdAt']);
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
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
                              GestureDetector(
                                onTap: () => _confirmDeleteBoard(context, ref, boardId, title),
                                child: const Icon(Icons.delete_outline, color: NordColors.nord11, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              description.isEmpty ? 'Geen beschrijving' : description,
                              style: const TextStyle(color: NordColors.nord4, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Divider(color: NordColors.nord2, height: 12),
                          Text(
                            createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt) : '',
                            style: const TextStyle(color: NordColors.nord3, fontSize: 10),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NordColors.nord8.withValues(alpha: 0.2),
                                foregroundColor: NordColors.nord8,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                projectsAsync.whenData((projects) {
                                  final matchedProject = projects.firstWhere(
                                        (p) => p.id == projectId,
                                    orElse: () => ProjectDto(
                                      id: projectId.isNotEmpty ? projectId : 'default',
                                      title: title,
                                      description: description,
                                      createdAt: DateTime.now(),
                                      notes: [],
                                      cards: [],
                                      ownerId: '',
                                    ),
                                  );

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => FlowboardScreen(
                                        project: matchedProject,
                                        source: 'hub',
                                      ),
                                    ),
                                  );
                                });
                              },
                              child: const Text('Openen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}