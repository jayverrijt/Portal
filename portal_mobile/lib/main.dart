import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/nord_theme.dart';

void main() {
  runApp(const ProviderScope(child: PortalApp()));
}

class PortalApp extends ConsumerWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Portal',
      debugShowCheckedModeBanner: false,
      theme: NordTheme.darkTheme,
      routerConfig: router,
    );
  }
}