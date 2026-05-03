class OptionModel {
  final String text;
  final int value;
  final String? macroArea; // FIS, BIO, SOC
  final String? careerTag; // Ingeniería Civil, Medicina, etc.

  OptionModel({
    required this.text,
    required this.value,
    this.macroArea,
    this.careerTag,
  });

  factory OptionModel.fromMap(Map<String, dynamic> map) {
    return OptionModel(
      text: map['text'] as String,
      value: map['value'] as int,
      macroArea: map['macroArea'] as String?,
      careerTag: map['careerTag'] as String?,
    );
  }
}

class QuestionModel {
  final int id;
  final String area;
  final String? dimension; // Nueva propiedad opcional
  final String question;
  final List<OptionModel> options;

  QuestionModel({
    required this.id,
    required this.area,
    this.dimension,
    required this.question,
    required this.options,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int,
      area: map['area'] as String,
      dimension: map['dimension'] as String?,
      question: map['question'] as String,
      options: (map['options'] as List)
          .map((o) => OptionModel.fromMap(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Las 3 áreas del test
enum EvaluationArea {
  preferencias,
  personalidad,
}

extension EvaluationAreaExtension on EvaluationArea {
  String get label {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'Preferencias Profesionales';
      case EvaluationArea.personalidad:
        return 'Características de la Personalidad';
    }
  }

  String get jsonKey {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'Preferencias Profesionales';
      case EvaluationArea.personalidad:
        return 'Características de la Personalidad';
    }
  }

  String get assetPath {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'assets/data/preferencias.json';
      case EvaluationArea.personalidad:
        return 'assets/data/personalidad.json';
    }
  }

  String get scoringType {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'preferencias_triadas';
      case EvaluationArea.personalidad:
        return 'dimensions';
      default:
        return 'affinity';
    }
  }

  String get description {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'Evalúa tu grado de interés hacia distintas áreas de estudio.';
      case EvaluationArea.personalidad:
        return 'Evalúa tus rasgos de personalidad: logro, liderazgo y más.';
    }
  }
}
