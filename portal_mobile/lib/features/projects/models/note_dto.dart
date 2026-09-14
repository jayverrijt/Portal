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