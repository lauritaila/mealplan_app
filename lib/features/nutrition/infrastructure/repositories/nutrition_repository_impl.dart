import '../../domain/datasources/nutrition_datasource.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/repositories/nutrition_repository.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionDatasource datasource;

  NutritionRepositoryImpl({required this.datasource});

  @override
  Future<NutritionSummary> getNutritionSummary({int days = 7}) {
    return datasource.getNutritionSummary(days: days);
  }
}
