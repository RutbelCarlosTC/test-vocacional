import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';
import '../services/profile_manager.dart';
import '../widgets/attempt_detail/podium_widget.dart';
import '../widgets/attempt_detail/personality_radar_chart.dart';
import 'result_screen.dart';
import '../widgets/app_drawer.dart';

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
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen global superior
            Container(
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
                              Builder(builder: (context) {
                                final sortedScores = List<DimensionScore>.from(attempt.dimensionScores);
                                const order = [
                                  'Resiliencia y Manejo del Estrés',
                                  'Disciplina Académica',
                                  'Curiosidad Intelectual',
                                  'Liderazgo y Sociabilidad',
                                  'Aprendizaje Colaborativo',
                                ];
                                sortedScores.sort((a, b) {
                                  int idxA = order.indexOf(a.label);
                                  int idxB = order.indexOf(b.label);
                                  if (idxA == -1) idxA = 99;
                                  if (idxB == -1) idxB = 99;
                                  return idxA.compareTo(idxB);
                                });
                                return PersonalityRadarChart(scores: sortedScores);
                              }),
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
