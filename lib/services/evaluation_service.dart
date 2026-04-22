import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';

class EvaluationService {
  static const String _boxName = 'evaluations';

  // Singleton
  static final EvaluationService _instance = EvaluationService._internal();
  factory EvaluationService() => _instance;
  EvaluationService._internal();

  // Cache de preguntas
  List<QuestionModel>? _allQuestions;

  // ──────────────────────────────────────────────
  // Inicialización de Hive
  // ──────────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AnswerRecordAdapter());
    Hive.registerAdapter(AreaResultAdapter());
    Hive.registerAdapter(EvaluationResultAdapter());
    await Hive.openBox<EvaluationResult>(_boxName);
  }

  Box<EvaluationResult> get _box => Hive.box<EvaluationResult>(_boxName);

  // ──────────────────────────────────────────────
  // Carga de preguntas desde JSON
  // ──────────────────────────────────────────────

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

  // ──────────────────────────────────────────────
  // Gestión de evaluaciones en Hive
  // ──────────────────────────────────────────────

  /// Clave única: profileId + area
  String _key(String profileId, String area) => '${profileId}_$area';

  /// Obtiene el resultado (completo o parcial) de un área para un perfil
  EvaluationResult? getResult(String profileId, EvaluationArea area) {
    return _box.get(_key(profileId, area.jsonKey));
  }

  /// Verifica si un área ya fue completada
  bool isAreaCompleted(String profileId, EvaluationArea area) {
    return getResult(profileId, area)?.completed ?? false;
  }

  /// Guarda o actualiza el progreso de una evaluación
  Future<void> saveProgress({
    required String profileId,
    required EvaluationArea area,
    required List<AnswerRecord> answers,
    required int totalScore,
    required int maxPossibleScore,
    required bool completed,
    required int lastAnsweredIndex,
  }) async {
    final key = _key(profileId, area.jsonKey);
    final existing = _box.get(key);

    final result = EvaluationResult(
      id: existing?.id ?? _generateId(),
      profileId: profileId,
      area: area.jsonKey,
      date: DateTime.now(),
      answers: answers,
      totalScore: totalScore,
      maxPossibleScore: maxPossibleScore,
      completed: completed,
      lastAnsweredIndex: lastAnsweredIndex,
    );

    await _box.put(key, result);
  }

  /// Devuelve todos los resultados de un perfil
  List<EvaluationResult> getResultsForProfile(String profileId) {
    return _box.values
        .where((r) => r.profileId == profileId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}
