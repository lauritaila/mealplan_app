import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/repository/meal_plan_repository_provider.dart';

final canGenerateMealPlanProvider =
    FutureProvider<CanGenerateMealPlanResponse>((ref) async {
  final repository = ref.read(mealPlanRepositoryProvider);
  return repository.canGenerateMealPlan();
});
