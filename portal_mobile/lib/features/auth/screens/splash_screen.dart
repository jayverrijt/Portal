import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/nord_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Korte pauze voor de sfeer en animatie
    await Future.delayed(const Duration(milliseconds: 1500));

    // Haal de auth state op
    final authState = ref.read(authNotifierProvider);

    // Controleer de status (indien geen error aanwezig is, gaan we door naar home)
    final bool isLoggedIn = authState.errorMessage == null;

    if (mounted) {
      if (isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.nord0,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [NordColors.nord1, NordColors.nord0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: NordColors.nord0,
                  shape: BoxShape.circle,
                  border: Border.all(color: NordColors.nord8, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: NordColors.nord8.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt,
                    color: NordColors.nord13,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Portal',
                style: TextStyle(
                  color: NordColors.nord6,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Project & Finance Suite',
                style: TextStyle(color: NordColors.nord4, fontSize: 13, letterSpacing: 0.5),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: NordColors.nord8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}