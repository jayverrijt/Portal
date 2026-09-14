import 'kanban_card_dto.dart';
import 'note_dto.dart';

class ProjectDto {
  final String id;
  final String title;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final List<NoteDto> notes;
  final List<KanbanCardDto> cards;

  ProjectDto({
    required this.id,
    required this.title,
    this.description,
    required this.ownerId,
    required this.createdAt,
    this.notes = const [],
    this.cards = const [],
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
      cards: (json['cards'] as List<dynamic>?)
          ?.map((c) => KanbanCardDto.fromJson(c as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}