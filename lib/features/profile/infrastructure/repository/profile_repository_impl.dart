import 'package:meal_plan_app/features/profile/domain/domain.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;

  ProfileRepositoryImpl(this._datasource);

  @override
  Future<Map<String, dynamic>> updateLanguage(String langCode) {
    return _datasource.updateLanguage( langCode);
  }

  @override
  Future<Map<String, dynamic>> updateHideNutritionValues(
    bool hideNutritionValues,
  ) {
    return _datasource.updateHideNutritionValues( hideNutritionValues);
  }

  @override
  Future<void> requestEmailChange(String newEmail) {
    return _datasource.requestEmailChange(newEmail);
  }

  @override
  Future<void> verifyEmailChangeOtp(String newEmail, String token) {
    return _datasource.verifyEmailChangeOtp(newEmail, token);
  }

  @override
  Future<void> reactivateAccount({required String userId}) {
    return _datasource.reactivateAccount(userId: userId);
  }

  @override
  Future<void> softDeleteAccount({
    required String userId,
    required String confirmationEmail,
  }) {
    return _datasource.softDeleteAccount(
      userId: userId,
      confirmationEmail: confirmationEmail,
    );
  }
}
