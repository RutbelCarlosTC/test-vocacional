import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/evaluation_result.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sube el resultado de un test a Firebase Firestore
  /// Retorna true si se subió exitosamente, false en caso contrario
  Future<bool> uploadEvaluationResult({
    required UserProfile profile,
    required AreaAttempt attempt,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'fechaTest': Timestamp.fromDate(attempt.date),
        'nombreCompleto': profile.name,
        'correoPersonal': profile.email,
        'posiblesCarreras': profile.possibleCareers,
        'genero': profile.gender,
        'fechaNacimiento': Timestamp.fromDate(profile.birthDate),
        'tipoColegio': profile.schoolType,
        'status': profile.academicStatus.label,
        'areaEvaluada': attempt.area,
        'numeroIntento': attempt.attemptNumber,
        'userId': profile.id, // Añadimos userId para facilitar seguimiento
      };

      // Si es el test de preferencias profesionales
      if (attempt.scoringType == 'preferencias_triadas') {
        data['resultados'] = {
          'afinidadPrimaria': attempt.afinidadPrimaria,
          'afinidadSecundaria': attempt.afinidadSecundaria,
          'afinidadTerciaria': attempt.afinidadTerciaria,
        };
      } 
      // Si es el test de personalidad (dimensiones)
      else if (attempt.scoringType == 'dimensions') {
        data['resultados'] = attempt.dimensionScores.map((d) => {
          'dimension': d.label,
          'puntaje': d.score,
          'nivel': d.level, // Alto, Medio o Bajo
        }).toList();
      }

      // Guardar en la colección 'evaluaciones'
      // Se usa un documento con ID automático, o podrías usar profileId_area_intento
      await _firestore.collection('evaluaciones').add(data);
      
      print('Resultado subido exitosamente a Firebase');
      return true;
    } catch (e) {
      print('Error al subir a Firebase: $e');
      return false;
      // No lanzamos error para no interrumpir el flujo del usuario si falla el internet
      // pero podrías manejarlo según tu necesidad.
    }
  }
}
