class KanbanBoardDto {
  final String id;
  final String title;
  final String projectId;

  KanbanBoardDto({
    required this.id,
    required this.title,
    required this.projectId,
  });

  factory KanbanBoardDto.fromJson(Map<String, dynamic> json) {
    return KanbanBoardDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      projectId: json['projectId']?.toString() ?? '',
    );
  }
}