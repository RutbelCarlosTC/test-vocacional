import 'package:hive/hive.dart';

part 'evaluation_result.g.dart';

const int kMaxAttempts = 2;

// ──────────────────────────────────────────────
// Respuesta individual  (typeId: 0)
// Sin cambios — sigue funcionando igual.
// ──────────────────────────────────────────────
@HiveType(typeId: 0)
class AnswerRecord extends HiveObject {
  @HiveField(0)
  final int questionId;

  @HiveField(1)
  final String questionText;

  @HiveField(2)
  final String selectedOption;

  @HiveField(3)
  final int value;

  AnswerRecord({
    required this.questionId,
    required this.questionText,
    required this.selectedOption,
    required this.value,
  });
}

// ──────────────────────────────────────────────
// Resultado de una dimensión individual (typeId: 3)
//
// Usado cuando scoringType == ScoringType.dimensions.
// Ej: Disciplina Académica → score: 11, maxScore: 15, level: "Medio"
// ──────────────────────────────────────────────
@HiveType(typeId: 3)
class DimensionScore extends HiveObject {
  /// Clave interna de la dimensión (coincide con DimensionDefinition.key)
  @HiveField(0)
  final String key;

  /// Etiqueta legible: "Disciplina Académica", "Resiliencia…", etc.
  @HiveField(1)
  final String label;

  /// Suma de los ítems de esta dimensión
  @HiveField(2)
  final int score;

  /// Puntaje máximo posible (ítems × valor máximo por ítem)
  @HiveField(3)
  final int maxScore;

  /// "Bajo", "Medio" o "Alto"
  @HiveField(4)
  final String level;

  DimensionScore({
    required this.key,
    required this.label,
    required this.score,
    required this.maxScore,
    required this.level,
  });

  double get percentage => maxScore == 0 ? 0 : score / maxScore * 100;
}

// ──────────────────────────────────────────────
// Un intento completo de un área  (typeId: 1)
//
// Ahora soporta dos modos de scoring:
//
//  Modo affinity (original):
//    dimensionScores = []
//    afinidadPrimaria / afinidadSecundaria / afinidadTerciaria tienen valor
//
//  Modo dimensions (IEAT-15 y similares):
//    dimensionScores = [ DimensionScore × N ]
//    afinidad* = null
//    isValid indica si el ítem de control fue respondido correctamente
// ──────────────────────────────────────────────
@HiveType(typeId: 1)
class AreaAttempt extends HiveObject {
  @HiveField(0)
  final int attemptNumber;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String area;

  @HiveField(3)
  final List<AnswerRecord> answers;

  @HiveField(4)
  final int totalScore;

  @HiveField(5)
  final int maxPossibleScore;

  // ── Campos modo affinity (nullable para modo dimensions) ──

  @HiveField(6)
  final String? afinidadPrimaria;

  @HiveField(7)
  final String? afinidadSecundaria;

  @HiveField(8)
  final String? afinidadTerciaria;

  // ── Campos modo dimensions ──

  /// Resultados por dimensión. Vacío en modo affinity.
  @HiveField(9)
  final List<DimensionScore> dimensionScores;

  /// true = prueba válida (ítem de control correcto o sin ítem de control).
  /// false = prueba invalidada por ítem de control incorrecto.
  @HiveField(10)
  final bool isValid;

  /// Identificador del tipo de scoring usado.
  /// "affinity" | "dimensions"
  @HiveField(11)
  final String scoringType;

  AreaAttempt({
    required this.attemptNumber,
    required this.date,
    required this.area,
    required this.answers,
    required this.totalScore,
    required this.maxPossibleScore,
    this.afinidadPrimaria,
    this.afinidadSecundaria,
    this.afinidadTerciaria,
    this.dimensionScores = const [],
    this.isValid = true,
    this.scoringType = 'affinity',
  });

  double get percentage =>
      maxPossibleScore == 0 ? 0 : (totalScore / maxPossibleScore) * 100;

  /// Solo relevante en modo affinity.
  String get scoreLabel {
    final p = percentage;
    if (p >= 80) return 'Afinidad muy alta';
    if (p >= 60) return 'Afinidad alta';
    if (p >= 40) return 'Afinidad media';
    return 'Afinidad baja';
  }

  /// ¿Tiene resultados por dimensión?
  bool get hasDimensions => dimensionScores.isNotEmpty;

  /// Devuelve el DimensionScore de una clave concreta (o null si no existe).
  DimensionScore? dimensionFor(String key) {
    try {
      return dimensionScores.firstWhere((d) => d.key == key);
    } catch (_) {
      return null;
    }
  }
}

// ──────────────────────────────────────────────
// Contenedor por perfil+área  (typeId: 2)
// Guarda hasta kMaxAttempts intentos + borrador en curso.
// Sin cambios estructurales — AreaAttempt ya es flexible.
// ──────────────────────────────────────────────
@HiveType(typeId: 2)
class AreaProgress extends HiveObject {
  @HiveField(0)
  final String profileId;

  @HiveField(1)
  final String area;

  @HiveField(2)
  final List<AreaAttempt> attempts;

  @HiveField(3)
  final List<AnswerRecord> draftAnswers;

  @HiveField(4)
  final int draftLastIndex;

  int? totalQuestions;

  AreaProgress({
    required this.profileId,
    required this.area,
    required this.attempts,
    required this.draftAnswers,
    required this.draftLastIndex,
  });

  bool get hasCompletedAttempts => attempts.isNotEmpty;
  bool get canStartNewAttempt => attempts.length < kMaxAttempts;
  int get attemptsLeft => kMaxAttempts - attempts.length;
  bool get hasDraft => draftAnswers.isNotEmpty;
  AreaAttempt? get latestAttempt =>
      attempts.isEmpty ? null : attempts.last;

  AreaProgress copyWith({
    List<AreaAttempt>? attempts,
    List<AnswerRecord>? draftAnswers,
    int? draftLastIndex,
  }) {
    return AreaProgress(
      profileId: profileId,
      area: area,
      attempts: attempts ?? this.attempts,
      draftAnswers: draftAnswers ?? this.draftAnswers,
      draftLastIndex: draftLastIndex ?? this.draftLastIndex,
    );
  }
}