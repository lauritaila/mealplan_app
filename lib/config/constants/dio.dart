import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/config/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final liveSessionToken =
                Supabase.instance.client.auth.currentSession?.accessToken;
            final persistedToken = await storage.read(
              key: StorageKeys.supabaseAccessToken,
            );
            final token =
                (liveSessionToken != null && liveSessionToken.isNotEmpty)
                ? liveSessionToken
                : persistedToken;

            if (liveSessionToken != null &&
                liveSessionToken.isNotEmpty &&
                liveSessionToken != persistedToken) {
              await storage.write(
                key: StorageKeys.supabaseAccessToken,
                value: liveSessionToken,
              );
            }

            final prefs = await SharedPreferences.getInstance();
            final storedLangCode = prefs.getString('app_language_code');
            options.headers['Accept-Language'] = storedLangCode ?? 'en';

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
            // ignore storage errors and continue without token or language
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
