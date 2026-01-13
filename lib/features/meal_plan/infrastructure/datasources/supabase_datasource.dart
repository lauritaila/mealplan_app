import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_plan_app/features/auth/domain/domain.dart';
import 'package:meal_plan_app/features/auth/infrastructure/infrastructure.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_mapper.dart';

class SupabaseMealPlanDatasource extends MealPlanDatasource {
  final SupabaseClient _supabaseClient;
  final Dio _http;
  final String _mealPlanApiBaseUrl;

  SupabaseMealPlanDatasource(
    this._supabaseClient, {
    Dio? httpClient,
    String? mealPlanApiBaseUrl,
  }) : _mealPlanApiBaseUrl =
           mealPlanApiBaseUrl ?? Enviroment.mealPlanApiBaseUrl,
       _http =
           httpClient ??
           Dio(
             BaseOptions(
               baseUrl: mealPlanApiBaseUrl ?? Enviroment.mealPlanApiBaseUrl,
             ),
           );

  @override
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('MEAL_PLAN_API_BASE_URL');
      }

      final response = await _http.post(
        '/api/meal-plan/generate',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200 || response.data == null) {
        _throwByStatus(response.statusCode ?? -1);
      }

      if (response.data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('meal plan');
      }

      return MealPlanResponseMapper.fromMap(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }

      if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode ?? -1;
        _throwByStatus(status);
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkAppError.unreachableHost();
      }

      throw const NetworkAppError.serverError();
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();
      return UserPreferencesMapper.fromMap(response);
    } catch (e) {
      throw DataAppError.fetchFailed('user preferences');
    }
  }

  Never _throwByStatus(int statusCode) {
    if (statusCode == 400) throw const NetworkAppError.badRequest();
    if (statusCode == 401) throw const PermissionAppError.unauthorized();
    if (statusCode == 403) throw const PermissionAppError.forbidden();
    if (statusCode == 404) throw const DataAppError.notFound('meal plan');
    if (statusCode == 409) throw const DataAppError.updateFailed('meal plan');
    if (statusCode == 429) throw const NetworkAppError.tooManyRequests();
    if (statusCode >= 500 && statusCode < 600) {
      throw const NetworkAppError.serverError();
    }
    throw const NetworkAppError.badResponse();
  }
}
