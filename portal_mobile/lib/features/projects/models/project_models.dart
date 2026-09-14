class ProjectDto {
  final String id;
  final String title;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final List<NoteDto> notes;

  ProjectDto({
    required this.id,
    required this.title,
    this.description,
    required this.ownerId,
    required this.createdAt,
    this.notes = const [],
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      ownerId: json['ownerId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      notes: (json['notes'] as List<dynamic>?)
          ?.map((n) => NoteDto.fromJson(n as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class NoteDto {
  final String id;
  final String title;
  final String content;
  final String projectId;
  final DateTime createdAt;

  NoteDto({
    required this.id,
    required this.title,
    required this.content,
    required this.projectId,
    required this.createdAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      projectId: json['projectId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}