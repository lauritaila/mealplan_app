import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/profile/domain/domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  final SupabaseClient _supabaseClient;

  ProfileDatasourceImpl(this._supabaseClient);

  @override
  Future<Map<String, dynamic>> updateLanguage(String userId, String langCode) async {
    try {
      final authUserId = _supabaseClient.auth.currentUser?.id;
      if (authUserId == null) {
        throw const PermissionAppError.unauthorized();
      }
      if (authUserId != userId) {
        throw const PermissionAppError.forbidden();
      }

      final profile = await _supabaseClient
          .from('user_profiles')
          .select('configurations')
          .eq('id', userId)
          .maybeSingle();

      final existingConfig =
          (profile?['configurations'] as Map<String, dynamic>?) ??
          const {
            'language': 'en',
            'notifications': {
              'reminders': false,
              'weeklySummary': true,
            },
            'hideNutritionValues': false,
          };

      final updatedConfig = <String, dynamic>{
        ...existingConfig,
        'language': langCode,
      };

      await _supabaseClient
          .from('user_profiles')
          .update({'configurations': updatedConfig})
          .eq('id', userId);

      return updatedConfig;
    } on PostgrestException catch (e) {
      throw DataAppError(
        'Failed to update language: ${e.message}',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error updating language: ${e.toString()}');
    }
  }

  @override
  Future<void> requestEmailChange(String newEmail) async {
    try {
      await _supabaseClient.auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already')) {
        throw const AuthAppError.emailAlreadyInUse();
      }
      throw AuthAppError(e.message, code: e.statusCode);
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error requesting email change: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmailChangeOtp(String newEmail, String token) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        type: OtpType.emailChange,
        email: newEmail,
        token: token,
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('expired')) {
        throw const AuthAppError.invalidOtp();
      }
      throw AuthAppError(e.message, code: e.statusCode);
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError(
        'Unexpected error verifying email change OTP: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> softDeleteAccount({
    required String userId,
    required String email,
    required String confirmationEmail,
  }) async {
    try {
      final authUserId = _supabaseClient.auth.currentUser?.id;
      if (authUserId == null) {
        throw const PermissionAppError.unauthorized();
      }
      if (authUserId != userId) {
        throw const PermissionAppError.forbidden();
      }
      if (email.trim().toLowerCase() != confirmationEmail.trim().toLowerCase()) {
        throw const AuthAppError.unexpected(message: 'Email confirmation does not match.');
      }

      await _supabaseClient
          .from('user_subscriptions')
          .update({'status': 'inactive'})
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DataAppError(
        'Failed to deactivate subscription: ${e.message}',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error deleting account: ${e.toString()}');
    }
  }
}
