import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/nord_theme.dart';
import '../models/project_models.dart';
import '../providers/project_provider.dart';

class FlowboardScreen extends ConsumerWidget {
  final ProjectDto project;

  const FlowboardScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${project.title} - FlowBoard'),
          bottom: const TabBar(
            indicatorColor: NordColors.nord8,
            labelColor: NordColors.nord8,
            unselectedLabelColor: NordColors.nord4,
            tabs: [
              Tab(text: 'To Do'),
              Tab(text: 'In Progress'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildColumn(context, ref, KanbanStatus.todo, NordColors.nord9),
            _buildColumn(context, ref, KanbanStatus.inProgress, NordColors.nord13),
            _buildColumn(context, ref, KanbanStatus.done, NordColors.nord14),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(
      BuildContext context,
      WidgetRef ref,
      KanbanStatus status,
      Color accentColor,
      ) {
    final cards = project.cards.where((c) => c.status == status).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return DragTarget<KanbanCardDto>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        ref.read(projectActionsProvider.notifier).updateCardStatus(
          project.id,
          details.data.id,
          status,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? NordColors.nord2.withValues(alpha: 0.3)
              : Colors.transparent,
          child: cards.isEmpty
              ? const Center(
            child: Text('Geen kaarten', style: TextStyle(color: NordColors.nord3)),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Draggable<KanbanCardDto>(
                data: card,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: _buildCardItem(card, accentColor, isDragging: true),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildCardItem(card, accentColor),
                ),
                child: _buildCardItem(card, accentColor),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCardItem(KanbanCardDto card, Color accentColor, {bool isDragging = false}) {
    return Card(
      elevation: isDragging ? 6 : 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: NordColors.nord6,
                fontSize: 14,
              ),
            ),
            if (card.description != null && card.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                card.description!,
                style: const TextStyle(color: NordColors.nord4, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}