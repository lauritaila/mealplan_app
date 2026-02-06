import '../domain.dart';

abstract class AuthDatasource {
  Future<bool> isAuthenticated();
  Future<UserProfile> logIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> logOut();
  Future<UserProfile> getAuthenticatedUserProfile();
  Future<void> signInWithOtp(String email);
  Future<UserProfile> verifyOtp(String email, String token);
  Future<void> saveUserPreference(
    UserPreferences userPreference,
    String userId,
  );
  Future<bool> userExists(String email);
  Future<void> signInWithGoogle();
}
