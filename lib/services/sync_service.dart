import 'dart:io';
import 'evaluation_service.dart';
import 'firebase_service.dart';
import 'profile_manager.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final EvaluationService _evalService = EvaluationService();
  final FirebaseService _firebaseService = FirebaseService();
  final ProfileManager _profileManager = ProfileManager();

  /// Verifica si hay conexión a internet
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Sincroniza todos los intentos no sincronizados
  Future<void> syncUnsyncedResults() async {
    if (!await hasInternet()) return;

    final allProgress = _evalService.getAllProgress();
    final profiles = await _profileManager.getProfiles();

    for (var progress in allProgress) {
      UserProfile? profile;
      try {
        profile = profiles.firstWhere((p) => p.id == progress.profileId);
      } catch (_) {
        profile = null;
      }

      if (profile == null) continue;

      for (var attempt in progress.attempts) {
        if (!attempt.isSynced) {
          final success = await _firebaseService.uploadEvaluationResult(
            profile: profile,
            attempt: attempt,
          );

          if (success) {
            await _evalService.markAttemptAsSynced(
              progress.profileId,
              progress.area,
              attempt.attemptNumber,
            );
          }
        }
      }
    }
  }
}
