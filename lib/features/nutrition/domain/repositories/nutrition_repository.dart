import '../entities/nutrition_summary.dart';

abstract class NutritionRepository {
  Future<NutritionSummary> getNutritionSummary({int days = 7});
}
