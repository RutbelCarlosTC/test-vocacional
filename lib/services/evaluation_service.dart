import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';

class EvaluationService {
  static const String _boxName = 'area_progress_v4'; // Cambiado a v4 para evitar errores de casteo con datos viejos

  static final EvaluationService _instance = EvaluationService._internal();
  factory EvaluationService() => _instance;
  EvaluationService._internal();

  // ── Inicialización ──────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();
    // Registrar todos los adaptadores
    Hive.registerAdapter(AnswerRecordAdapter());
    Hive.registerAdapter(DimensionScoreAdapter()); // Falta este adaptador
    Hive.registerAdapter(AreaAttemptAdapter());
    Hive.registerAdapter(AreaProgressAdapter());

    await Hive.openBox<AreaProgress>(_boxName);
  }

  Box<AreaProgress> get _box => Hive.box<AreaProgress>(_boxName);

  // ── Carga de preguntas ──────────────────────────────────

  Future<List<QuestionModel>> loadQuestionsForArea(EvaluationArea area) async {
    try {
      final raw = await rootBundle.loadString(area.assetPath);
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => QuestionModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error cargando JSON para ${area.name}: $e');
      return [];
    }
  }

  // ── Acceso a AreaProgress ────────────────────────────────

  String _key(String profileId, EvaluationArea area) =>
      '${profileId}_${area.jsonKey}';

  AreaProgress getProgress(String profileId, EvaluationArea area) {
    return _box.get(_key(profileId, area)) ??
        AreaProgress(
          profileId: profileId,
          area: area.jsonKey,
          attempts: [],
          draftAnswers: [],
          draftLastIndex: 0,
        );
  }

  // ── Guardar borrador (progreso parcial) ──────────────────

  Future<void> saveDraft({
    required String profileId,
    required EvaluationArea area,
    required List<AnswerRecord> answers,
    required int lastIndex,
  }) async {
    final progress = getProgress(profileId, area);
    final updated = progress.copyWith(
      draftAnswers: answers,
      draftLastIndex: lastIndex,
    );
    await _box.put(_key(profileId, area), updated);
  }

  // ── Finalizar intento ────────────────────────────────────

  Future<AreaAttempt?> finalizeAttempt({
    required String profileId,
    required EvaluationArea area,
    required List<AnswerRecord> answers,
    required List<QuestionModel> questions,
  }) async {
    final progress = getProgress(profileId, area);
    if (!progress.canStartNewAttempt) return null;

    final scoringType = area.scoringType;
    bool isValid = true;

    // --- PROTOCOLO DE VALIDACIÓN (PERSONALIDAD) ---
    if (area == EvaluationArea.personalidad) {
      try {
        // Buscamos la respuesta a la pregunta con ID 16
        final item16 = answers.firstWhere((a) => a.questionId == 16);
        // Según el protocolo: Válida si el valor es 2 (En desacuerdo)
        if (item16.value != 2) {
          isValid = false;
        }
      } catch (e) {
        // Si no se encuentra el ítem 16 (ej. test incompleto), invalidamos por seguridad
        isValid = false;
      }
    }

    final totalScore = answers.fold(0, (sum, a) => sum + a.value);
    final maxScore = _calcMaxScore(questions);

    List<DimensionScore> dimensionScores = [];
    String? p1, p2, p3;

    if (scoringType == 'dimensions') {
      if (area == EvaluationArea.personalidad) {
        dimensionScores = _calcDimensionScoresPersonalidad(answers, questions);
      } else {
        dimensionScores = _calcDimensionScores(answers, questions);
      }
    } else if (scoringType == 'preferencias_triadas') {
      final results = _calcPreferenciasTriadas(answers, questions);
      dimensionScores = results.macroScores;
      p1 = results.topCareers[0];
      p2 = results.topCareers[1];
      p3 = results.topCareers[2];
    } else {
      final afinidades = _calcAfinidades(area, totalScore, maxScore);
      p1 = afinidades[0];
      p2 = afinidades[1];
      p3 = afinidades[2];
    }

    final attempt = AreaAttempt(
      attemptNumber: progress.attempts.length + 1,
      date: DateTime.now(),
      area: area.jsonKey,
      answers: List.from(answers),
      totalScore: totalScore,
      maxPossibleScore: maxScore,
      afinidadPrimaria: p1,
      afinidadSecundaria: p2,
      afinidadTerciaria: p3,
      dimensionScores: dimensionScores,
      scoringType: scoringType,
      isValid: isValid,
    );

    final updated = progress.copyWith(
      attempts: [...progress.attempts, attempt],
      draftAnswers: [],
      draftLastIndex: 0,
    );
    await _box.put(_key(profileId, area), updated);
    return attempt;
  }

  /// Cálculo específico para Personalidad: 5 dimensiones, 3 ítems cada una.
  /// Rango 3-15 puntos.
  List<DimensionScore> _calcDimensionScoresPersonalidad(
      List<AnswerRecord> answers, List<QuestionModel> questions) {
    final Map<String, int> scoresByDim = {};

    // Solo procesamos ítems del 1 al 15 (las 5 dimensiones de 3 ítems cada una)
    for (var q in questions) {
      if (q.id > 15) continue; // Ignorar ítem de control 16 o adicionales

      final dim = q.dimension ?? 'General';
      final ans = answers.firstWhere(
        (a) => a.questionId == q.id,
        orElse: () => AnswerRecord(
          questionId: q.id,
          questionText: q.question,
          selectedOption: 'N/A',
          value: 0,
        ),
      );

      scoresByDim[dim] = (scoresByDim[dim] ?? 0) + ans.value;
    }

    return scoresByDim.entries.map((e) {
      final dimKey = e.key;
      final score = e.value;
      
      // Baremos: 3-6 Bajo, 7-11 Medio, 12-15 Alto
      String level = 'Medio';
      if (score <= 6) level = 'Bajo';
      if (score >= 12) level = 'Alto';

      return DimensionScore(
        key: dimKey.toLowerCase().replaceAll(' ', '_'),
        label: dimKey,
        score: score,
        maxScore: 15, // Cada dimensión tiene 3 preguntas de máx 5 pts.
        level: level,
      );
    }).toList();
  }

  List<DimensionScore> _calcDimensionScores(
      List<AnswerRecord> answers, List<QuestionModel> questions) {
    final Map<String, List<int>> scoresByDim = {};
    final Map<String, List<int>> maxByDim = {};

    for (var q in questions) {
      final dim = q.dimension ?? 'General';
      final ans = answers.firstWhere((a) => a.questionId == q.id,
          orElse: () => AnswerRecord(
              questionId: q.id,
              questionText: q.question,
              selectedOption: 'N/A',
              value: 0));

      final maxVal =
          q.options.map((o) => o.value).reduce((a, b) => a > b ? a : b);

      scoresByDim.putIfAbsent(dim, () => []).add(ans.value);
      maxByDim.putIfAbsent(dim, () => []).add(maxVal);
    }

    return scoresByDim.entries.map((e) {
      final dimKey = e.key;
      final total = e.value.fold(0, (a, b) => a + b);
      final max = maxByDim[dimKey]!.fold(0, (a, b) => a + b);
      final pct = max == 0 ? 0 : total / max;

      String level = 'Medio';
      if (pct < 0.33) level = 'Bajo';
      if (pct > 0.66) level = 'Alto';

      return DimensionScore(
        key: dimKey,
        label: dimKey,
        score: total,
        maxScore: max,
        level: level,
      );
    }).toList();
  }

  _PreferenciasResult _calcPreferenciasTriadas(
      List<AnswerRecord> answers, List<QuestionModel> questions) {
    final Map<String, int> macroScores = {'FIS': 0, 'BIO': 0, 'SOC': 0};
    final Map<String, int> careerScores = {};

    for (var ans in answers) {
      final question = questions.firstWhere((q) => q.id == ans.questionId);
      final option =
          question.options.firstWhere((o) => o.text == ans.selectedOption);

      if (option.macroArea != null) {
        macroScores[option.macroArea!] =
            (macroScores[option.macroArea!] ?? 0) + 1;
      }
      if (option.careerTag != null) {
        careerScores[option.careerTag!] =
            (careerScores[option.careerTag!] ?? 0) + 1;
      }
    }

    // Convertir macroScores a DimensionScore
    final List<DimensionScore> dimensionScores = macroScores.entries.map((e) {
      final score = e.value;
      String level = 'Bajo';
      if (score >= 20)
        level = 'Muy Alto';
      else if (score >= 14)
        level = 'Alto';
      else if (score >= 7) level = 'Medio';

      String label = e.key;
      if (e.key == 'FIS') label = 'Ciencias Físicas e Ingenierías';
      if (e.key == 'BIO') label = 'Ciencias Biológicas y de la Salud';
      if (e.key == 'SOC') label = 'Ciencias Sociales y Humanidades';

      return DimensionScore(
        key: e.key,
        label: label,
        score: score,
        maxScore: 30,
        level: level,
      );
    }).toList();

    // Obtener Top 3 carreras
    final sortedCareers = careerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = sortedCareers.take(3).map((e) => e.key).toList();
    while (top3.length < 3) {
      top3.add('N/A');
    }

    return _PreferenciasResult(dimensionScores, top3);
  }

  // ── Helpers ──────────────────────────────────────────────

  int _calcMaxScore(List<QuestionModel> questions) {
    return questions.fold(0, (sum, q) {
      final max =
          q.options.map((o) => o.value).reduce((a, b) => a > b ? a : b);
      return sum + max;
    });
  }

  /// Devuelve lista de 3 afinidades ordenadas de mayor a menor.
  /// La lógica asigna carreras según porcentaje y área.
  List<String> _calcAfinidades(EvaluationArea area, int score, int maxScore) {
    final pct = maxScore == 0 ? 0.0 : score / maxScore * 100;

    final Map<EvaluationArea, List<String>> tabla = {
      EvaluationArea.preferencias: [
        'Ingeniería de Sistemas / Ciencias',
        'Administración / Economía',
        'Humanidades / Educación',
        'Arte / Diseño',
      ],
      EvaluationArea.personalidad: [
        'Liderazgo / Gestión Empresarial',
        'Docencia / Psicología',
        'Investigación / Ciencias',
        'Servicio Social / Voluntariado',
      ],
    };

    final opciones = tabla[area]!;

    // El índice de la primaria depende del rango de puntaje.
    int primaryIdx;
    if (pct >= 80) {
      primaryIdx = 0;
    } else if (pct >= 60) {
      primaryIdx = 1;
    } else if (pct >= 40) {
      primaryIdx = 2;
    } else {
      primaryIdx = 3;
    }

    // Secundaria y terciaria: siguientes en la lista (rotando)
    final secondaryIdx = (primaryIdx + 1) % opciones.length;
    final tertiaryIdx = (primaryIdx + 2) % opciones.length;

    return [opciones[primaryIdx], opciones[secondaryIdx], opciones[tertiaryIdx]];
  }
}

class _PreferenciasResult {
  final List<DimensionScore> macroScores;
  final List<String> topCareers;
  _PreferenciasResult(this.macroScores, this.topCareers);
}
