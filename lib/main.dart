import 'package:flutter/material.dart';
import 'services/profile_manager.dart';
import 'screens/profile_selection_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CeprunsaApp());
}

class CeprunsaApp extends StatelessWidget {
  const CeprunsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEPRUNSA Vocacional',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
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
    final hasSession = await ProfileManager().hasActiveSession();
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