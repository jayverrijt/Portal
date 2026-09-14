class NoteDto {
  final String id;
  final String title;
  final String content;
  final String? projectId;
  final DateTime createdAt;

  NoteDto({
    required this.id,
    required this.title,
    required this.content,
    this.projectId,
    required this.createdAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'])?.toString() ?? '',
      content: (json['content'] ?? json['Content'])?.toString() ?? '',
      projectId: (json['projectId'] ?? json['ProjectId'])?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['CreatedAt'])?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'projectId': projectId,
    'createdAt': createdAt.toIso8601String(),
  };
}