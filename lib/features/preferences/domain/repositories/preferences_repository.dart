import '../domain.dart';

abstract class PreferencesRepository {
  Future<PreferencesConfiguration> fetchPreferencesConfiguration();
  Future<UserPreferences?> fetchUserPreference();
  Future<void> saveUserPreference(UserPreferences userPreference);
}
