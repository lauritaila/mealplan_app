import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_plan_app/config/constants/storage_keys.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/preferences/domain/domain.dart';
import 'package:meal_plan_app/features/preferences/infrastructure/infrastructure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreferencesSupabaseDatasourceImpl implements PreferencesDatasource {
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage;

  PreferencesSupabaseDatasourceImpl(
    this._supabaseClient, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<PreferencesConfiguration> fetchPreferencesConfiguration() async {
    final response = await _supabaseClient
        .from('configurations')
        .select()
        .eq('name', 'dietary_preferences')
        .maybeSingle();

    if (response == null) {
      throw const ConfigAppError.missing('dietary_preferences');
    }

    return PreferencesConfigurationMapper.fromRow(response);
  }

  @override
  Future<UserPreferences?> fetchUserPreference() async {
    try {
      String? authUserId = _supabaseClient.auth.currentUser?.id;
      if (authUserId == null) {
        final refreshToken = await _secureStorage.read(
          key: StorageKeys.supabaseRefreshToken,
        );
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _supabaseClient.auth.setSession(refreshToken);
          authUserId = _supabaseClient.auth.currentUser?.id;
        }
      }

      if (authUserId == null) {
        throw const PermissionAppError.unauthorized();
      }

      final response = await _supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', authUserId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserPreferencesMapper.fromMap(response);
    } on PostgrestException catch (e) {
      final details = [
        if (e.message.isNotEmpty) e.message,
        if (e.details != null && e.details.toString().isNotEmpty)
          e.details.toString(),
        if (e.hint != null && e.hint.toString().isNotEmpty) e.hint.toString(),
      ].join(' | ');
      throw DataAppError(
        details.isNotEmpty
            ? 'Failed to fetch user preferences: $details'
            : 'Failed to fetch user preferences.',
        code: e.code ?? 'DATA_FETCH_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserPreference(UserPreferences userPreference) async {
    try {
      String? authUserId = _supabaseClient.auth.currentUser?.id;
      if (authUserId == null) {
        final refreshToken = await _secureStorage.read(
          key: StorageKeys.supabaseRefreshToken,
        );
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _supabaseClient.auth.setSession(refreshToken);
          authUserId = _supabaseClient.auth.currentUser?.id;
        }
      }
      if (authUserId == null) {
        throw const PermissionAppError.unauthorized();
      }
      final preferencesMap = UserPreferencesMapper.toMap(userPreference);
      preferencesMap.remove('id');
      preferencesMap.remove('created_at');
      preferencesMap.remove('updated_at');
      preferencesMap['user_id'] = authUserId;

      await _supabaseClient
          .from('user_preferences')
          .upsert(preferencesMap, onConflict: 'user_id');
    } on PostgrestException catch (e) {
      final details = [
        if (e.message.isNotEmpty) e.message,
        if (e.details != null && e.details.toString().isNotEmpty)
          e.details.toString(),
        if (e.hint != null && e.hint.toString().isNotEmpty) e.hint.toString(),
      ].join(' | ');
      throw DataAppError(
        details.isNotEmpty
            ? 'Failed to update user preferences: $details'
            : 'Failed to update user preferences.',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error: ${e.toString()}');
    }
  }
}
