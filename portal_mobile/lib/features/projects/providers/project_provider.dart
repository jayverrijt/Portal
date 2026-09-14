import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/api/api_client.dart';
import '../models/project_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authStateProvider = StateProvider<bool>((ref) => false);

final projectsProvider = FutureProvider.autoDispose<List<ProjectDto>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.dio.get('/projects');
    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;
      return list.map((json) => ProjectDto.fromJson(json)).toList();
    }
    return [];
  } on DioException catch (_) {
    return [];
  }
});