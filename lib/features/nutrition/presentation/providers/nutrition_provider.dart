import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/nutrition_summary.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../infrastructure/datasources/http_nutrition_datasource.dart';
import '../../infrastructure/repositories/nutrition_repository_impl.dart';

part 'nutrition_provider.g.dart';

@riverpod
NutritionRepository nutritionRepository(NutritionRepositoryRef ref) {
  return NutritionRepositoryImpl(datasource: HttpNutritionDatasource());
}

@riverpod
class NutritionDaysFilter extends _$NutritionDaysFilter {
  @override
  int build() => 7;

  void setDays(int days) {
    if (days <= 0) {
      throw ArgumentError('days must be > 0');
    }
    state = days;
  }
}

@riverpod
Future<NutritionSummary> nutritionSummary(
  NutritionSummaryRef ref, {
  int days = 7,
}) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getNutritionSummary(days: days);
}

@riverpod
Future<NutritionSummary> currentNutritionSummary(
  CurrentNutritionSummaryRef ref,
) {
  final days = ref.watch(nutritionDaysFilterProvider);
  return ref.watch(nutritionSummaryProvider(days: days).future);
}
