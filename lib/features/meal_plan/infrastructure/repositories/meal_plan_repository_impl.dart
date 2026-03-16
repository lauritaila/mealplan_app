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
  Future<void> deleteMealPlanEntry(int entryId, {bool? removeShoppingList}) {
    return datasource.deleteMealPlanEntry(
      entryId,
      removeShoppingList: removeShoppingList,
    );
  }

  @override
  Future<DayMealEntry> changeMealPlanRecipe(
    int entryId,
    ChangeMealPlanRecipeRequest request,
  ) {
    return datasource.changeMealPlanRecipe(entryId, request);
  }

  @override
  Future<void> deleteMealPlan(
    int mealPlanId, {
    String? deleteDescription,
    bool? removeShoppingList,
  }) {
    return datasource.deleteMealPlan(
      mealPlanId,
      deleteDescription: deleteDescription,
      removeShoppingList: removeShoppingList,
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

  @override
  Future<List<MealPlanSummary>> getMealPlans() {
    return datasource.getMealPlans();
  }

  @override
  Future<List<DayMealEntry>> getMealPlanEntries(int planId) {
    return datasource.getMealPlanEntries(planId);
  }

  @override
  Future<UpdateMealPlanDatesResponse> updateMealPlanDates(
    int planId,
    String startDate,
    String endDate,
  ) {
    return datasource.updateMealPlanDates(planId, startDate, endDate);
  }

  @override
  Future<ReuseMealPlanResponse> reuseMealPlan(
    int planId,
    String startDate, {
    String? name,
  }) {
    return datasource.reuseMealPlan(planId, startDate, name: name);
  }

  @override
  Future<BulkDeductResult> bulkDeductFromPantry(
    int recipeId,
    int servings, {
    int? entryId,
  }) {
    return datasource.bulkDeductFromPantry(
      recipeId,
      servings,
      entryId: entryId,
    );
  }

  @override
  Future<MealPlanCookingAssistantResponseDto> getMealPlanCookingAssistant(int planId) {
    return datasource.getMealPlanCookingAssistant(planId);
  }

  @override
  Future<CanGenerateMealPlanResponse> canGenerateMealPlan() {
    return datasource.canGenerateMealPlan();
  }
}
