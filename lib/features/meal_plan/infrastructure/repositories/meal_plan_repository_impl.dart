import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';

class MealPlanRepositoryImpl extends MealPlanRepository {
  final MealPlanDatasource datasource;

  MealPlanRepositoryImpl(this.datasource);

  @override
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request) {
    return datasource.generateMealPlan(request);
  }

  @override
  Future<List<DayMealEntry>> getDayMealEntries(String userId, {String? date}) {
    return datasource.getDayMealEntries(userId, date: date);
  }

  @override
  Future<void> updateDayMealEntryStatus(
    int entryId, {
    required String? status,
  }) {
    return datasource.updateDayMealEntryStatus(entryId, status: status);
  }

  @override
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(String userId) {
    return datasource.getMealPlanGenerationStatus(userId);
  }

  @override
  Future<void> deleteMealPlanEntry(int entryId) {
    return datasource.deleteMealPlanEntry(entryId);
  }

  @override
  Future<DayMealEntry> changeMealPlanRecipe(
    int entryId,
    ChangeMealPlanRecipeRequest request,
  ) {
    return datasource.changeMealPlanRecipe(entryId, request);
  }

  @override
  Future<void> deleteMealPlan(int mealPlanId, {String? deleteDescription}) {
    return datasource.deleteMealPlan(
      mealPlanId,
      deleteDescription: deleteDescription,
    );
  }

  @override
  Future<void> moveMealPlanEntryToDate(int entryId, DateTime newDate) {
    return datasource.moveMealPlanEntryToDate(entryId, newDate);
  }

  @override
  Future<DayMealEntry> swapMealPlanRecipe(int entryId, int recipeId) {
    return datasource.swapMealPlanRecipe(entryId, recipeId);
  }
}
