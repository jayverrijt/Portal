import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import 'flowboard_screen.dart';
import 'note_editor_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  // HCD-vriendelijke bottom sheet voor het aanmaken van een nieuw project
  void _showNewProjectDialog(BuildContext context, WidgetRef ref) {
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
                      Icon(Icons.create_new_folder_outlined, color: NordColors.nord8, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Nieuw Project',
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
                  labelText: 'Project Titel',
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
                          await ref
                              .read(projectActionsProvider.notifier)
                              .createProject(title, descController.text.trim());
                          if (ctx.mounted) Navigator.of(ctx).pop();
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

  // HCD-vriendelijke bottom sheet voor projectverwijdering
  void _confirmDeleteProject(BuildContext context, WidgetRef ref, String projectId, String title) {
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
                      'Project Verwijderen',
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
              'Weet je zeker dat je "$title" wilt verwijderen? Alle bijbehorende notities en taken gaan verloren. Dit kan niet ongedaan worden gemaakt.',
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
                      await ref.read(projectActionsProvider.notifier).deleteProject(projectId);
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

  // Webapp-style "Toegang Beheren" Bottom Sheet
  void _showShareDialog(BuildContext context, WidgetRef ref, String projectId, String projectTitle) {
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final client = ref.read(apiClientProvider);

            Future<List<dynamic>> fetchProjectMembers() async {
              try {
                final res = await client.dio.get('/Project/$projectId/members');
                if (res.statusCode == 200 && res.data is List) {
                  return res.data as List;
                }
              } catch (e) {
                debugPrint('Fout bij ophalen members: $e');
              }
              return [];
            }

            return Padding(
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
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.share_outlined, color: NordColors.nord8, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Toegang Beheren: $projectTitle',
                                  style: const TextStyle(
                                    color: NordColors.nord6,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: NordColors.nord4),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nieuw account machtigen',
                      style: TextStyle(color: NordColors.nord4, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            style: const TextStyle(color: NordColors.nord6),
                            decoration: InputDecoration(
                              hintText: 'collega@domein.nl',
                              hintStyle: const TextStyle(color: NordColors.nord3),
                              filled: true,
                              fillColor: NordColors.nord0,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NordColors.nord8,
                              foregroundColor: NordColors.nord0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text('Delen', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final email = emailController.text.trim();
                              if (email.isNotEmpty) {
                                try {
                                  await client.dio.post('/Project/$projectId/share', data: {'email': email});
                                  emailController.clear();
                                  setModalState(() {});
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Project succesvol gedeeld')),
                                    );
                                  }
                                } catch (e) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Fout bij delen: $e'), backgroundColor: NordColors.nord11),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<dynamic>>(
                      future: fetchProjectMembers(),
                      builder: (context, snapshot) {
                        final members = snapshot.data ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACTIEVE DEELNEMERS (${members.length})',
                              style: const TextStyle(color: NordColors.nord4, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 180),
                              child: snapshot.connectionState == ConnectionState.waiting
                                  ? const Center(child: CircularProgressIndicator(color: NordColors.nord8))
                                  : members.isEmpty
                                  ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: NordColors.nord0,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: NordColors.nord2),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Dit project is nog niet gedeeld met andere accounts.',
                                    style: TextStyle(color: NordColors.nord4, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                itemCount: members.length,
                                itemBuilder: (context, index) {
                                  final member = members[index];
                                  final memberEmail = member['email'] ?? 'Onbekend';
                                  final memberId = member['id']?.toString() ?? '';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: NordColors.nord0,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: NordColors.nord2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.person_outline, color: NordColors.nord8, size: 18),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  memberEmail,
                                                  style: const TextStyle(color: NordColors.nord6, fontSize: 13, fontWeight: FontWeight.w500),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: NordColors.nord11,
                                            side: BorderSide(color: NordColors.nord11.withValues(alpha: 0.6)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          icon: const Icon(Icons.person_remove_outlined, size: 14),
                                          label: const Text('Intrekken', style: TextStyle(fontSize: 12)),
                                          onPressed: () async {
                                            try {
                                              await client.dio.delete('/Project/$projectId/share/$memberId');
                                              setModalState(() {});
                                              if (ctx.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Toegang ingetrokken')),
                                                );
                                              }
                                            } catch (e) {
                                              if (ctx.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Fout bij intrekken: $e'), backgroundColor: NordColors.nord11),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: NordColors.nord2,
                          foregroundColor: NordColors.nord6,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Sluiten'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                      'Project & Finance Suite',
                      style: TextStyle(color: NordColors.nord4, fontSize: 12),
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
              leading: const Icon(Icons.folder_outlined, color: NordColors.nord8),
              title: const Text('Projecten', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
              selected: true,
              selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => Navigator.of(context).pop(),
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
                                        builder: (_) => FlowboardScreen(project: project, source: 'projects'),
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
                                        builder: (_) => ProjectNotesScreen(projectId: project.id, projectTitle: project.title),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: NordColors.nord8,
                                    side: BorderSide(color: NordColors.nord8.withValues(alpha: 0.4)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.share_outlined, size: 18),
                                  label: const Text('Toegang & Delen'),
                                  onPressed: () => _showShareDialog(context, ref, project.id, project.title),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: NordColors.nord11,
                                    side: BorderSide(color: NordColors.nord11.withValues(alpha: 0.4)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('Verwijderen'),
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

// Dedicated Notes Overzichtsscherm inclusief HCD delete dialoog
class ProjectNotesScreen extends ConsumerWidget {
  final String projectId;
  final String projectTitle;

  const ProjectNotesScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

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
              'Weet je zeker dat je "$noteTitle" wilt verwijderen?',
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
                      await ref.read(projectActionsProvider.notifier).deleteNote(projectId, noteId);
                      ref.invalidate(projectNotesProvider(projectId));
                      ref.invalidate(projectsProvider);
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
    final notesAsync = ref.watch(projectNotesProvider(projectId));

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NordColors.nord6),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Notities: $projectTitle', style: const TextStyle(color: NordColors.nord6, fontSize: 18)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: NordColors.nord8),
            tooltip: 'Nieuwe Notitie',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(projectId: projectId),
                ),
              );
            },
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NordColors.nord8)),
        error: (err, _) => Center(child: Text('Fout bij laden notities: $err', style: const TextStyle(color: NordColors.nord11))),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
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
                          builder: (_) => NoteEditorScreen(projectId: projectId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = notes[index];
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
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: NordColors.nord4, size: 20),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NoteEditorScreen(
                                      projectId: projectId,
                                      initialNote: note,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: NordColors.nord11, size: 20),
                              onPressed: () => _confirmDeleteNote(context, ref, note.id, note.title),
                            ),
                          ],
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
          );
        },
      ),
    );
  }
}