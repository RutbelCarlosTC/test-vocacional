import 'package:hive/hive.dart';

part 'evaluation_result.g.dart';

const int kMaxAttempts = 3;

// ──────────────────────────────────────────────
// Respuesta individual  (typeId: 0)
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
// Un intento completo de un área  (typeId: 1)
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

  /// Afinidad con mayor puntaje
  @HiveField(6)
  final String afinidadPrimaria;

  /// Segunda afinidad más alta
  @HiveField(7)
  final String afinidadSecundaria;

  /// Tercera afinidad más alta
  @HiveField(8)
  final String afinidadTerciaria;

  AreaAttempt({
    required this.attemptNumber,
    required this.date,
    required this.area,
    required this.answers,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.afinidadPrimaria,
    required this.afinidadSecundaria,
    required this.afinidadTerciaria,
  });

  double get percentage =>
      maxPossibleScore == 0 ? 0 : (totalScore / maxPossibleScore) * 100;

  String get scoreLabel {
    final p = percentage;
    if (p >= 80) return 'Afinidad muy alta';
    if (p >= 60) return 'Afinidad alta';
    if (p >= 40) return 'Afinidad media';
    return 'Afinidad baja';
  }
}

// ──────────────────────────────────────────────
// Contenedor por perfil+área  (typeId: 2)
// Guarda hasta kMaxAttempts intentos + borrador en curso
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