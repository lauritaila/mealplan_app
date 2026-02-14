abstract class ProfileRepository {
  Future<Map<String, dynamic>> updateLanguage(String userId, String langCode);
  Future<Map<String, dynamic>> updateHideNutritionValues(
    String userId,
    bool hideNutritionValues,
  );
  Future<void> requestEmailChange(String newEmail);
  Future<void> verifyEmailChangeOtp(String newEmail, String token);
  Future<void> reactivateAccount({required String userId});
  Future<void> softDeleteAccount({
    required String userId,
    required String email,
    required String confirmationEmail,
  });
}
