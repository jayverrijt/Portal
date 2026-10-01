import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/project_models.dart';
import '../providers/project_provider.dart';

class FlowboardScreen extends ConsumerStatefulWidget {
  final ProjectDto project;
  final String source;

  const FlowboardScreen({
    super.key,
    required this.project,
    this.source = 'hub',
  });

  @override
  ConsumerState<FlowboardScreen> createState() => _FlowboardScreenState();
}

class _FlowboardScreenState extends ConsumerState<FlowboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<KanbanStatus> _statuses = const [
    KanbanStatus.backlog,
    KanbanStatus.currentSprint,
    KanbanStatus.ongoing,
    KanbanStatus.testing,
    KanbanStatus.done,
    KanbanStatus.onHold,
  ];

  final Map<KanbanStatus, Color> _statusColors = const {
    KanbanStatus.backlog: NordColors.nord3,
    KanbanStatus.currentSprint: NordColors.nord9,
    KanbanStatus.ongoing: NordColors.nord13,
    KanbanStatus.testing: NordColors.nord15,
    KanbanStatus.done: NordColors.nord14,
    KanbanStatus.onHold: NordColors.nord11,
  };

  final Map<KanbanStatus, String> _statusLabels = const {
    KanbanStatus.backlog: 'Backlog',
    KanbanStatus.currentSprint: 'Current Sprint',
    KanbanStatus.ongoing: 'Ongoing',
    KanbanStatus.testing: 'Testing',
    KanbanStatus.done: 'Done',
    KanbanStatus.onHold: 'On Hold',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(projectCardsProvider(widget.project.id));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NordColors.nord6),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(Icons.bolt, color: NordColors.nord13, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'FlowBoard: ${widget.project.title}',
                style: const TextStyle(color: NordColors.nord6),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: NordColors.nord6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            onPressed: () => ref.refresh(projectCardsProvider(widget.project.id)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: NordColors.nord8,
          labelColor: NordColors.nord8,
          unselectedLabelColor: NordColors.nord4,
          tabs: _statuses.map((s) => Tab(text: _statusLabels[s])).toList(),
        ),
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
                          child: const Icon(Icons.bolt, color: NordColors.nord13, size: 24),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Portal',
                          style: TextStyle(color: NordColors.nord6, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Project & Finance Suite', style: TextStyle(color: NordColors.nord4, fontSize: 12)),
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
              leading: Icon(
                Icons.folder_outlined,
                color: widget.source == 'projects' ? NordColors.nord8 : NordColors.nord4,
              ),
              title: Text(
                'Projecten',
                style: TextStyle(
                  color: widget.source == 'projects' ? NordColors.nord6 : NordColors.nord4,
                  fontWeight: widget.source == 'projects' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: widget.source == 'projects',
              selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/projects');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.view_kanban_outlined,
                color: widget.source == 'hub' ? NordColors.nord8 : NordColors.nord4,
              ),
              title: Text(
                'FlowBoards',
                style: TextStyle(
                  color: widget.source == 'hub' ? NordColors.nord6 : NordColors.nord4,
                  fontWeight: widget.source == 'hub' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: widget.source == 'hub',
              selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        onPressed: () => _openCardDialog(context, initialStatus: _statuses[_tabController.index]),
        child: const Icon(Icons.add),
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NordColors.nord8)),
        error: (err, _) => Center(child: Text('Fout bij laden kaarten: $err', style: const TextStyle(color: NordColors.nord11))),
        data: (cards) {
          return TabBarView(
            controller: _tabController,
            children: _statuses.map((status) {
              final columnCards = cards.where((c) => c.status == status).toList()
                ..sort((a, b) => a.order.compareTo(b.order));

              if (columnCards.isEmpty) {
                return const Center(child: Text('Geen kaarten', style: TextStyle(color: NordColors.nord3)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: columnCards.length,
                itemBuilder: (context, index) {
                  final card = columnCards[index];
                  return _buildCardItem(card, _statusColors[status]!);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCardItem(KanbanCardDto card, Color accentColor) {
    final doneSubTasks = card.subTasks.where((st) => st.status == 2).length;
    final totalSubTasks = card.subTasks.length;

    return InkWell(
      onTap: () => _openCardDialog(context, card: card),
      borderRadius: BorderRadius.circular(8),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: NordColors.nord1,
        elevation: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: NordColors.nord6, fontSize: 14),
                    ),
                  ),
                  Row(
                    children: [
                      if (card.moscowPriority != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: NordColors.nord0,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: NordColors.nord2),
                          ),
                          child: Text(
                            card.moscowPriority.toString().split('.').last.toUpperCase(),
                            style: const TextStyle(color: NordColors.nord8, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (card.sprintNumber != null || (card.sprint != null && card.sprint!.isNotEmpty))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NordColors.nord2,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            card.sprintNumber != null ? 'S${card.sprintNumber}' : card.sprint!,
                            style: const TextStyle(color: NordColors.nord4, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (card.description != null && card.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(card.description!, style: const TextStyle(color: NordColors.nord4, fontSize: 12)),
              ],
              if (totalSubTasks > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.list_alt, size: 14, color: NordColors.nord4),
                    const SizedBox(width: 4),
                    Text(
                      'Subtasks: $doneSubTasks / $totalSubTasks',
                      style: const TextStyle(color: NordColors.nord4, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openCardDialog(BuildContext context, {KanbanCardDto? card, KanbanStatus? initialStatus}) {
    final titleController = TextEditingController(text: card?.title ?? '');
    final descController = TextEditingController(text: card?.description ?? '');
    var selectedStatus = card?.status ?? initialStatus ?? KanbanStatus.currentSprint;
    int selectedSprintNumber = card?.sprintNumber ?? 1;
    MoscowPriority? selectedMoscow = card?.moscowPriority;

    List<Map<String, dynamic>> subTasksList = card?.subTasks.map((st) => <String, dynamic>{
      'id': st.id.isNotEmpty ? st.id : null,
      'title': st.title,
      'status': st.status,
    }).toList() ?? [];

    final newSubTaskController = TextEditingController();
    int newSubTaskStatus = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card == null ? 'Nieuwe Use Case' : 'Use Case Bewerken',
                          style: const TextStyle(color: NordColors.nord6, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (card != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: NordColors.nord11),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await ref.read(projectActionsProvider.notifier).deleteCard(widget.project.id, card.id);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      autofocus: card == null,
                      style: const TextStyle(color: NordColors.nord6),
                      decoration: const InputDecoration(labelText: 'Titel (Use Case Naam)', filled: true, fillColor: NordColors.nord2),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: const TextStyle(color: NordColors.nord6),
                      decoration: const InputDecoration(labelText: 'Beschrijving (optioneel)', filled: true, fillColor: NordColors.nord2),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedSprintNumber,
                            dropdownColor: NordColors.nord2,
                            style: const TextStyle(color: NordColors.nord6),
                            decoration: const InputDecoration(labelText: 'Sprint', filled: true, fillColor: NordColors.nord2),
                            items: List.generate(10, (i) => i + 1).map((s) => DropdownMenuItem(value: s, child: Text('Sprint $s'))).toList(),
                            onChanged: (val) => setModalState(() => selectedSprintNumber = val ?? 1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<MoscowPriority?>(
                            initialValue: selectedMoscow,
                            dropdownColor: NordColors.nord2,
                            style: const TextStyle(color: NordColors.nord6),
                            decoration: const InputDecoration(labelText: 'MoSCoW Prioriteit', filled: true, fillColor: NordColors.nord2),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Geen')),
                              DropdownMenuItem(value: MoscowPriority.mustHave, child: Text('Must Have')),
                              DropdownMenuItem(value: MoscowPriority.shouldHave, child: Text('Should Have')),
                              DropdownMenuItem(value: MoscowPriority.couldHave, child: Text('Could Have')),
                              DropdownMenuItem(value: MoscowPriority.wontHave, child: Text('Won\'t Have')),
                            ],
                            onChanged: (val) => setModalState(() => selectedMoscow = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Status / Kolom:', style: TextStyle(color: NordColors.nord4, fontSize: 12)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<KanbanStatus>(
                      initialValue: selectedStatus,
                      dropdownColor: NordColors.nord2,
                      style: const TextStyle(color: NordColors.nord6),
                      decoration: const InputDecoration(filled: true, fillColor: NordColors.nord2),
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabels[s]!))).toList(),
                      onChanged: (val) => setModalState(() => selectedStatus = val ?? selectedStatus),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NordColors.nord0,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NordColors.nord2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.list_alt, color: NordColors.nord8, size: 18),
                              SizedBox(width: 6),
                              Text('Subtasks Workflow (Todo, Testing, Done)', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: newSubTaskController,
                                  style: const TextStyle(color: NordColors.nord6, fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Subtask titel...',
                                    hintStyle: TextStyle(color: NordColors.nord3),
                                    filled: true,
                                    fillColor: NordColors.nord2,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<int>(
                                  initialValue: newSubTaskStatus,
                                  dropdownColor: NordColors.nord2,
                                  style: const TextStyle(color: NordColors.nord6, fontSize: 12),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: NordColors.nord2,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 0, child: Text('Todo')),
                                    DropdownMenuItem(value: 1, child: Text('Testing')),
                                    DropdownMenuItem(value: 2, child: Text('Done')),
                                  ],
                                  onChanged: (val) => setModalState(() => newSubTaskStatus = val ?? 0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NordColors.nord8,
                                  foregroundColor: NordColors.nord0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Toevoegen', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  if (newSubTaskController.text.trim().isNotEmpty) {
                                    setModalState(() {
                                      subTasksList.add(<String, dynamic>{
                                        'title': newSubTaskController.text.trim(),
                                        'status': newSubTaskStatus,
                                      });
                                      newSubTaskController.clear();
                                      newSubTaskStatus = 0;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (subTasksList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Nog geen subtasks toegevoegd.', style: TextStyle(color: NordColors.nord3, fontSize: 12)),
                            )
                          else
                            ...subTasksList.map((st) {
                              final stStatus = st['status'] ?? 0;
                              String statusLabel = 'Todo';
                              Color statusColor = NordColors.nord3;
                              if (stStatus == 1) {
                                statusLabel = 'Testing';
                                statusColor = NordColors.nord13;
                              } else if (stStatus == 2) {
                                statusLabel = 'Done';
                                statusColor = NordColors.nord14;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: NordColors.nord1,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: NordColors.nord2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        st['title'],
                                        style: const TextStyle(color: NordColors.nord6, fontSize: 13),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: NordColors.nord11, size: 18),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => setModalState(() => subTasksList.remove(st)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NordColors.nord8,
                        foregroundColor: NordColors.nord0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        Navigator.pop(ctx);
                        final notifier = ref.read(projectActionsProvider.notifier);

                        if (card == null) {
                          await notifier.createCard(
                            projectId: widget.project.id,
                            title: title,
                            description: descController.text.trim(),
                            status: selectedStatus,
                            sprintNumber: selectedSprintNumber,
                            moscowPriority: selectedMoscow,
                            subTasks: subTasksList,
                          );
                        } else {
                          await notifier.editCard(
                            projectId: widget.project.id,
                            cardId: card.id,
                            title: title,
                            description: descController.text.trim(),
                            status: selectedStatus,
                            sprintNumber: selectedSprintNumber,
                            moscowPriority: selectedMoscow,
                            subTasks: subTasksList,
                          );
                        }
                      },
                      child: Text(card == null ? 'Aanmaken' : 'Opslaan', style: const TextStyle(fontWeight: FontWeight.bold)),
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
}