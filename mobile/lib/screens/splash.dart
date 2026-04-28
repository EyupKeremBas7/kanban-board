import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';
import 'package:mobile/screens/login.dart';
import 'package:mobile/screens/signup.dart';
import 'package:mobile/widgets/bottom_nav_shell.dart';

/// Karşılama ekranı — referans: giris.jpeg
/// Otomatik giriş kontrolü yapar. Giriş yapılmışsa direkt ana ekrana yönlendirir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final authViewModel = context.read<AuthViewModel>();
    final isLoggedIn = await authViewModel.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavShell()),
        (route) => false,
      );
    }
    // Giriş yapılmamışsa splash ekranında kal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo ve başlık
              Icon(
                Icons.dashboard_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Kanban Board',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Her şeyi zahmetsizce düzenleyin',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(flex: 3),
              // Üye Ol butonu
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Üye Ol'),
                ),
              ),
              const SizedBox(height: 12),
              // Oturum Aç butonu
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Oturum Aç'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
