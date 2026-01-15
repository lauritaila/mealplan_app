import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_plan_app/features/auth/domain/domain.dart';
import 'package:meal_plan_app/features/auth/infrastructure/infrastructure.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_mapper.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_entries_mapper.dart';

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
               validateStatus: (_) => true, // handle status codes manually
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

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        _throwByStatus(status);
      }

      if (data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('meal plan');
      }

      try {
        return MealPlanResponseMapper.fromMap(Map<String, dynamic>.from(data));
      } on FormatException catch (_) {
        throw const DataAppError.serializationFailed('meal plan');
      } on TypeError catch (_) {
        throw const DataAppError.serializationFailed('meal plan');
      }
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
    } on AppError {
      // Preserve the specific domain/network error instead of overriding it.
      rethrow;
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

  @override
  Future<List<DayMealEntry>> getDayMealEntries(String userId) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('MEAL_PLAN_API_BASE_URL');
      }

      final response = await _http.get(
        '/api/meal-plan/entries/day',
        queryParameters: {'userId': userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('meal plan entries');
      }

      final entries = MealPlanEntriesMapper.fromResponse(data);
      return entries;
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
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
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
