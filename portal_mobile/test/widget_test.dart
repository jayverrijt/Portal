import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_mobile/features/auth/providers/auth_provider.dart';
import 'package:portal_mobile/features/projects/models/project_models.dart';
import 'package:portal_mobile/features/projects/providers/project_provider.dart';
import 'package:portal_mobile/features/projects/screens/projects_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.authenticated);
  }
}

void main() {
  testWidgets('PortalApp smoke test renders projects screen and mock projects', (WidgetTester tester) async {
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
        child: const MaterialApp(
          home: ProjectsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Projecten'), findsOneWidget);
    expect(find.text('Project Alpha'), findsOneWidget);
  });
}