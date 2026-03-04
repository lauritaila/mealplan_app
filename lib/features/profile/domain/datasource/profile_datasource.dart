abstract class ProfileDatasource {
  Future<Map<String, dynamic>> updateLanguage( String langCode);
  Future<Map<String, dynamic>> updateHideNutritionValues(
    bool hideNutritionValues,
  );
  Future<void> requestEmailChange(String newEmail);
  Future<void> verifyEmailChangeOtp(String newEmail, String token);
  Future<void> reactivateAccount({required String userId});
  Future<void> softDeleteAccount({
    required String userId,
    required String confirmationEmail,
  });
}
