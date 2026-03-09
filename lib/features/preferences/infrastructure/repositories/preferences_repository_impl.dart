import '../../domain/domain.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesDatasource datasource;

  PreferencesRepositoryImpl(this.datasource);

  @override
  Future<PreferencesConfiguration> fetchPreferencesConfiguration() {
    return datasource.fetchPreferencesConfiguration();
  }

  @override
  Future<UserPreferences?> fetchUserPreference() {
    return datasource.fetchUserPreference();
  }

  @override
  Future<void> saveUserPreference(UserPreferences userPreference) {
    return datasource.saveUserPreference(userPreference);
  }
}
