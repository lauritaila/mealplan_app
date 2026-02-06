import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_plan_app/config/config.dart';

class DioFactory {
  static Dio create({
    String? baseUrl,
    FlutterSecureStorage? secureStorage,
    bool enableLogging = false,
  }) {
    final storage = secureStorage ?? const FlutterSecureStorage();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? Enviroment.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await storage.read(key: 'SUPABASE_ACCESS_TOKEN');
            // If caller explicitly opted out of auth check, continue.
            final skipAuth = options.extra['skipAuth'] == true;
            if (!skipAuth) {
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              } else {
                // No token available and auth is required: return 401 immediately.
                final resp = Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Unauthorized: missing token'},
                );
                return handler.resolve(resp);
              }
            }
          } catch (_) {
            // ignore storage errors and continue without token
          }
          handler.next(options);
        },
      ),
    );

    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
