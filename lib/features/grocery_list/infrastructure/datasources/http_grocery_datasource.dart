import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/config/constants/dio.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';
import 'package:meal_plan_app/features/grocery_list/infrastructure/mappers/grocery_mapper.dart';
import 'package:meal_plan_app/features/grocery_list/infrastructure/mappers/pantry_mapper.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class HttpGroceryDatasource extends GroceryDatasource {
  final Dio _dio;

  HttpGroceryDatasource({Dio? httpClient, String? baseUrl})
    : _dio =
          httpClient ??
                DioFactory.create(baseUrl: baseUrl ?? Enviroment.apiBaseUrl)
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

  // ---------------------------------------------------------------------------
  // Grocery Lists
  // ---------------------------------------------------------------------------

  @override
  Future<List<GroceryList>> getGroceryLists() async {
    try {
      final response = await _dio.get('/api/grocery-lists');
      _assertSuccess(response.statusCode ?? 200);
      final data = response.data;
      if (data == null) return [];
      if (data is! List)
        throw const DataAppError.serializationFailed('grocery lists');
      return GroceryListMapper.fromList(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<GroceryList> createGroceryList({
    required String name,
    int? mealPlanId,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};
      if (mealPlanId != null) body['meal_plan_id'] = mealPlanId;
      final response = await _dio.post('/api/grocery-lists', data: body);
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return GroceryListMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<GroceryListDetail> getGroceryListDetail(int id) async {
    try {
      final response = await _dio.get('/api/grocery-lists/$id');
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return GroceryListDetailMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<GroceryList> updateGroceryList(int id, {required String name}) async {
    try {
      final response = await _dio.patch(
        '/api/grocery-lists/$id',
        data: {'name': name},
      );
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return GroceryListMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<void> deleteGroceryList(int id) async {
    try {
      final response = await _dio.delete('/api/grocery-lists/$id');
      _assertSuccess(response.statusCode ?? 200);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  // ---------------------------------------------------------------------------
  // Grocery List Items
  // ---------------------------------------------------------------------------

  @override
  Future<GroceryListItem> addGroceryListItem(
    int listId, {
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
  }) async {
    try {
      final body = <String, dynamic>{'quantity': quantity, 'unit': unit};
      if (ingredientName != null) body['ingredient_name'] = ingredientName;
      if (ingredientId != null) body['ingredient_id'] = ingredientId;
      final response = await _dio.post(
        '/api/grocery-lists/$listId/items',
        data: body,
      );
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return GroceryListItemMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<GroceryListItem> updateGroceryListItem(
    int listId,
    int itemId, {
    double? quantity,
    bool? checked,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (quantity != null) body['quantity'] = quantity;
      if (checked != null) body['checked'] = checked;
      final response = await _dio.patch(
        '/api/grocery-lists/$listId/items/$itemId',
        data: body,
      );
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return GroceryListItemMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<void> deleteGroceryListItem(int listId, int itemId) async {
    try {
      final response = await _dio.delete(
        '/api/grocery-lists/$listId/items/$itemId',
      );
      _assertSuccess(response.statusCode ?? 200);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  // ---------------------------------------------------------------------------
  // Pantry
  // ---------------------------------------------------------------------------

  @override
  Future<List<PantryItem>> getPantryItems() async {
    try {
      final response = await _dio.get('/api/pantry');
      _assertSuccess(response.statusCode ?? 200);
      final data = response.data;
      if (data == null) return [];
      if (data is! List) throw const DataAppError.serializationFailed('pantry');
      return PantryItemMapper.fromList(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<PantryItem> addPantryItem({
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
    String? category,
    String? expiresAt,
  }) async {
    try {
      final body = <String, dynamic>{'quantity': quantity, 'unit': unit};
      if (ingredientName != null) body['ingredient_name'] = ingredientName;
      if (ingredientId != null) body['ingredient_id'] = ingredientId;
      if (category != null) body['category'] = category;
      if (expiresAt != null) body['expires_at'] = expiresAt;
      final response = await _dio.post('/api/pantry', data: body);
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return PantryItemMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<PantryItem> updatePantryItem(
    int id, {
    double? quantity,
    String? expiresAt,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (quantity != null) body['quantity'] = quantity;
      if (expiresAt != null) body['expires_at'] = expiresAt;
      final response = await _dio.patch('/api/pantry/$id', data: body);
      _assertSuccess(response.statusCode ?? 200);
      final data = _toMap(response.data);
      return PantryItemMapper.fromMap(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<void> deletePantryItem(int id) async {
    try {
      final response = await _dio.delete('/api/pantry/$id');
      _assertSuccess(response.statusCode ?? 200);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  @override
  Future<void> importMealPlan(int groceryListId, int mealPlanId) async {
    try {
      final response = await _dio.post(
        '/api/grocery-lists/$groceryListId/import-meal-plan',
        data: {'meal_plan_id': mealPlanId},
      );
      _assertSuccess(response.statusCode ?? 200);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  @override
  Future<void> importRecipe(
    int groceryListId,
    int recipeId, {
    int? servings,
  }) async {
    try {
      final body = <String, dynamic>{
        'recipe_id': recipeId,
        'servings': servings ?? 1,
      };
      final response = await _dio.post(
        '/api/grocery-lists/$groceryListId/import-recipe',
        data: body,
      );
      _assertSuccess(response.statusCode ?? 200);
    } on DioException catch (e) {
      _handleDioException(e);
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _assertSuccess(int statusCode) {
    if (statusCode < 200 || statusCode >= 300) {
      _throwByStatus(statusCode);
    }
  }

  Never _throwByStatus(int statusCode) {
    if (statusCode == 400) throw const NetworkAppError.badRequest();
    if (statusCode == 401) throw const PermissionAppError.unauthorized();
    if (statusCode == 403) throw const PermissionAppError.forbidden();
    if (statusCode == 404) throw const DataAppError.notFound('grocery');
    if (statusCode == 409) throw const DataAppError.updateFailed('grocery');
    if (statusCode == 429) throw const NetworkAppError.tooManyRequests();
    if (statusCode >= 500 && statusCode < 600) {
      throw const NetworkAppError.serverError();
    }
    throw const NetworkAppError.badResponse();
  }

  Never _handleDioException(DioException e) {
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
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }
}
