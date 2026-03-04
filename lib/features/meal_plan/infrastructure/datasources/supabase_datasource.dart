import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_mapper.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/mappers/meal_plan_entries_mapper.dart';
import 'package:meal_plan_app/config/constants/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class SupabaseMealPlanDatasource extends MealPlanDatasource {
  final Dio _dio;
  final SupabaseClient? _supabaseClient;
  final String _mealPlanApiBaseUrl;

  SupabaseMealPlanDatasource({
    Dio? httpClient,
    String? mealPlanApiBaseUrl,
    SupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient,
       _mealPlanApiBaseUrl = mealPlanApiBaseUrl ?? Enviroment.apiBaseUrl,
       _dio =
           httpClient ??
                 DioFactory.create(
                   baseUrl: mealPlanApiBaseUrl ?? Enviroment.apiBaseUrl,
                 )
             ..interceptors.add(
               TalkerDioLogger(
                 talker: TalkerFlutter.init(),
                 settings: const TalkerDioLoggerSettings(
                   printRequestHeaders: true,
                   printRequestData: true,
                   printResponseData: true,
                   printResponseHeaders: false,
                 ),
               ),
             );

  @override
  Future<void> updateDayMealEntryStatus(
    int entryId, {
    required String? status,
  }) async {
    final client = _supabaseClient;
    if (client == null) {
      throw const ConfigAppError.missing('SUPABASE_CLIENT');
    }

    final normalizedStatus = status?.trim().toLowerCase();
    final valueToPersist = normalizedStatus == null || normalizedStatus.isEmpty
        ? null
        : normalizedStatus == 'skiped'
        ? 'skipped'
        : normalizedStatus;

    try {
      await client
          .from('meal_plan_entries')
          .update({'status': valueToPersist})
          .eq('id', entryId)
          .select('id')
          .single();
    } on PostgrestException catch (e) {
      final details = [
        if (e.message.isNotEmpty) e.message,
        if (e.details != null && e.details.toString().isNotEmpty)
          e.details.toString(),
        if (e.hint != null && e.hint.toString().isNotEmpty) e.hint.toString(),
      ].join(' | ');
      throw DataAppError(
        details.isNotEmpty
            ? 'Failed to update meal entry status: $details'
            : 'Failed to update meal entry status.',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

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

  @override
  Future<void> deleteMealPlanEntry(
    int entryId, {
    bool? removeShoppingList,
  }) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.delete(
        '/api/meal-plan/entries/$entryId',
        queryParameters: {
          if (removeShoppingList == true) 'removeShoppingList': 'true',
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
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
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<DayMealEntry> changeMealPlanRecipe(
    int entryId,
    ChangeMealPlanRecipeRequest request,
  ) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.patch(
        '/api/meal-plan/entries/$entryId/change-recipe',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('meal plan entry');
      }

      if (data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('meal plan entry');
      }

      return MealPlanEntriesMapper.fromEntryMap(
        Map<String, dynamic>.from(data),
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

  @override
  Future<void> deleteMealPlan(
    int mealPlanId, {
    String? deleteDescription,
    bool? removeShoppingList,
  }) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final body = <String, dynamic>{
        if (deleteDescription != null && deleteDescription.isNotEmpty)
          'delete_description': deleteDescription,
        if (removeShoppingList == true) 'removeShoppingList': true,
      };

      final response = await _dio.post(
        '/api/meal-plan/$mealPlanId/delete',
        data: body.isEmpty ? null : body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
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
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<void> moveMealPlanEntryToDate(int entryId, DateTime newDate) async {
    final client = _supabaseClient;
    if (client == null) {
      throw const ConfigAppError.missing('SUPABASE_CLIENT');
    }

    try {
      final dateOnly = newDate.toIso8601String().split('T').first;
      await client.rpc(
        'update_meal_plan_entry_date',
        params: {'p_entry_id': entryId, 'p_new_date': dateOnly},
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const DataAppError.uniqueViolation('meal_plan_entries');
      }
      throw const DataAppError.queryError();
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<DayMealEntry> swapMealPlanRecipe(int entryId, int recipeId) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.patch(
        '/api/meal-plan/entries/$entryId/swap-favorite',
        data: {'recipeId': recipeId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw const DataAppError.mappingError();
      }

      return MealPlanEntriesMapper.fromEntryMap(
        Map<String, dynamic>.from(data),
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

  @override
  Future<List<MealPlanSummary>> getMealPlans() async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }
      final response = await _dio.get(
        '/api/meal-plan',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) _throwByStatus(status);
      final data = response.data;
      if (data == null || data is! List) {
        throw const DataAppError.emptyResponse('meal plans');
      }
      return (data as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return MealPlanSummary(
          id: m['id'] as int,
          planName: m['plan_name'] as String? ?? '',
          startDate: DateTime.parse(m['start_date'] as String),
          endDate: DateTime.parse(m['end_date'] as String),
          generatedByAi: m['generated_by_ai'] as bool? ?? false,
          createdAt: DateTime.parse(m['created_at'] as String),
        );
      }).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }
      if (e.type == DioExceptionType.badResponse) {
        _throwByStatus(e.response?.statusCode ?? -1);
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
  Future<List<DayMealEntry>> getMealPlanEntries(int planId) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }
      final response = await _dio.get(
        '/api/meal-plan/$planId/entries',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) _throwByStatus(status);
      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('meal plan entries');
      }
      return MealPlanEntriesMapper.fromResponse(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }
      if (e.type == DioExceptionType.badResponse) {
        _throwByStatus(e.response?.statusCode ?? -1);
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
  Future<ReuseMealPlanResponse> reuseMealPlan(
    int planId,
    String startDate, {
    String? name,
  }) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }
      final body = <String, dynamic>{'startDate': startDate};
      if (name != null && name.isNotEmpty) body['name'] = name;
      final response = await _dio.post(
        '/api/meal-plan/$planId/reuse',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) _throwByStatus(status);
      final data = response.data;
      if (data == null || data is! Map) {
        throw const DataAppError.mappingError();
      }
      final m = Map<String, dynamic>.from(data);
      return ReuseMealPlanResponse(
        sourcePlanId: m['source_plan_id'] as int,
        newPlanId: m['new_plan_id'] as int,
        newPlanName: m['new_plan_name'] as String? ?? '',
        startDate: DateTime.parse(m['start_date'] as String),
        endDate: DateTime.parse(m['end_date'] as String),
        entriesCloned: m['entries_cloned'] as int? ?? 0,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }
      if (e.type == DioExceptionType.badResponse) {
        _throwByStatus(e.response?.statusCode ?? -1);
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
  Future<UpdateMealPlanDatesResponse> updateMealPlanDates(
    int planId,
    String startDate,
    String endDate,
  ) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }
      final body = <String, dynamic>{
        'start_date': startDate,
        'end_date': endDate,
      };
      final response = await _dio.patch(
        '/api/meal-plan/$planId/dates',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) _throwByStatus(status);
      final data = response.data;
      if (data == null || data is! Map) {
        throw const DataAppError.mappingError();
      }
      return UpdateMealPlanDatesResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }
      if (e.type == DioExceptionType.badResponse) {
        _throwByStatus(e.response?.statusCode ?? -1);
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
  Future<BulkDeductResult> bulkDeductFromPantry(
    int recipeId,
    int servings, {
    int? entryId,
  }) async {
    try {
      if (_mealPlanApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }
      final body = <String, dynamic>{
        'recipe_id': recipeId,
        'servings': servings,
        if (entryId != null) 'entry_id': entryId,
      };
      final response = await _dio.post(
        '/api/pantry/bulk-deduct',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) _throwByStatus(status);
      final data = response.data;
      if (data == null || data is! Map) {
        return const BulkDeductResult(deducted: [], missing: []);
      }
      final m = Map<String, dynamic>.from(data);
      BulkDeductIngredient mapItem(Map<String, dynamic> item) =>
          BulkDeductIngredient(
            ingredient: item['ingredient'] as String? ?? '',
            quantity: (item['quantity'] as num?)?.toDouble() ?? 0,
            unit: item['unit'] as String? ?? '',
          );
      final deducted = ((m['deducted'] as List?) ?? [])
          .map((e) => mapItem(Map<String, dynamic>.from(e as Map)))
          .toList();
      final missing = ((m['missing'] as List?) ?? [])
          .map((e) => mapItem(Map<String, dynamic>.from(e as Map)))
          .toList();
      return BulkDeductResult(deducted: deducted, missing: missing);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }
      if (e.type == DioExceptionType.badResponse) {
        _throwByStatus(e.response?.statusCode ?? -1);
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
}
