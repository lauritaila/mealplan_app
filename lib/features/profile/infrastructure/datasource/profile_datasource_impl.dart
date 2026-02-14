import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/profile/domain/domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  final SupabaseClient _supabaseClient;

  ProfileDatasourceImpl(this._supabaseClient);

  bool _isInvalidOrExpiredOtp(AuthException exception) {
    final normalizedStatus = exception.statusCode?.toString().toLowerCase();
    if (normalizedStatus == null) return false;

    return normalizedStatus == '400' ||
        normalizedStatus == '401' ||
        normalizedStatus == '422' ||
        normalizedStatus == 'invalid_otp' ||
        normalizedStatus == 'otp_expired';
  }

  bool _isDuplicateEmailError(AuthException exception) {
    final normalizedStatus = exception.statusCode?.toString().toLowerCase();
    if (normalizedStatus == null) return false;

    // Supabase auth usually reports duplicate/conflict email with 409/422.
    return normalizedStatus == '409' ||
        normalizedStatus == '422' ||
        normalizedStatus == 'email_exists' ||
        normalizedStatus == 'user_already_exists';
  }

  @override
  Future<Map<String, dynamic>> updateLanguage(
    String userId,
    String langCode,
  ) async {
    try {
      // Llamamos al RPC pasándole el nombre de la llave y el valor
      final response = await _supabaseClient.rpc(
        'patch_user_config',
        params: {
          'key_name': 'language',
          'key_value': langCode, // Supabase manejará la conversión a JSONB
        },
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw NetworkAppError('Error updating language: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateHideNutritionValues(
    String userId,
    bool hideNutritionValues,
  ) async {
    try {
      final response = await _supabaseClient.rpc(
        'patch_user_config',
        params: {
          'key_name': 'hideNutritionValues',
          'key_value': hideNutritionValues,
        },
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw NetworkAppError('Error updating nutrition toggle: $e');
    }
  }

  @override
  Future<void> requestEmailChange(String newEmail) async {
    try {
      await _supabaseClient.auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      if (_isDuplicateEmailError(e)) {
        throw const AuthAppError.emailAlreadyInUse();
      }
      throw AuthAppError(e.message, code: e.statusCode?.toString());
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
      if (_isInvalidOrExpiredOtp(e)) {
        throw const AuthAppError.invalidOtp();
      }
      throw AuthAppError(e.message, code: e.statusCode?.toString());
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
    final currentUser = _supabaseClient.auth.currentUser;
    final authUserId = currentUser?.id;
    if (authUserId == null) {
      throw const PermissionAppError.unauthorized();
    }
    if (authUserId != userId) {
      throw const PermissionAppError.forbidden();
    }
    final canonicalEmail = currentUser!.email;
    if (canonicalEmail == null ||
        canonicalEmail.trim().toLowerCase() !=
            confirmationEmail.trim().toLowerCase()) {
      throw const AuthAppError.emailConfirmationMismatch();
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

      final result = await _supabaseClient.rpc('reactivate_user_account');

      if (result is bool && result == false) {
        throw const DataAppError.updateFailed('account reactivation');
      }
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
