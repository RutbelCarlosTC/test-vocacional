import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileManager {
  static const String _profilesKey = 'profiles';
  static const String _activeProfileKey = 'active_profile_id';
  static const String _onboardingKey = 'onboarding_shown';

  // Singleton
  static final ProfileManager _instance = ProfileManager._internal();
  factory ProfileManager() => _instance;
  ProfileManager._internal();

  // ---------- Onboarding ----------

  Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_onboardingKey) ?? false);
  }

  Future<void> setOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // ---------- Perfiles ----------

  Future<List<UserProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey) ?? [];
    return raw
        .map((e) => UserProfile.fromMap(jsonDecode(e)))
        .toList();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();

    // Reemplazar si ya existe, agregar si no
    final idx = profiles.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      profiles[idx] = profile;
    } else {
      profiles.add(profile);
    }

    final raw = profiles.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList(_profilesKey, raw);
  }

  Future<void> deleteProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == profileId);
    final raw = profiles.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList(_profilesKey, raw);

    // Si era el activo, limpiar sesión
    final activeId = await getActiveProfileId();
    if (activeId == profileId) {
      await clearSession();
    }
  }

  // ---------- Sesión ----------

  Future<void> setActiveProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profileId);
  }

  Future<String?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey);
  }

  Future<UserProfile?> getActiveProfile() async {
    final activeId = await getActiveProfileId();
    if (activeId == null) return null;
    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((p) => p.id == activeId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasActiveSession() async {
    final profile = await getActiveProfile();
    return profile != null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeProfileKey);
  }

  // ---------- Utilidades ----------

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}