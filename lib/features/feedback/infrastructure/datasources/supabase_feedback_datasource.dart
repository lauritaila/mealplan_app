import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/feedback/domain/datasources/feedback_datasource.dart';
import 'package:meal_plan_app/features/feedback/domain/entities/submit_feedback_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFeedbackDatasource implements FeedbackDatasource {
  final SupabaseClient _supabase;
  final Dio _dio;

  SupabaseFeedbackDatasource({
    required SupabaseClient supabase,
    required Dio dio,
  })  : _supabase = supabase,
        _dio = dio;

  @override
  Future<void> submitFeedback(SubmitFeedbackRequest request) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) throw const PermissionAppError.unauthorized();

      await _dio.post(
        '/api/feedback',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const PermissionAppError.unauthorized();
      }
      if (e.response?.statusCode == 403) {
        throw const PermissionAppError.forbidden();
      }
      final responseData = e.response?.data;
      final errorMessage = (responseData is Map<String, dynamic>)
          ? responseData['message']?.toString()
          : responseData?.toString();

      throw NetworkAppError.badResponse(
        details: errorMessage ?? e.message,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw const NetworkAppError.serverError();
    }
  }
}
