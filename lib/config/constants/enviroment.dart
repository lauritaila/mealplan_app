import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroment {
  static Future<void> initEnv() async => dotenv.load(fileName: '.env');
  static String supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'No configure the SUPABASE_URL';
  static String supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'No configure the SUPABASE_ANON_KEY';
  static String webClientId =
      dotenv.env['WEB_CLIENT_ID'] ?? 'No configure the WEB_CLIENT_ID';
  static String mealPlanApiBaseUrl =
      dotenv.env['MEAL_PLAN_API_BASE_URL'] ??
      'No configure the MEAL_PLAN_API_BASE_URL';
}
