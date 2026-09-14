enum KanbanStatus { backlog, currentSprint, ongoing, testing, done, onHold }

class KanbanCardDto {
  final String id;
  final String title;
  final String? description;
  final KanbanStatus status;
  final int order;
  final String? sprint;
  final String projectId;

  KanbanCardDto({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.order,
    this.sprint,
    required this.projectId,
  });

  factory KanbanCardDto.fromJson(Map<String, dynamic> json) {
    KanbanStatus parseStatus(dynamic val) {
      if (val is int) {
        switch (val) {
          case 0:
            return KanbanStatus.backlog;
          case 1:
            return KanbanStatus.currentSprint;
          case 2:
            return KanbanStatus.ongoing;
          case 3:
            return KanbanStatus.testing;
          case 4:
            return KanbanStatus.done;
          case 5:
            return KanbanStatus.onHold;
          default:
            return KanbanStatus.backlog;
        }
      }

      final str = val?.toString().toLowerCase().replaceAll(' ', '') ?? '';
      if (str.contains('backlog') || str == '0') return KanbanStatus.backlog;
      if (str.contains('sprint') || str == '1') return KanbanStatus.currentSprint;
      if (str.contains('ongoing') || str.contains('progress') || str == '2') return KanbanStatus.ongoing;
      if (str.contains('test') || str == '3') return KanbanStatus.testing;
      if (str.contains('done') || str == '4') return KanbanStatus.done;
      if (str.contains('hold') || str == '5') return KanbanStatus.onHold;

      return KanbanStatus.backlog;
    }

    return KanbanCardDto(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'])?.toString() ?? '',
      description: (json['description'] ?? json['Description'])?.toString(),
      status: parseStatus(json['status'] ?? json['Status']),
      order: json['order'] is int
          ? json['order']
          : int.tryParse((json['order'] ?? json['Order'])?.toString() ?? '0') ?? 0,
      sprint: (json['sprint'] ?? json['Sprint'] ?? json['sprintName'] ?? json['SprintName'])?.toString(),
      projectId: (json['projectId'] ??
          json['ProjectId'] ??
          json['boardId'] ??
          json['BoardId'])
          ?.toString() ??
          '',
    );
  }
}