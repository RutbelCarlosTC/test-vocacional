enum AcademicStatus {
  secundaria1a4,
  secundaria5,
  egresado,
}

extension AcademicStatusExtension on AcademicStatus {
  String get label {
    switch (this) {
      case AcademicStatus.secundaria1a4:
        return 'Secundaria (1° - 4°)';
      case AcademicStatus.secundaria5:
        return 'Secundaria (5°)';
      case AcademicStatus.egresado:
        return 'Egresado';
    }
  }

  String get value {
    switch (this) {
      case AcademicStatus.secundaria1a4:
        return 'secundaria_1_4';
      case AcademicStatus.secundaria5:
        return 'secundaria_5';
      case AcademicStatus.egresado:
        return 'egresado';
    }
  }

  static AcademicStatus fromValue(String value) {
    switch (value) {
      case 'secundaria_1_4':
        return AcademicStatus.secundaria1a4;
      case 'secundaria_5':
        return AcademicStatus.secundaria5;
      case 'egresado':
        return AcademicStatus.egresado;
      default:
        return AcademicStatus.egresado;
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

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.academicStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'academicStatus': academicStatus.value,
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