import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/config/constants/dio.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/infrastructure/mappers/recipe_list_item_mapper.dart';
import 'package:meal_plan_app/features/recipes/infrastructure/mappers/recipe_detail_mapper.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class SupabaseRecipeDatasource extends RecipeDatasource {
  final Dio _dio;
  static const String defaultPlaceholder = 'No configure';
  final String _apiBaseUrl;

  SupabaseRecipeDatasource({Dio? httpClient, String? apiBaseUrl})
    : _apiBaseUrl = apiBaseUrl ?? Enviroment.apiBaseUrl,
      _dio =
          httpClient ??
                DioFactory.create(baseUrl: apiBaseUrl ?? Enviroment.apiBaseUrl)
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
  Future<List<RecipeListItem>> getUserRecipes() async {
    try {
      if (_apiBaseUrl.isEmpty || _apiBaseUrl == defaultPlaceholder) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.get(
        '/api/recipes',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('recipes');
      }

      if (data is! List) {
        throw const DataAppError.serializationFailed('recipes');
      }

      return data.map((item) {
        final itemMap = Map<String, dynamic>.from(item as Map);
        return RecipeListItemMapper.fromMap(itemMap);
      }).toList();
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
  Future<List<RecipeListItem>> getFavoriteRecipes() async {
    try {
      if (_apiBaseUrl.isEmpty || _apiBaseUrl == defaultPlaceholder) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.get(
        '/api/recipes/favorites',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('favorite recipes');
      }

      if (data is! List) {
        throw const DataAppError.serializationFailed('favorite recipes');
      }

      return data.map((item) {
        final itemMap = Map<String, dynamic>.from(item as Map);
        return RecipeListItemMapper.fromMap(itemMap);
      }).toList();
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
  Future<RecipeDetail> getRecipeDetail(int id) async {
    try {
      if (_apiBaseUrl.isEmpty || _apiBaseUrl == defaultPlaceholder) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.get(
        '/api/recipes/$id',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('recipe detail');
      }

      if (data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('recipe detail');
      }

      return RecipeDetailMapper.fromMap(Map<String, dynamic>.from(data));
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
  Future<bool> toggleFavorite(int id) async {
    try {
      if (_apiBaseUrl.isEmpty || _apiBaseUrl == defaultPlaceholder) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.post(
        '/api/recipes/$id/favorite',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('toggle favorite');
      }

      if (data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('toggle favorite');
      }

      return (data['is_favorite'] ?? false) as bool;
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
    if (statusCode == 404) throw const DataAppError.notFound('recipe');
    if (statusCode == 409) throw const DataAppError.updateFailed('recipe');
    if (statusCode == 429) throw const NetworkAppError.tooManyRequests();
    if (statusCode >= 500 && statusCode < 600) {
      throw const NetworkAppError.serverError();
    }
    throw const NetworkAppError.badResponse();
  }
}
