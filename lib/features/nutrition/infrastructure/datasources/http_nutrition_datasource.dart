import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/config/constants/dio.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/datasources/nutrition_datasource.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../dto/nutrition_summary_response_dto.dart';
import '../mappers/nutrition_mapper.dart';

class HttpNutritionDatasource implements NutritionDatasource {
  final Dio _dio;

  HttpNutritionDatasource({Dio? httpClient, String? baseUrl})
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

  @override
  Future<NutritionSummary> getNutritionSummary({int days = 7}) async {
    try {
      final response = await _dio.get(
        '/api/nutrition/summary',
        queryParameters: {'days': days},
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null && data is Map<String, dynamic>) {
        final dto = NutritionSummaryResponseDto.fromJson(data);
        return NutritionMapper.dtoToEntity(dto);
      } else {
        throw NetworkAppError.badResponse();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const DataAppError.notFound('Nutrition summary');
      }
      throw NetworkAppError.badResponse(details: e.message);
    } catch (e) {
      if (e is AppError) rethrow;
      throw NetworkAppError.badResponse(details: e.toString());
    }
  }
}
