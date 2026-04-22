class OptionModel {
  final String text;
  final int value;

  OptionModel({required this.text, required this.value});

  factory OptionModel.fromMap(Map<String, dynamic> map) {
    return OptionModel(
      text: map['text'] as String,
      value: map['value'] as int,
    );
  }
}

class QuestionModel {
  final int id;
  final String area;
  final String question;
  final List<OptionModel> options;

  QuestionModel({
    required this.id,
    required this.area,
    required this.question,
    required this.options,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int,
      area: map['area'] as String,
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
  aptitudes,
  personalidad,
}

extension EvaluationAreaExtension on EvaluationArea {
  String get label {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'Preferencias Profesionales';
      case EvaluationArea.aptitudes:
        return 'Aptitudes Intelectuales';
      case EvaluationArea.personalidad:
        return 'Características de la Personalidad';
    }
  }

  String get jsonKey {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'Preferencias Profesionales';
      case EvaluationArea.aptitudes:
        return 'Aptitudes Intelectuales';
      case EvaluationArea.personalidad:
        return 'Características de la Personalidad';
    }
  }

  String get description {
    switch (this) {
      case EvaluationArea.preferencias:
        return 'Evalúa tu grado de interés hacia distintas áreas de estudio.';
      case EvaluationArea.aptitudes:
        return 'Evalúa tus aptitudes e inteligencia general.';
      case EvaluationArea.personalidad:
        return 'Evalúa tus rasgos de personalidad: logro, liderazgo y más.';
    }
  }
}
