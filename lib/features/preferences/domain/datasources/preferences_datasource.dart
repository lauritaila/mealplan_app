import '../domain.dart';

abstract class PreferencesDatasource {
  Future<PreferencesConfiguration> fetchPreferencesConfiguration();
  Future<UserPreferences?> fetchUserPreference();
  Future<void> saveUserPreference(UserPreferences userPreference);
}
