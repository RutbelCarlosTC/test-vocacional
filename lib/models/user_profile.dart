enum AcademicStatus {
  secundaria1a4,
  secundaria5,
  secundariaCompleta,
}

extension AcademicStatusExtension on AcademicStatus {
  String get label {
    switch (this) {
      case AcademicStatus.secundaria1a4:
        return 'Secundaria (1° - 4°)';
      case AcademicStatus.secundaria5:
        return 'Secundaria (5°)';
    case AcademicStatus.secundariaCompleta:
        return 'Secundaria Completa';
    }
  }

  String get value {
    switch (this) {
      case AcademicStatus.secundaria1a4:
        return 'secundaria_1_4';
      case AcademicStatus.secundaria5:
        return 'secundaria_5';
      case AcademicStatus.secundariaCompleta:
        return 'secundaria_completa';
    }
  }

  static AcademicStatus fromValue(String value) {
    switch (value) {
      case 'secundaria_1_4':
        return AcademicStatus.secundaria1a4;
      case 'secundaria_5':
        return AcademicStatus.secundaria5;
      case 'secundaria_completa':
        return AcademicStatus.secundariaCompleta;
      default:
        return AcademicStatus.secundariaCompleta;
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String gender;
  final DateTime birthDate;
  final AcademicStatus academicStatus;
  final String schoolType; // Nacional, Parroquial, Particular
  final List<String> possibleCareers; // 3 opciones
  final bool tourHomeShown;
  final bool tourAreasShown;
  final bool tourQuizShown;
  final bool tourResultsShown;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.academicStatus,
    required this.schoolType,
    required this.possibleCareers,
    this.tourHomeShown = false,
    this.tourAreasShown = false,
    this.tourQuizShown = false,
    this.tourResultsShown = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'academicStatus': academicStatus.value,
      'schoolType': schoolType,
      'possibleCareers': possibleCareers,
      'tourHomeShown': tourHomeShown,
      'tourAreasShown': tourAreasShown,
      'tourQuizShown': tourQuizShown,
      'tourResultsShown': tourResultsShown,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      gender: map['gender'],
      birthDate: DateTime.parse(map['birthDate']),
      academicStatus: AcademicStatusExtension.fromValue(map['academicStatus']),
      schoolType: map['schoolType'] ?? 'Nacional',
      possibleCareers: List<String>.from(map['possibleCareers'] ?? []),
      tourHomeShown: map['tourHomeShown'] ?? map['tourShown'] ?? false,
      tourAreasShown: map['tourAreasShown'] ?? map['tourShown'] ?? false,
      tourQuizShown: map['tourQuizShown'] ?? map['tourShown'] ?? false,
      tourResultsShown: map['tourResultsShown'] ?? map['tourShown'] ?? false,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    DateTime? birthDate,
    AcademicStatus? academicStatus,
    String? schoolType,
    List<String>? possibleCareers,
    bool? tourHomeShown,
    bool? tourAreasShown,
    bool? tourQuizShown,
    bool? tourResultsShown,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      academicStatus: academicStatus ?? this.academicStatus,
      schoolType: schoolType ?? this.schoolType,
      possibleCareers: possibleCareers ?? this.possibleCareers,
      tourHomeShown: tourHomeShown ?? this.tourHomeShown,
      tourAreasShown: tourAreasShown ?? this.tourAreasShown,
      tourQuizShown: tourQuizShown ?? this.tourQuizShown,
      tourResultsShown: tourResultsShown ?? this.tourResultsShown,
    );
  }

  int get age {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}