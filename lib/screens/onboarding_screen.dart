import 'package:flutter/material.dart';
import '../services/profile_manager.dart';
import 'profile_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: '¡Bienvenido a EnrutaT!',
      description: 'Tu brújula para descubrir tu camino profesional. Estamos aquí para ayudarte a tomar la mejor decisión para tu futuro.',
      image: 'assets/ENRUTAT_LOGO.png',
      icon: Icons.explore_outlined,
    ),
    OnboardingData(
      title: 'Preferencias Profesionales',
      description: 'Descubre qué áreas de estudio te apasionan. Este test evalúa tus intereses en diferentes campos del conocimiento.',
      image: 'assets/ENRUTAT_LOGO.png',
      icon: Icons.auto_stories_outlined,
    ),
    OnboardingData(
      title: 'Perfil de Personalidad',
      description: 'Conoce tus rasgos y fortalezas personales. Entender cómo eres te ayudará a encontrar la carrera que mejor se adapte a tu forma de ser.',
      image: 'assets/ENRUTAT_LOGO.png',
      icon: Icons.psychology_outlined,
    ),
  ];

  void _onNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await ProfileManager().setOnboardingShown();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _onNext,
                    child: Text(_currentPage == _pages.length - 1 ? 'Empezar' : 'Siguiente'),
                  ),
                  const SizedBox(height: 10),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () async {
                        await ProfileManager().setOnboardingShown();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
                        );
                      },
                      child: const Text('Omitir', style: TextStyle(color: Colors.grey)),
                    ),
                  if (_currentPage == _pages.length - 1)
                    const SizedBox(height: 48), // Espacio para mantener el botón en la misma posición
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}

class OnboardingContent extends StatelessWidget {
  final OnboardingData data;

  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            data.image,
            height: 180,
          ),
          const SizedBox(height: 40),
          Icon(
            data.icon,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
