import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/nord_theme.dart';
import '../models/project_models.dart';
import '../providers/project_provider.dart';

class FlowboardScreen extends ConsumerStatefulWidget {
  final ProjectDto project;

  const FlowboardScreen({super.key, required this.project});

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
        title: Row(
          children: [
            const Icon(Icons.bolt, color: NordColors.nord13, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'FlowBoard: ${widget.project.title}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordColors.nord8,
        foregroundColor: NordColors.nord0,
        onPressed: () => _openCardDialog(context, initialStatus: _statuses[_tabController.index]),
        child: const Icon(Icons.add),
      ),
      body: cardsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NordColors.nord8),
        ),
        error: (err, _) => Center(
          child: Text(
            'Fout bij laden kaarten: $err',
            style: const TextStyle(color: NordColors.nord11),
          ),
        ),
        data: (cards) {
          return TabBarView(
            controller: _tabController,
            children: _statuses.map((status) {
              final columnCards = cards.where((c) => c.status == status).toList()
                ..sort((a, b) => a.order.compareTo(b.order));

              if (columnCards.isEmpty) {
                return const Center(
                  child: Text('Geen kaarten', style: TextStyle(color: NordColors.nord3)),
                );
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: NordColors.nord6,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (card.sprint != null && card.sprint!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NordColors.nord2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        card.sprint!,
                        style: const TextStyle(
                          color: NordColors.nord4,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (card.description != null && card.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  card.description!,
                  style: const TextStyle(color: NordColors.nord4, fontSize: 12),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card == null ? 'Nieuwe Kaart' : 'Kaart Bewerken',
                        style: const TextStyle(
                          color: NordColors.nord6,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (card != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: NordColors.nord11),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ref.read(projectActionsProvider.notifier).deleteCard(
                              widget.project.id,
                              card.id,
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    autofocus: card == null,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      labelStyle: TextStyle(color: NordColors.nord4),
                      filled: true,
                      fillColor: NordColors.nord2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: const InputDecoration(
                      labelText: 'Beschrijving (optioneel)',
                      labelStyle: TextStyle(color: NordColors.nord4),
                      filled: true,
                      fillColor: NordColors.nord2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Status / Kolom:', style: TextStyle(color: NordColors.nord4, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<KanbanStatus>(
                    initialValue: selectedStatus,
                    dropdownColor: NordColors.nord2,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: NordColors.nord2,
                    ),
                    items: _statuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabels[s]!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedStatus = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NordColors.nord8,
                      foregroundColor: NordColors.nord0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                          sprintNumber: 1,
                        );
                      } else {
                        if (card.status != selectedStatus) {
                          await notifier.updateCardStatus(widget.project.id, card.id, selectedStatus);
                        }
                        await notifier.editCard(
                          projectId: widget.project.id,
                          cardId: card.id,
                          title: title,
                          description: descController.text.trim(),
                          status: selectedStatus,
                        );
                      }
                    },
                    child: Text(card == null ? 'Aanmaken' : 'Opslaan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}