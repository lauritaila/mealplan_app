import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_mapper.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_entries_mapper.dart';
import 'package:meal_plan_app/config/constants/dio.dart';

class SupabaseMealPlanDatasource extends MealPlanDatasource {

  final Dio _dio;
  final String _mealPlanApiBaseUrl;

  SupabaseMealPlanDatasource({
    Dio? httpClient,
    String? mealPlanApiBaseUrl,
  }) : _mealPlanApiBaseUrl = mealPlanApiBaseUrl ?? Enviroment.apiBaseUrl,
       _dio =
           httpClient ??
           DioFactory.create(
             baseUrl: mealPlanApiBaseUrl ?? Enviroment.apiBaseUrl,
           );

  @override
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.post(
        '/api/meal-plan/generate',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        if (status == 403) {
          throw const PermissionAppError.forbidden();
        }
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
  Future<List<DayMealEntry>> getDayMealEntries(
    String userId, {
    String? date,
  }) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.get(
        '/api/meal-plan/entries/day',
        queryParameters: {if (date != null) 'date': date},
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

  @override
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(
    String userId,
  ) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.get(
        '/api/meal-plan/can-generate',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('meal plan generation status');
      }

      if (data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed(
          'meal plan generation status',
        );
      }

      return MealPlanGenerationStatus(
        canGenerate: data['canGenerate'] as bool? ?? false,
        reason: data['reason'] as String?,
        remaining: data['remaining'] as int? ?? 0,
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
