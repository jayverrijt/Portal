import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/nord_theme.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exact op de hoogte van jouw getekende zwarte lijn (ongeveer 32% van het scherm)
    final double cardTopPosition = MediaQuery.of(context).size.height * 0.32;

    return Scaffold(
      backgroundColor: NordColors.nord0,
      body: Stack(
        children: [
          // 1. Gehele achtergrond in de mooie gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [NordColors.nord10, NordColors.nord8],
              ),
            ),
          ),

          // 2. De Login Card precies op de hoogte van jouw lijn
          Positioned.fill(
            top: cardTopPosition,
            child: Container(
              decoration: const BoxDecoration(
                color: NordColors.nord1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 20,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                // Voldoende ruimte boven zodat de velden onder het logo vallen
                padding: const EdgeInsets.fromLTRB(28, 52, 28, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final authState = ref.watch(authNotifierProvider);
                              if (authState.errorMessage == null) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: NordColors.nord11.withValues(alpha: 0.15),
                                  border: Border.all(color: NordColors.nord11),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(color: NordColors.nord11, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                          const Text(
                            'E-mailadres',
                            style: TextStyle(color: NordColors.nord8, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: NordColors.nord6),
                            decoration: InputDecoration(
                              hintText: 'jouw@email.nl',
                              hintStyle: const TextStyle(color: NordColors.nord3),
                              filled: true,
                              fillColor: NordColors.nord0,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Voer een e-mailadres in';
                              if (!val.contains('@')) return 'Ongeldig e-mailadres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Wachtwoord',
                            style: TextStyle(color: NordColors.nord8, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: NordColors.nord6),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(color: NordColors.nord3),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: NordColors.nord3,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: NordColors.nord0,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (val) =>
                            (val == null || val.isEmpty) ? 'Voer je wachtwoord in' : null,
                          ),
                          const SizedBox(height: 32),
                          Consumer(
                            builder: (context, ref, _) {
                              final authState = ref.watch(authNotifierProvider);
                              return ElevatedButton(
                                onPressed: authState.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NordColors.nord10,
                                  foregroundColor: NordColors.nord6,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: NordColors.nord6,
                                  ),
                                )
                                    : const Text(
                                  'SIGN IN',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have account? ", style: TextStyle(color: NordColors.nord4, fontSize: 13)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Gecentreerd Logo precies op de rand van de card (op de zwarte lijn)
          Positioned(
            top: cardTopPosition - 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: NordColors.nord1,
                  shape: BoxShape.circle,
                  border: Border.all(color: NordColors.nord8, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt,
                    color: NordColors.nord13,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}