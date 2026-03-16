import 'package:meal_plan_app/features/meal_plan/domain/entities/entities.dart';

abstract class MealPlanRepository {
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request);
  Future<List<DayMealEntry>> getDayMealEntries(String userId, {String? date});
  Future<void> updateDayMealEntryStatus(int entryId, {required String? status});
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(String userId);
  Future<void> deleteMealPlanEntry(int entryId, {bool? removeShoppingList});
  Future<DayMealEntry> changeMealPlanRecipe(
    int entryId,
    ChangeMealPlanRecipeRequest request,
  );
  Future<void> deleteMealPlan(
    int mealPlanId, {
    String? deleteDescription,
    bool? removeShoppingList,
  });
  Future<void> moveMealPlanEntryToDate(int entryId, DateTime newDate);
  Future<DayMealEntry> swapMealPlanRecipe(int entryId, int recipeId);
  // --- New ---
  Future<List<MealPlanSummary>> getMealPlans();
  Future<List<DayMealEntry>> getMealPlanEntries(int planId);
  Future<ReuseMealPlanResponse> reuseMealPlan(
    int planId,
    String startDate, {
    String? name,
  });
  Future<BulkDeductResult> bulkDeductFromPantry(
    int recipeId,
    int servings, {
    int? entryId,
  });
  Future<UpdateMealPlanDatesResponse> updateMealPlanDates(
    int planId,
    String startDate,
    String endDate,
  );
  Future<MealPlanCookingAssistantResponseDto> getMealPlanCookingAssistant(int planId);
  Future<CanGenerateMealPlanResponse> canGenerateMealPlan();
}
