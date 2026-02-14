import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/profile/domain/domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  final SupabaseClient _supabaseClient;

  ProfileDatasourceImpl(this._supabaseClient);

  Future<Map<String, dynamic>> _loadAndValidateConfig(String userId) async {
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

    return (profile?['configurations'] as Map<String, dynamic>?) ??
        const {
          'language': 'en',
          'notifications': {'reminders': false, 'weeklySummary': true},
          'hideNutritionValues': false,
        };
  }

  @override
  Future<Map<String, dynamic>> updateLanguage(
    String userId,
    String langCode,
  ) async {
    try {
      final existingConfig = await _loadAndValidateConfig(userId);

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
      throw NetworkAppError(
        'Unexpected error updating language: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateHideNutritionValues(
    String userId,
    bool hideNutritionValues,
  ) async {
    try {
      final existingConfig = await _loadAndValidateConfig(userId);

      final updatedConfig = <String, dynamic>{
        ...existingConfig,
        'hideNutritionValues': hideNutritionValues,
      };

      await _supabaseClient
          .from('user_profiles')
          .update({'configurations': updatedConfig})
          .eq('id', userId);

      return updatedConfig;
    } on PostgrestException catch (e) {
      throw DataAppError(
        'Failed to update hide nutrition values: ${e.message}',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError(
        'Unexpected error updating hide nutrition values: ${e.toString()}',
      );
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
      throw NetworkAppError(
        'Unexpected error requesting email change: ${e.toString()}',
      );
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
    // 1. Mantener validaciones de identidad y confirmación de correo
    final authUserId = _supabaseClient.auth.currentUser?.id;
    if (authUserId == null) {
      throw const PermissionAppError.unauthorized();
    }
    if (authUserId != userId) {
      throw const PermissionAppError.forbidden();
    }
    if (email.trim().toLowerCase() !=
        confirmationEmail.trim().toLowerCase()) {
      throw const AuthAppError.unexpected(
        message: 'Email confirmation does not match.',
      );
    }

    try {
       await _supabaseClient.rpc('soft_delete_user_account');
      
    } on PostgrestException catch (e) {
      throw DataAppError(
        'Failed to deactivate account: ${e.message}',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError(
        'Unexpected error deleting account: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> reactivateAccount({required String userId}) async {
    try {
      final authUserId = _supabaseClient.auth.currentUser?.id;
      if (authUserId == null) {
        throw const PermissionAppError.unauthorized();
      }
      if (authUserId != userId) {
        throw const PermissionAppError.forbidden();
      }

      // Restore previous_status if present, else fallback to 'inactive'
      final subRow = await _supabaseClient
          .from('user_subscriptions')
          .select('previous_status')
          .eq('user_id', userId)
          .maybeSingle();
      final prevStatus = subRow?['previous_status'] as String?;
      await _supabaseClient
          .from('user_subscriptions')
          .update({'status': prevStatus ?? 'inactive', 'previous_status': null})
          .eq('user_id', userId);
      await _supabaseClient
          .from('user_profiles')
          .update({'deleted_at': null})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw DataAppError(
        'Failed to reactivate account: ${e.message}',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError(
        'Unexpected error reactivating account: ${e.toString()}',
      );
    }
  }
}
