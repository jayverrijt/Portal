enum KanbanStatus { backlog, currentSprint, ongoing, testing, done, onHold }

enum MoscowPriority { mustHave, shouldHave, couldHave, wontHave }

class SubTaskDto {
  final String id;
  final String title;
  final int status; // 0 = Todo, 1 = Testing, 2 = Done
  final String cardId;

  SubTaskDto({
    required this.id,
    required this.title,
    required this.status,
    required this.cardId,
  });

  factory SubTaskDto.fromJson(Map<String, dynamic> json) {
    return SubTaskDto(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'])?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      cardId: (json['cardId'] ?? json['CardId'])?.toString() ?? '',
    );
  }
}

class KanbanCardDto {
  final String id;
  final String title;
  final String? description;
  final KanbanStatus status;
  final int order;
  final String? sprint;
  final int? sprintNumber;
  final MoscowPriority? moscowPriority;
  final List<SubTaskDto> subTasks;
  final String projectId;

  KanbanCardDto({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.order,
    this.sprint,
    this.sprintNumber,
    this.moscowPriority,
    this.subTasks = const [],
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

    MoscowPriority? parseMoscow(dynamic val) {
      if (val is int && val >= 0 && val < MoscowPriority.values.length) {
        return MoscowPriority.values[val];
      }
      return null;
    }

    final rawSubTasks = json['subTasks'] ?? json['SubTasks'];
    final List<SubTaskDto> subTasksList = rawSubTasks is List
        ? rawSubTasks.map((st) => SubTaskDto.fromJson(st as Map<String, dynamic>)).toList()
        : [];

    final parsedOrder = json['order'] is int
        ? json['order']
        : int.tryParse((json['order'] ?? json['Order'])?.toString() ?? '0') ?? 0;

    return KanbanCardDto(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'])?.toString() ?? '',
      description: (json['description'] ?? json['Description'])?.toString(),
      status: parseStatus(json['status'] ?? json['Status']),
      order: parsedOrder,
      sprint: (json['sprint'] ?? json['Sprint'] ?? json['sprintName'] ?? json['SprintName'])?.toString(),
      sprintNumber: json['sprintNumber'] ?? json['SprintNumber'],
      moscowPriority: parseMoscow(json['moscowPriority'] ?? json['MoscowPriority']),
      subTasks: subTasksList,
      projectId: (json['projectId'] ?? json['ProjectId'] ?? json['boardId'] ?? json['BoardId'])?.toString() ?? '',
    );
  }
}