enum KanbanStatus { todo, inProgress, done }

class KanbanCardDto {
  final String id;
  final String title;
  final String? description;
  final KanbanStatus status;
  final int order;
  final String projectId;

  KanbanCardDto({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.order,
    required this.projectId,
  });

  factory KanbanCardDto.fromJson(Map<String, dynamic> json) {
    KanbanStatus parseStatus(dynamic val) {
      final str = val?.toString().toLowerCase() ?? '';
      if (str.contains('progress') || str == '1') return KanbanStatus.inProgress;
      if (str.contains('done') || str == '2') return KanbanStatus.done;
      return KanbanStatus.todo;
    }

    return KanbanCardDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: parseStatus(json['status']),
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      projectId: json['projectId']?.toString() ?? '',
    );
  }
}