import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../models/user_profile.dart';
import '../services/evaluation_service.dart';
import '../services/profile_manager.dart';
import '../services/tour_service.dart';
import '../widgets/attempt_detail/podium_widget.dart';
import '../widgets/attempt_detail/personality_radar_chart.dart';
import 'result_screen.dart';

class GlobalResultsScreen extends StatefulWidget {
  const GlobalResultsScreen({super.key});

  @override
  State<GlobalResultsScreen> createState() => _GlobalResultsScreenState();
}

class _GlobalResultsScreenState extends State<GlobalResultsScreen> {
  final EvaluationService _evalService = EvaluationService();
  final ProfileManager _profileManager = ProfileManager();

  bool _loading = true;
  String? _profileId;
  
  // Keys para el tour
  final GlobalKey _summaryKey = GlobalKey();

  // Guardamos el progreso de todas las áreas
  final Map<EvaluationArea, AreaProgress> _progressMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await _profileManager.getActiveProfile();
    if (profile == null) return;

    final Map<EvaluationArea, AreaProgress> map = {};
    for (final area in EvaluationArea.values) {
      map[area] = _evalService.getProgress(profile.id, area);
    }

    setState(() {
      _profileId = profile.id;
      _progressMap.addAll(map);
      _loading = false;
    });

    if (!profile.tourResultsShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTour(profile));
    }
  }

  void _startTour(UserProfile profile) {
    TourService.showTour(
      context,
      targets: [
        TourService.createTarget(
          key: _summaryKey,
          title: 'Resumen Global',
          description: 'Aquí verás un resumen de cuánto has avanzado en total.',
        ),
      ],
      onFinish: () => _markTourAsShown(profile),
      onSkip: () => _markTourAsShown(profile),
    );
  }

  Future<void> _markTourAsShown(UserProfile profile) async {
    final updated = profile.copyWith(tourResultsShown: true);
    await _profileManager.saveProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Calculamos cuántas áreas ya tienen al menos un intento completado
    final int areasCompletadas = _progressMap.values
        .where((p) => p.hasCompletedAttempts)
        .length;
    final int totalAreas = EvaluationArea.values.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Generales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen global superior
            Container(
              key: _summaryKey,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.pie_chart, color: Theme.of(context).colorScheme.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Has completado $areasCompletadas de $totalAreas áreas de evaluación.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Resumen por área (Último intento)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: EvaluationArea.values.map((area) {
                  final progress = _progressMap[area]!;
                  final attempt = progress.latestAttempt;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        // Al hacer clic, enviamos al usuario al historial detallado de esa área
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultScreen(
                              area: area,
                              profileId: _profileId!,
                            ),
                          ),
                        ).then((_) {
                          // Recargar los datos al regresar por si acaso hizo un nuevo intento
                          setState(() => _loading = true);
                          _loadData();
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  area.label,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (attempt == null)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text('Aún no evaluado', style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            else if (area == EvaluationArea.preferencias)
                              PodiumWidget(
                                attempt: attempt,
                                onCareerTap: (career) {
                                  // Opcionalmente podemos navegar al detalle o no hacer nada 
                                  // ya que el Card entero navega al historial.
                                },
                              )
                            else if (area == EvaluationArea.personalidad)
                              PersonalityRadarChart(scores: attempt.dimensionScores),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}