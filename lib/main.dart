import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'theme/app_theme.dart';
import 'services/profile_manager.dart';
import 'services/evaluation_service.dart';
import 'screens/profile_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ← CAMBIAR AQUÍ
  );
  await EvaluationService.init();

  runApp(const ConoceTApp());
}

class ConoceTApp extends StatelessWidget {
  const ConoceTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConoceT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
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
    // Realizamos la lógica de perfil mientras el Splash Nativo sigue visible
    final manager = ProfileManager();
    final showOnboarding = await manager.shouldShowOnboarding();
    final hasSession = await manager.hasActiveSession();
    
    if (!mounted) return;

    // Una vez decidida la ruta, quitamos el Splash nativo
    FlutterNativeSplash.remove();

    if (showOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

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
    // Retornamos un contenedor con el mismo color de fondo del splash nativo
    // para que no haya parpadeos antes de la navegación.
    return const Scaffold(
      backgroundColor: Color(0xFF1A1F3C),
      body: SizedBox.expand(),
    );
  }
}
