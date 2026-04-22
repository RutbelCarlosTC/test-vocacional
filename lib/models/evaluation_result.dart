import 'package:hive/hive.dart';

part 'evaluation_result.g.dart';

// ──────────────────────────────────────────────
// Respuesta individual
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
// Resultado de un área completa
// ──────────────────────────────────────────────
@HiveType(typeId: 1)
class AreaResult extends HiveObject {
  @HiveField(0)
  final String area;

  @HiveField(1)
  final List<AnswerRecord> answers;

  @HiveField(2)
  final int totalScore;

  @HiveField(3)
  final int maxPossibleScore;

  @HiveField(4)
  final bool completed;

  AreaResult({
    required this.area,
    required this.answers,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.completed,
  });

  double get percentage =>
      maxPossibleScore == 0 ? 0 : (totalScore / maxPossibleScore) * 100;
}

// ──────────────────────────────────────────────
// Resultado completo de una evaluación
// ──────────────────────────────────────────────
@HiveType(typeId: 2)
class EvaluationResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String profileId;

  @HiveField(2)
  final String area;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final List<AnswerRecord> answers;

  @HiveField(5)
  final int totalScore;

  @HiveField(6)
  final int maxPossibleScore;

  @HiveField(7)
  final bool completed;

  // Respuestas guardadas hasta el momento (progreso parcial)
  @HiveField(8)
  final int lastAnsweredIndex;

  EvaluationResult({
    required this.id,
    required this.profileId,
    required this.area,
    required this.date,
    required this.answers,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.completed,
    required this.lastAnsweredIndex,
  });

  double get percentage =>
      maxPossibleScore == 0 ? 0 : (totalScore / maxPossibleScore) * 100;

  double get progressPercent => completed ? 1.0 : 0.0;

  // Copia con cambios
  EvaluationResult copyWith({
    List<AnswerRecord>? answers,
    int? totalScore,
    int? maxPossibleScore,
    bool? completed,
    int? lastAnsweredIndex,
  }) {
    return EvaluationResult(
      id: id,
      profileId: profileId,
      area: area,
      date: date,
      answers: answers ?? this.answers,
      totalScore: totalScore ?? this.totalScore,
      maxPossibleScore: maxPossibleScore ?? this.maxPossibleScore,
      completed: completed ?? this.completed,
      lastAnsweredIndex: lastAnsweredIndex ?? this.lastAnsweredIndex,
    );
  }
}
