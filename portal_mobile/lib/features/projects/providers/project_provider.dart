import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/project_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final projectsProvider = FutureProvider.autoDispose<List<ProjectDto>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.dio.get('/Project');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((json) => ProjectDto.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    debugPrint('Fout bij ophalen projecten: $e');
    return [];
  }
});

final projectCardsProvider = FutureProvider.autoDispose.family<List<KanbanCardDto>, String>((ref, projectId) async {
  final client = ref.watch(apiClientProvider);

  try {
    List<dynamic> rawBoards = [];

    if (projectId.isNotEmpty) {
      final res = await client.dio.get('/Boards', queryParameters: {'projectId': projectId});
      if (res.statusCode == 200 && res.data is List && (res.data as List).isNotEmpty) {
        rawBoards = res.data as List;
      }
    }

    if (rawBoards.isEmpty) {
      final allRes = await client.dio.get('/Boards');
      if (allRes.statusCode == 200 && allRes.data is List) {
        final list = allRes.data as List;
        final matched = list.where((b) {
          final pId = (b['projectId'] ?? b['ProjectId'])?.toString() ?? '';
          return pId.toLowerCase() == projectId.toLowerCase();
        }).toList();

        rawBoards = matched.isNotEmpty ? matched : list;
      }
    }

    if (rawBoards.isEmpty) {
      return [];
    }

    final firstBoard = rawBoards.first as Map<String, dynamic>;
    final boardId = (firstBoard['id'] ?? firstBoard['Id'])?.toString() ?? '';

    if (boardId.isEmpty) {
      return [];
    }

    final cardsRes = await client.dio.get('/FlowBoard', queryParameters: {'boardId': boardId});
    if (cardsRes.statusCode == 200 && cardsRes.data is List) {
      return (cardsRes.data as List)
          .map((j) => KanbanCardDto.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e, stack) {
    debugPrint('Fout bij ophalen FlowBoard kaarten: $e\n$stack');
    return [];
  }
});

final projectNotesProvider = FutureProvider.autoDispose.family<List<NoteDto>, String>((ref, projectId) async {
  final client = ref.watch(apiClientProvider);

  try {
    final res = await client.dio.get('/Notes', queryParameters: {'projectId': projectId});
    if (res.statusCode == 200 && res.data is List) {
      return (res.data as List)
          .map((j) => NoteDto.fromJson(j as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return [];
  } catch (e) {
    debugPrint('Fout bij ophalen notities: $e');
    return [];
  }
});

class ProjectActionsNotifier extends Notifier<void> {
  late final ApiClient _client;

  @override
  void build() {
    _client = ref.watch(apiClientProvider);
  }

  Future<String?> _resolveBoardId(String projectId) async {
    try {
      final res = await _client.dio.get('/Boards', queryParameters: {'projectId': projectId});
      if (res.statusCode == 200 && res.data is List && (res.data as List).isNotEmpty) {
        final first = res.data.first as Map<String, dynamic>;
        return (first['id'] ?? first['Id'])?.toString();
      }

      final allRes = await _client.dio.get('/Boards');
      if (allRes.statusCode == 200 && allRes.data is List) {
        final list = allRes.data as List;
        final match = list.firstWhere(
              (b) => ((b['projectId'] ?? b['ProjectId'])?.toString().toLowerCase() == projectId.toLowerCase()),
          orElse: () => list.isNotEmpty ? list.first : null,
        );
        if (match != null) {
          return (match['id'] ?? match['Id'])?.toString();
        }
      }
    } catch (e) {
      debugPrint('Fout bij resolven van boardId: $e');
    }
    return null;
  }

  // --- Project Actions ---

  Future<bool> createProject(String title, String? description) async {
    try {
      final res = await _client.dio.post('/Project', data: {
        'title': title,
        'description': description,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidate(projectsProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij project aanmaken: $e');
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      final res = await _client.dio.delete('/Project/$id');
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectsProvider);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij project verwijderen: $e');
      return false;
    }
  }

  // --- FlowBoard Card Actions ---

  Future<bool> createCard({
    required String projectId,
    String? boardId,
    required String title,
    String? description,
    required KanbanStatus status,
    int? sprintNumber,
  }) async {
    try {
      final effectiveBoardId = boardId ?? await _resolveBoardId(projectId);
      if (effectiveBoardId == null || effectiveBoardId.isEmpty) {
        debugPrint('Fout: Geen geldig boardId gevonden voor projectId $projectId');
        return false;
      }

      final payload = {
        'boardId': effectiveBoardId,
        'title': title,
        'description': (description != null && description.isNotEmpty) ? description : null,
        'status': status.index,
        'sprintNumber': sprintNumber ?? 1,
        'labelIds': <String>[],
      };

      final res = await _client.dio.post('/FlowBoard', data: payload);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidate(projectCardsProvider(projectId));
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('Dio error bij aanmaken kaart: ${e.response?.statusCode} - ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Fout bij aanmaken kaart: $e');
      return false;
    }
  }

  Future<bool> editCard({
    required String projectId,
    required String cardId,
    required String title,
    String? description,
    required KanbanStatus status,
  }) async {
    try {
      final res = await _client.dio.put('/FlowBoard/$cardId', data: {
        'title': title,
        'description': (description != null && description.isNotEmpty) ? description : null,
        'status': status.index,
      });
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectCardsProvider(projectId));
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('Dio error bij bewerken kaart: ${e.response?.statusCode} - ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Fout bij bewerken kaart: $e');
      return false;
    }
  }

  Future<bool> deleteCard(String projectId, String cardId) async {
    try {
      final res = await _client.dio.delete('/FlowBoard/$cardId');
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectCardsProvider(projectId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij verwijderen kaart: $e');
      return false;
    }
  }

  Future<bool> updateCardStatus(String projectId, String cardId, KanbanStatus status) async {
    try {
      final res = await _client.dio.patch(
        '/FlowBoard/$cardId/status',
        data: {'status': status.index},
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectCardsProvider(projectId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij status updaten: $e');
      return false;
    }
  }

  // --- Notes Actions ---

  Future<bool> saveNote({
    String? noteId,
    required String projectId,
    required String title,
    required String content,
  }) async {
    try {
      final data = {
        'title': title,
        'content': content,
        'projectId': projectId,
      };

      final res = noteId == null
          ? await _client.dio.post('/Notes', data: data)
          : await _client.dio.put('/Notes/$noteId', data: data);

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        ref.invalidate(projectNotesProvider(projectId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij notitie opslaan: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String projectId, String noteId) async {
    try {
      final res = await _client.dio.delete('/Notes/$noteId');
      if (res.statusCode == 200 || res.statusCode == 204) {
        ref.invalidate(projectNotesProvider(projectId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fout bij notitie verwijderen: $e');
      return false;
    }
  }
}

final projectActionsProvider = NotifierProvider<ProjectActionsNotifier, void>(() {
  return ProjectActionsNotifier();
});