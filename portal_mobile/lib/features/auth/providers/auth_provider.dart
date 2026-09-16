import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../projects/providers/project_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiClient _apiClient;

  @override
  AuthState build() {
    _apiClient = ref.watch(apiClientProvider);
    checkAuthStatus();
    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final hasToken = await _apiClient.hasToken();
    state = state.copyWith(
      status: hasToken ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] ?? response.data['accessToken'];
        if (token != null) {
          await _apiClient.saveToken(token.toString());
          state = state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
          );
          return true;
        }
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'Ongeldige inloggegevens.',
      );
      return false;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Inloggen mislukt. Controleer je verbinding.';
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: message.toString(),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'Er is een onverwachte fout opgetreden.',
      );
      return false;
    }
  }

  /// Handig om direct een vernieuwd token op te slaan na het updaten van profiel/instellingen,
  /// zodat de UI (zoals de sidebar/profielfoto) direct ververst zonder herinloggen.
  Future<void> updateToken(String newToken) async {
    await _apiClient.saveToken(newToken);
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});