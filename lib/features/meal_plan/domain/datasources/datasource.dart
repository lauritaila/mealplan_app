import 'package:meal_plan_app/features/meal_plan/domain/entities/entities.dart';

abstract class MealPlanDatasource {
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request);
  Future<List<DayMealEntry>> getDayMealEntries(String userId, {String? date});
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(String userId);
}
