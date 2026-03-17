import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/shared/infrastructure/datasources/subscription_datasource.dart';
import 'package:meal_plan_app/features/shared/infrastructure/models/subscription_dtos.dart';

class SubscriptionDatasourceImpl implements SubscriptionDatasource {
  final Dio _dio;
  late final String _baseUrl;

  SubscriptionDatasourceImpl(this._dio) {
    _baseUrl = '${Enviroment.apiBaseUrl}/api/subscriptions';
  }

  @override
  Future<List<SubscriptionPlanResponseDto>> getSubscriptionPlans() async {
    try {
      final response = await _dio.get('$_baseUrl/plans');
      
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is! List) {
          throw NetworkAppError('Unexpected response format: expected List, got ${data.runtimeType}');
        }
        return data.map((json) => SubscriptionPlanResponseDto.fromJson(json)).toList();
      } else {
        throw NetworkAppError('Failed to fetch subscription plans: ${response.statusMessage}', code: response.statusCode?.toString());
      }
    } on DioException catch (e) {
      throw NetworkAppError('Network error fetching subscription plans: ${e.message}', code: e.response?.statusCode?.toString());
    } on NetworkAppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error fetching subscription plans: $e');
    }
  }

  @override
  Future<ValidateCodeResponseDto> validatePromotionCode({
    required String code,
  }) async {
    try {
      final response = await _dio.post('$_baseUrl/validate-code', data: {
        'code': code,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ValidateCodeResponseDto.fromJson(response.data);
      } else {
        throw NetworkAppError('Failed to validate promo code: ${response.statusMessage}', code: response.statusCode?.toString());
      }
    } on DioException catch (e) {
      throw NetworkAppError('Network error validating promo code: ${e.message}', code: e.response?.statusCode?.toString());
    } on NetworkAppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error validating promo code: $e');
    }
  }
}
