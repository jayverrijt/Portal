import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_mobile/features/auth/providers/auth_provider.dart';
import 'package:portal_mobile/features/projects/models/project_models.dart';
import 'package:portal_mobile/features/projects/providers/project_provider.dart';
import 'package:portal_mobile/main.dart';

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.authenticated);
  }
}

void main() {
  testWidgets('PortalApp smoke test renders appbar and mock projects', (WidgetTester tester) async {
    final mockProjects = [
      ProjectDto(
        id: '1',
        title: 'Project Alpha',
        ownerId: 'user-1',
        createdAt: DateTime(2026, 1, 1),
        notes: [],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthNotifier()),
          projectsProvider.overrideWith((ref) async => mockProjects),
        ],
        child: const PortalApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Portal Projecten'), findsOneWidget);
    expect(find.text('Project Alpha'), findsOneWidget);
  });
}