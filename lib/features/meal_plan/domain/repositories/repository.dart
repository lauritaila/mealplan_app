import 'package:meal_plan_app/features/auth/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/domain/entities/entities.dart';

abstract class MealPlanRepository {
  Future<UserPreferences> getUserPreferences(String userId);
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request);
  Future<List<DayMealEntry>> getDayMealEntries(String userId, {String? date});
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(String userId);
}
