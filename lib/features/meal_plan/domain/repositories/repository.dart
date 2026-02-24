import 'package:meal_plan_app/features/meal_plan/domain/entities/entities.dart';

abstract class MealPlanRepository {
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request);
  Future<List<DayMealEntry>> getDayMealEntries(String userId, {String? date});
  Future<void> updateDayMealEntryStatus(int entryId, {required String? status});
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(String userId);
  Future<void> deleteMealPlanEntry(int entryId);
  Future<DayMealEntry> changeMealPlanRecipe(int entryId, ChangeMealPlanRecipeRequest request);
  Future<void> deleteMealPlan(int mealPlanId, {String? deleteDescription});
  Future<void> moveMealPlanEntryToDate(int entryId, DateTime newDate);
  Future<DayMealEntry> swapMealPlanRecipe(int entryId, int recipeId);
}
