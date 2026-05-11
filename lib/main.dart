import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/profile_manager.dart';
import 'services/evaluation_service.dart';
import 'screens/profile_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EvaluationService.init();
  runApp(const EnrutaTApp());
}

class EnrutaTApp extends StatelessWidget {
  const EnrutaTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnrutaT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _SplashRouter(),
    );
  }
}

/// Decide a qué pantalla ir según si hay sesión activa.
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final manager = ProfileManager();
    final showOnboarding = await manager.shouldShowOnboarding();
    
    if (!mounted) return;

    if (showOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final hasSession = await manager.hasActiveSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            hasSession ? const HomeScreen() : const ProfileSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}