import '../entities/nutrition_summary.dart';

abstract class NutritionDatasource {
  Future<NutritionSummary> getNutritionSummary({int days = 7});
}
