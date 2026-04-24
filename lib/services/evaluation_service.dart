import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';

class EvaluationService {
  static const String _boxName = 'area_progress_v3';

  static final EvaluationService _instance = EvaluationService._internal();
  factory EvaluationService() => _instance;
  EvaluationService._internal();

  List<QuestionModel>? _allQuestions;

  // ── Inicialización ──────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AnswerRecordAdapter());
    Hive.registerAdapter(AreaAttemptAdapter());
    Hive.registerAdapter(AreaProgressAdapter());
    await Hive.openBox<AreaProgress>(_boxName);
  }

  Box<AreaProgress> get _box => Hive.box<AreaProgress>(_boxName);

  // ── Carga de preguntas ──────────────────────────────────

  Future<List<QuestionModel>> loadAllQuestions() async {
    if (_allQuestions != null) return _allQuestions!;
    final raw = await rootBundle.loadString('assets/questions.json');
    final list = jsonDecode(raw) as List;
    _allQuestions = list
        .map((e) => QuestionModel.fromMap(e as Map<String, dynamic>))
        .toList();
    return _allQuestions!;
  }

  Future<List<QuestionModel>> loadQuestionsForArea(EvaluationArea area) async {
    final all = await loadAllQuestions();
    return all.where((q) => q.area == area.jsonKey).toList();
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

    final totalScore = answers.fold(0, (sum, a) => sum + a.value);
    final maxScore = _calcMaxScore(questions);

    final afinidades = _calcAfinidades(area, totalScore, maxScore);

    final attempt = AreaAttempt(
      attemptNumber: progress.attempts.length + 1,
      date: DateTime.now(),
      area: area.jsonKey,
      answers: List.from(answers),
      totalScore: totalScore,
      maxPossibleScore: maxScore,
      afinidadPrimaria: afinidades[0],
      afinidadSecundaria: afinidades[1],
      afinidadTerciaria: afinidades[2],
    );

    final updated = progress.copyWith(
      attempts: [...progress.attempts, attempt],
      draftAnswers: [],
      draftLastIndex: 0,
    );
    await _box.put(_key(profileId, area), updated);
    return attempt;
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
      EvaluationArea.aptitudes: [
        'Matemáticas / Física / Ingeniería',
        'Ciencias Sociales / Derecho',
        'Arte / Comunicaciones',
        'Técnico / Oficios especializados',
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