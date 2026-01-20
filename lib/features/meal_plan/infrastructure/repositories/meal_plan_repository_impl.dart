import 'package:meal_plan_app/features/auth/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';

class MealPlanRepositoryImpl extends MealPlanRepository {
  final MealPlanDatasource datasource;

  MealPlanRepositoryImpl(this.datasource);

  @override
  Future<MealPlanResponse> generateMealPlan(NewMealPlanRequest request) {
    return datasource.generateMealPlan(request);
  }

  @override
  Future<UserPreferences> getUserPreferences(String userId) {
    return datasource.getUserPreferences(userId);
  }

  @override
  Future<List<DayMealEntry>> getDayMealEntries(String userId, {String? date}) {
    return datasource.getDayMealEntries(userId, date: date);
  }

  @override
  Future<MealPlanGenerationStatus> getMealPlanGenerationStatus(String userId) {
    return datasource.getMealPlanGenerationStatus(userId);
  }
}
