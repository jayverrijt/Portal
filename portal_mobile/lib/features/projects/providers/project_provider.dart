import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/project_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final projectsProvider = FutureProvider.autoDispose<List<ProjectDto>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.dio.get('/projects');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List).map((json) => ProjectDto.fromJson(json)).toList();
    }
    return [];
  } on DioException catch (_) {
    return [];
  }
});

class ProjectActionsNotifier extends Notifier<void> {
  late final ApiClient _client;

  @override
  void build() {
    _client = ref.watch(apiClientProvider);
  }

  Future<bool> createProject(String title, String? description) async {
    try {
      final res = await _client.dio.post('/projects', data: {
        'title': title,
        'description': description,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidate(projectsProvider);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      final res = await _client.dio.delete('/projects/$id');
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectsProvider);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveNote({
    String? noteId,
    required String projectId,
    required String title,
    required String content,
  }) async {
    try {
      final data = {'title': title, 'content': content, 'projectId': projectId};
      final res = noteId == null
          ? await _client.dio.post('/projects/$projectId/notes', data: data)
          : await _client.dio.put('/projects/$projectId/notes/$noteId', data: data);

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        ref.invalidate(projectsProvider);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCardStatus(String projectId, String cardId, KanbanStatus status) async {
    try {
      final res = await _client.dio.patch(
        '/projects/$projectId/cards/$cardId/status',
        data: {'status': status.index},
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectsProvider);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final projectActionsProvider = NotifierProvider<ProjectActionsNotifier, void>(() {
  return ProjectActionsNotifier();
});