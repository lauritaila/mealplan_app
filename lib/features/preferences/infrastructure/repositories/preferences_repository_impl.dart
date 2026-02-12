import '../../domain/domain.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesDatasource datasource;

  PreferencesRepositoryImpl(this.datasource);

  @override
  Future<PreferencesConfiguration> fetchPreferencesConfiguration() {
    return datasource.fetchPreferencesConfiguration();
  }

  @override
  Future<UserPreferences?> fetchUserPreference(String userId) {
    return datasource.fetchUserPreference(userId);
  }

  @override
  Future<void> saveUserPreference(
    UserPreferences userPreference,
    String userId,
  ) {
    return datasource.saveUserPreference(userPreference, userId);
  }
}

