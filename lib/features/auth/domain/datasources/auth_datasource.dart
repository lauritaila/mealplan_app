import '../domain.dart';

abstract class AuthDatasource {
  Future<bool> isAuthenticated();
  Future<UserProfile> logIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> logOut();
  Future<UserProfile> getAuthenticatedUserProfile();
  Future<void> signInWithOtp(String email);
  Future<UserProfile> verifyOtp(String email, String token);
  Future<void> markOnboardingComplete(String userId);
  Future<AccessStatus> getUserAccessStatus(String email);
  Future<AccessStatus> signInWithGoogle();
}
