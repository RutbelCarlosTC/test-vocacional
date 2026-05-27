import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/user_profile.dart';
import '../services/profile_manager.dart';
import '../services/tour_service.dart';
import '../widgets/countdown_banner.dart';
import 'profile_selection_screen.dart';
import 'area_selection_screen.dart';
import 'global_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileManager _manager = ProfileManager();
  UserProfile? _profile;
  bool _loading = true;

  // Keys para el tour
  final GlobalKey _evalKey = GlobalKey();
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _manager.getActiveProfile();
    setState(() {
      _profile = profile;
      _loading = false;
    });

    if (profile != null && !profile.tourHomeShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
    }
  }

  void _startTour() {
    TargetPosition? evalPosition;
    TargetPosition? resultsPosition;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcular posición para Evaluación (ancho completo)
    final evalCtx = _evalKey.currentContext;
    if (evalCtx != null) {
      final box = evalCtx.findRenderObject() as RenderBox?;
      if (box != null) {
        final offset = box.localToGlobal(Offset.zero);
        evalPosition = TargetPosition(
          Size(screenWidth, box.size.height),
          Offset(0, offset.dy),
        );
      }
    }

    // Calcular posición para Resultados (ancho completo)
    final resultsCtx = _resultsKey.currentContext;
    if (resultsCtx != null) {
      final box = resultsCtx.findRenderObject() as RenderBox?;
      if (box != null) {
        final offset = box.localToGlobal(Offset.zero);
        resultsPosition = TargetPosition(
          Size(screenWidth, box.size.height),
          Offset(0, offset.dy),
        );
      }
    }

    TourService.showTour(
      context,
      targets: [
        TourService.createTarget(
          key: _evalKey,
          targetPosition: evalPosition,
          title: 'Realizar Evaluación',
          description: 'Presiona aquí para comenzar tus test vocacionales.',
        ),
        TourService.createTarget(
          key: _resultsKey,
          targetPosition: resultsPosition,
          title: 'Tus Resultados',
          description: 'Aquí podrás ver el progreso y resultados de tus test.',
        ),
      ],
      onFinish: () => _markTourAsShown(_profile!),
      onSkip: () => _markTourAsShown(_profile!),
    );
  }

  Future<void> _markTourAsShown(UserProfile profile) async {
    final updated = profile.copyWith(tourHomeShown: true);
    await _manager.saveProfile(updated);
    if (mounted) setState(() => _profile = updated);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cambiar de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _manager.clearSession();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const CountdownBanner(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/CONOCET_LOGO.png',
                    height: 250,
                  ),
                ),
                const SizedBox(height: 24),
                // Saludo
                _WelcomeBanner(profile: _profile),
                const SizedBox(height: 32),

                const Text(
                  '¿Qué deseas hacer?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Botón Evaluar
                _MenuCard(
                  key: _evalKey,
                  icon: Icons.assignment_outlined,
                  title: 'Realizar evaluación',
                  subtitle: 'Completa un test de orientación vocacional.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AreaSelectionScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Botón Consultar
                _MenuCard(
                  key: _resultsKey,
                  icon: Icons.history,
                  title: 'Consultar resultados',
                  subtitle: 'Revisa tus evaluaciones anteriores.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GlobalResultsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/LOGO CEPRUNSA-03.png',
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Widget interno: banner de bienvenida
// ──────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final UserProfile? profile;
  const _WelcomeBanner({this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile?.name ?? 'Usuario';
    final status = profile?.academicStatus.label ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: Text(
              profile?.initials ?? '?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Widget interno: tarjeta de menú
// ──────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon,
            size: 36, color: Theme.of(context).colorScheme.primary),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}