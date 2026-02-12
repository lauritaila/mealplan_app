import '../domain.dart';

abstract class PreferencesRepository {
  Future<PreferencesConfiguration> fetchPreferencesConfiguration();
  Future<UserPreferences?> fetchUserPreference(String userId);
  Future<void> saveUserPreference(
    UserPreferences userPreference,
    String userId,
  );
}

