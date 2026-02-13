
abstract class ProfileDatasource {
  Future<Map<String, dynamic>> updateLanguage(String userId, String langCode);
  Future<void> requestEmailChange(String newEmail);
  Future<void> verifyEmailChangeOtp(String newEmail, String token);
  Future<void> softDeleteAccount({
    required String userId,
    required String email,
    required String confirmationEmail,
  });
}